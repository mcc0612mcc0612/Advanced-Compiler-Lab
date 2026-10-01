//===- KnownBitsAnalysis.cpp - Transfer functions for LLVM dialect ops ----===//
//
// Maps each LLVM dialect operation to its transfer function in
// KnownBitsTransfer.h.  The bit-level reasoning lives there; this file only
// decides which rule applies and moves states in and out of the solver.
//
// Anything without a rule is unknown, which is always sound.
//
//===----------------------------------------------------------------------===//

#include "KnownBitsAnalysis.h"
#include "KnownBitsTransfer.h"

#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/Matchers.h"

using namespace mlir;

namespace knownbits {

void KnownBitsAnalysis::setToEntryState(KnownBitsLattice *lattice) {
  propagateIfChanged(lattice, lattice->join(KnownBitsState::top()));
}

/// The rule for `op`, whose result is a `width`-bit integer, or nothing if no
/// rule covers it.  `in(i)` is what is known about operand i, which must be a
/// scalar integer.
static std::optional<Bits> transfer(Operation *op, unsigned width,
                                    function_ref<Bits(unsigned)> in) {
  auto isInteger = [&](unsigned i) {
    return isa<IntegerType>(op->getOperand(i).getType());
  };

  // The operands of these have the result's type, so they are integers too.
  if (isa<LLVM::AndOp>(op))
    return bitAnd(in(0), in(1));
  if (isa<LLVM::OrOp>(op))
    return bitOr(in(0), in(1));
  if (isa<LLVM::XOrOp>(op))
    return bitXor(in(0), in(1));
  if (isa<LLVM::AddOp>(op))
    return add(in(0), in(1));
  if (isa<LLVM::SubOp>(op))
    return sub(in(0), in(1));
  if (isa<LLVM::MulOp>(op))
    return mul(in(0), in(1));
  if (isa<LLVM::ShlOp>(op))
    return shl(in(0), in(1));
  if (isa<LLVM::LShrOp>(op))
    return lshr(in(0), in(1));
  if (isa<LLVM::AShrOp>(op))
    return ashr(in(0), in(1));
  if (isa<LLVM::SelectOp>(op))
    return select(in(0), in(1), in(2));

  if (isa<LLVM::TruncOp>(op))
    return trunc(in(0), width);
  if (isa<LLVM::ZExtOp>(op))
    return zext(in(0), width);
  if (isa<LLVM::SExtOp>(op))
    return sext(in(0), width);

  // icmp also compares pointers, which are not tracked.
  if (auto icmp = dyn_cast<LLVM::ICmpOp>(op); icmp && isInteger(0)) {
    switch (icmp.getPredicate()) {
    case LLVM::ICmpPredicate::eq:
      return icmpEq(in(0), in(1));
    case LLVM::ICmpPredicate::ne:
      return icmpNe(in(0), in(1));
    case LLVM::ICmpPredicate::ult:
      return icmpUlt(in(0), in(1));
    case LLVM::ICmpPredicate::ule:
      return icmpUle(in(0), in(1));
    case LLVM::ICmpPredicate::ugt:
      return icmpUgt(in(0), in(1));
    case LLVM::ICmpPredicate::uge:
      return icmpUge(in(0), in(1));
    // Signed comparisons have no rule yet.
    case LLVM::ICmpPredicate::slt:
    case LLVM::ICmpPredicate::sle:
    case LLVM::ICmpPredicate::sgt:
    case LLVM::ICmpPredicate::sge:
      return std::nullopt;
    }
  }

  return std::nullopt;
}

LogicalResult
KnownBitsAnalysis::visitOperation(Operation *op,
                                  ArrayRef<const KnownBitsLattice *> operands,
                                  ArrayRef<KnownBitsLattice *> results) {
  // Raising a result to top says "this operation could produce anything",
  // which is always a sound answer and is what every unhandled case does.
  auto unknown = [&] {
    setAllToEntryStates(results);
    return success();
  };

  // Only single-result scalar integer operations are interesting here.  Calls,
  // loads, floats, pointers, and vectors all land in `unknown`.
  if (op->getNumResults() != 1)
    return unknown();
  auto resultType = dyn_cast<IntegerType>(op->getResult(0).getType());
  if (!resultType)
    return unknown();
  KnownBitsLattice *result = results[0];

  // A constant has every bit known.  This is the only rule that does not
  // consult its operands, and the source of every fact the others propagate.
  // (llvm.mlir.undef and llvm.mlir.poison do not match, and stay unknown.)
  IntegerAttr value;
  if (matchPattern(op, m_Constant(&value))) {
    propagateIfChanged(result,
                       result->join(Bits::constant(value.getValue())));
    return success();
  }

  // Bottom means the solver has not yet proved anything reaches an operand.
  // Leaving the result alone keeps the analysis optimistic; the solver will
  // call back here once the operand moves up the lattice.
  for (const KnownBitsLattice *operand : operands)
    if (operand->getValue().isBottom())
      return success();

  auto in = [&](unsigned i) {
    unsigned width = cast<IntegerType>(op->getOperand(i).getType()).getWidth();
    return operands[i]->getValue().bits(width);
  };
  std::optional<Bits> bits = transfer(op, resultType.getWidth(), in);
  if (!bits)
    return unknown();

  propagateIfChanged(result, result->join(*bits));
  return success();
}

} // namespace knownbits
