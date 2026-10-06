; Bitwise propagation: and makes high bits zero, or forces bit 6 one.

define i8 @keep_bitwise(i8 %x, i8 %y) {
entry:
  %noise1 = add i8 %y, 13
  %noise2 = xor i8 %noise1, -1
  %masked = and i8 %x, 15
  %forced = or i8 %masked, 64
  %noise3 = mul i8 %noise2, 3
  ret i8 %forced
}
