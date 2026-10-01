//===- KnownBitsTransfer.h - Transfer functions on Bits -------------------===//
//
// One function per integer operation: given what is known about the operands'
// bits, state what is known about the result's.  These know nothing about
// MLIR; KnownBitsAnalysis.cpp maps operations onto them.
//
// Each must be sound -- every concrete result of the operation on values the
// operands describe must be contained in the returned Bits -- and monotone.
//
//===----------------------------------------------------------------------===//

#ifndef KNOWNBITS_TRANSFER_H
#define KNOWNBITS_TRANSFER_H

#include "KnownBitsDomain.h"

#include <algorithm>

namespace knownbits {

//===----------------------------------------------------------------------===//
// Bitwise operations: each result bit depends on one bit of each operand.
//===----------------------------------------------------------------------===//

/// A result bit is zero if either input bit is zero, one if both are one.
inline Bits bitAnd(const Bits &a, const Bits &b) {
  return Bits(a.zero | b.zero, a.one & b.one);
}

/// A result bit is one if either input bit is one, zero if both are zero.
inline Bits bitOr(const Bits &a, const Bits &b) {
  return Bits(a.zero & b.zero, a.one | b.one);
}

/// A result bit is known only if both input bits are: zero where they agree,
/// one where they differ.
inline Bits bitXor(const Bits &a, const Bits &b) {
  return Bits((a.zero & b.zero) | (a.one & b.one),
              (a.zero & b.one) | (a.one & b.zero));
}

//===----------------------------------------------------------------------===//
// Arithmetic
//===----------------------------------------------------------------------===//

/// a + b + carryIn, as a ripple-carry adder whose wires carry three values.
/// A sum bit is known only when both input bits and the incoming carry are;
/// the outgoing carry is the majority of those three, so it is known as soon
/// as two of them are known and agree.
inline Bits addWithCarry(const Bits &a, const Bits &b, bool carryIn) {
  unsigned width = a.width();
  Bits result = Bits::unknown(width);
  bool carryZero = !carryIn, carryOne = carryIn;
  for (unsigned i = 0; i < width; ++i) {
    bool aZero = a.zero[i], aOne = a.one[i];
    bool bZero = b.zero[i], bOne = b.one[i];
    if ((aZero || aOne) && (bZero || bOne) && (carryZero || carryOne)) {
      if (aOne ^ bOne ^ carryOne)
        result.one.setBit(i);
      else
        result.zero.setBit(i);
    }
    unsigned zeros = aZero + bZero + carryZero;
    unsigned ones = aOne + bOne + carryOne;
    carryZero = zeros >= 2;
    carryOne = ones >= 2;
  }
  return result;
}

inline Bits add(const Bits &a, const Bits &b) {
  return addWithCarry(a, b, /*carryIn=*/false);
}

/// a - b is a + ~b + 1, and complementing swaps what is known zero and one.
inline Bits sub(const Bits &a, const Bits &b) {
  return addWithCarry(a, Bits(b.one, b.zero), /*carryIn=*/true);
}

/// Trailing zeros add up: if a is a multiple of 2^m and b of 2^n, then a * b
/// is a multiple of 2^(m+n).  Nothing is claimed about the higher bits unless
/// both operands are fully known.
inline Bits mul(const Bits &a, const Bits &b) {
  unsigned width = a.width();
  if (a.isConstant() && b.isConstant())
    return Bits::constant(a.one * b.one);
  unsigned trailingZeros =
      std::min(width, a.zero.countr_one() + b.zero.countr_one());
  return Bits(llvm::APInt::getLowBitsSet(width, trailingZeros),
              llvm::APInt::getZero(width));
}

//===----------------------------------------------------------------------===//
// Shifts
//
// The shift amount is itself only partly known, so shift by every amount it
// could be and join the results.  An amount of `width` or more makes the
// result poison in LLVM, which no claim can be wrong about, so those amounts
// are skipped.
//===----------------------------------------------------------------------===//

template <typename ShiftByConstant>
Bits shiftByEveryPossibleAmount(const Bits &a, const Bits &amount,
                                ShiftByConstant shift) {
  unsigned width = a.width();
  std::optional<Bits> result;
  for (unsigned s = 0; s < width; ++s) {
    if (!amount.contains(llvm::APInt(width, s)))
      continue;
    Bits shifted = shift(a, s);
    result = result ? Bits::join(*result, shifted) : shifted;
  }
  // No amount below `width` is possible: the result is always poison.
  if (!result)
    return Bits::unknown(width);
  return *result;
}

/// Zeros are shifted in at the bottom.
inline Bits shl(const Bits &a, const Bits &amount) {
  return shiftByEveryPossibleAmount(a, amount, [](const Bits &x, unsigned s) {
    return Bits(x.zero.shl(s) | llvm::APInt::getLowBitsSet(x.width(), s),
                x.one.shl(s));
  });
}

/// Zeros are shifted in at the top.
inline Bits lshr(const Bits &a, const Bits &amount) {
  return shiftByEveryPossibleAmount(a, amount, [](const Bits &x, unsigned s) {
    return Bits(x.zero.lshr(s) | llvm::APInt::getHighBitsSet(x.width(), s),
                x.one.lshr(s));
  });
}

/// Copies of the sign bit are shifted in at the top, so they are known exactly
/// when the sign bit is -- which is what an arithmetic shift of each mask does.
inline Bits ashr(const Bits &a, const Bits &amount) {
  return shiftByEveryPossibleAmount(a, amount, [](const Bits &x, unsigned s) {
    return Bits(x.zero.ashr(s), x.one.ashr(s));
  });
}

//===----------------------------------------------------------------------===//
// Casts
//===----------------------------------------------------------------------===//

inline Bits trunc(const Bits &a, unsigned width) {
  return Bits(a.zero.trunc(width), a.one.trunc(width));
}

/// The new high bits are known zero.
inline Bits zext(const Bits &a, unsigned width) {
  return Bits(a.zero.zext(width) |
                  llvm::APInt::getHighBitsSet(width, width - a.width()),
              a.one.zext(width));
}

/// The new high bits are copies of the sign bit, known exactly when it is.
inline Bits sext(const Bits &a, unsigned width) {
  return Bits(a.zero.sext(width), a.one.sext(width));
}

//===----------------------------------------------------------------------===//
// Comparisons and select.  A comparison's result is a one-bit value.
//===----------------------------------------------------------------------===//

inline Bits boolean(bool value) {
  return Bits::constant(llvm::APInt(1, value));
}

/// Unequal if some bit is known to differ; equal only if both are constants.
inline Bits icmpEq(const Bits &a, const Bits &b) {
  if (a.zero.intersects(b.one) || a.one.intersects(b.zero))
    return boolean(false);
  if (a.isConstant() && b.isConstant())
    return boolean(true);
  return Bits::unknown(1);
}

inline Bits icmpNe(const Bits &a, const Bits &b) {
  Bits eq = icmpEq(a, b);
  return Bits(eq.one, eq.zero);
}

/// Unsigned less-than, decided by the extremes: true if even the largest a is
/// below the smallest b, false if even the smallest a is not below the
/// largest b.
inline Bits icmpUlt(const Bits &a, const Bits &b) {
  if (a.umax().ult(b.umin()))
    return boolean(true);
  if (a.umin().uge(b.umax()))
    return boolean(false);
  return Bits::unknown(1);
}

inline Bits icmpUle(const Bits &a, const Bits &b) {
  if (a.umax().ule(b.umin()))
    return boolean(true);
  if (a.umin().ugt(b.umax()))
    return boolean(false);
  return Bits::unknown(1);
}

inline Bits icmpUgt(const Bits &a, const Bits &b) { return icmpUlt(b, a); }
inline Bits icmpUge(const Bits &a, const Bits &b) { return icmpUle(b, a); }

/// A known condition picks one arm; an unknown one could pick either.
inline Bits select(const Bits &condition, const Bits &ifTrue,
                   const Bits &ifFalse) {
  if (condition.one[0])
    return ifTrue;
  if (condition.zero[0])
    return ifFalse;
  return Bits::join(ifTrue, ifFalse);
}

} // namespace knownbits

#endif
