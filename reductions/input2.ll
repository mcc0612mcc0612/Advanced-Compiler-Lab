; Shift propagation: masked low byte is shifted left, then logically right.

define i32 @keep_shift(i32 %x, i32 %y) {
entry:
  %noise1 = xor i32 %y, 12345
  %masked = and i32 %x, 255
  %left = shl i32 %masked, 8
  %right = lshr i32 %left, 4
  %noise2 = add i32 %noise1, 99
  ret i32 %right
}
