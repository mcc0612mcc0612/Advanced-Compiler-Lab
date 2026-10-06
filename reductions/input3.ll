; Range propagation: the mask proves an unsigned comparison true, so select
; picks the constant true arm.

define i8 @keep_select(i8 %x, i8 %y) {
entry:
  %noise1 = sub i8 %y, 11
  %masked = and i8 %x, 7
  %cmp = icmp ult i8 %masked, 8
  %chosen = select i1 %cmp, i8 42, i8 -1
  %noise2 = xor i8 %noise1, -86
  ret i8 %chosen
}
