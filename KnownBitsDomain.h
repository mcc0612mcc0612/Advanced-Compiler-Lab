//===- KnownBitsDomain.h - The abstract domain ----------------------------===//
//
// The known-bits lattice.  Each bit of an integer is tracked independently as
// known zero, known one, or unknown, so an abstract value such as
//
//        0000??10
//
// stands for the set of concrete values {2, 6, 10, 14}.  Per bit the lattice is
//
//        ?            could be either
//       / \
//      0   1
//       \ /
//      bottom         unreachable, or not yet analyzed
//
// and the lattice for a whole value is the product of one of these per bit,
// with a single shared bottom.  Join keeps a bit only where both sides agree
// on it; every disagreement becomes `?`.  A value can lose each bit at most
// once, so the lattice has finite height and the solver needs no widening.
//
// MLIR's dataflow framework asks three things of a lattice value:
//
//   * a default constructor, which must produce the bottom element, because the
//     solver starts every value optimistically and raises it as facts arrive;
//   * a static join(), which must be commutative, associative, idempotent, and
//     monotone -- assertions in Lattice<> check monotonicity in debug builds;
//   * operator== and print().
//
//===----------------------------------------------------------------------===//

#ifndef KNOWNBITS_DOMAIN_H
#define KNOWNBITS_DOMAIN_H

#include "llvm/ADT/APInt.h"
#include "llvm/Support/raw_ostream.h"

#include <cassert>
#include <optional>

namespace knownbits {

/// What is known about the bits of one integer of a fixed width: bit i is
/// known zero if `zero[i]` is set, known one if `one[i]` is set, and unknown
/// if neither is.  Both set at once would describe no value at all, and is
/// never constructed.
struct Bits {
  llvm::APInt zero;
  llvm::APInt one;

  Bits(llvm::APInt zero, llvm::APInt one)
      : zero(std::move(zero)), one(std::move(one)) {
    assert(this->zero.getBitWidth() == this->one.getBitWidth() &&
           "masks must have the same width");
    assert(!this->zero.intersects(this->one) &&
           "a bit cannot be both known zero and known one");
  }

  static Bits unknown(unsigned width) {
    return Bits(llvm::APInt::getZero(width), llvm::APInt::getZero(width));
  }
  static Bits constant(const llvm::APInt &value) { return Bits(~value, value); }

  unsigned width() const { return zero.getBitWidth(); }
  bool isUnknown() const { return zero.isZero() && one.isZero(); }
  bool isConstant() const { return (zero | one).isAllOnes(); }

  /// Whether `value` is one of the concrete values this describes.
  bool contains(const llvm::APInt &value) const {
    return !value.intersects(zero) && one.isSubsetOf(value);
  }

  /// The smallest and largest unsigned values this describes: every unknown
  /// bit taken as zero, or as one.
  llvm::APInt umin() const { return one; }
  llvm::APInt umax() const { return ~zero; }

  /// Least upper bound: a bit stays known only if both sides know it and
  /// agree on its value.
  static Bits join(const Bits &lhs, const Bits &rhs) {
    return Bits(lhs.zero & rhs.zero, lhs.one & rhs.one);
  }

  bool operator==(const Bits &other) const {
    return width() == other.width() && zero == other.zero && one == other.one;
  }
  bool operator!=(const Bits &other) const { return !(*this == other); }

  /// Most significant bit first, like a binary literal.
  void print(llvm::raw_ostream &os) const {
    for (unsigned i = width(); i-- > 0;)
      os << (zero[i] ? '0' : one[i] ? '1' : '?');
  }
};

/// The lattice element attached to each SSA value.  Top is kept separate from
/// "all bits unknown" so that values the analysis does not track at all
/// (floats, pointers, vectors) have somewhere to go without needing a width;
/// an integer with no known bits is normalized to top, so each element has
/// exactly one representation.
class KnownBitsState {
public:
  /// Bottom.
  KnownBitsState() = default;

  /* implicit */ KnownBitsState(const Bits &bits) {
    if (bits.isUnknown())
      kind = Kind::Top;
    else {
      kind = Kind::Known;
      known = bits;
    }
  }

  static KnownBitsState bottom() { return KnownBitsState(); }
  static KnownBitsState top() {
    KnownBitsState state;
    state.kind = Kind::Top;
    return state;
  }

  bool isBottom() const { return kind == Kind::Bottom; }
  bool isTop() const { return kind == Kind::Top; }
  bool hasKnownBits() const { return kind == Kind::Known; }

  /// The bits of a `width`-bit value in this state.  Not meaningful for
  /// bottom, which describes no value.
  Bits bits(unsigned width) const {
    assert(!isBottom() && "bottom has no bits");
    if (isTop())
      return Bits::unknown(width);
    assert(known->width() == width && "state belongs to a different type");
    return *known;
  }

  static KnownBitsState join(const KnownBitsState &lhs,
                             const KnownBitsState &rhs) {
    if (lhs.isBottom())
      return rhs;
    if (rhs.isBottom())
      return lhs;
    if (lhs.isTop() || rhs.isTop())
      return top();
    return Bits::join(*lhs.known, *rhs.known);
  }

  bool operator==(const KnownBitsState &other) const {
    return kind == other.kind && known == other.known;
  }
  bool operator!=(const KnownBitsState &other) const {
    return !(*this == other);
  }

  void print(llvm::raw_ostream &os) const {
    if (isBottom())
      os << "bottom";
    else if (isTop())
      os << "top";
    else
      known->print(os);
  }

private:
  enum class Kind { Bottom, Known, Top };
  Kind kind = Kind::Bottom;
  /// Set exactly when `kind` is Known, and then has at least one known bit.
  std::optional<Bits> known;
};

inline llvm::raw_ostream &operator<<(llvm::raw_ostream &os,
                                     const KnownBitsState &state) {
  state.print(os);
  return os;
}

} // namespace knownbits

#endif
