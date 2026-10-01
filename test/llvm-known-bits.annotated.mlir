module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, i64 = dense<[32, 64]> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little">, llvm.module_asm = [], llvm.target_triple = ""} {
  llvm.func @test_shl(%arg0: i1) {
    %0 = llvm.mlir.constant(64 : i8) : i8 // %0 is 01000000
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.zext %arg0 : i1 to i8 // %2 is 0000000?
    %3 = llvm.shl %0, %2 : i8 // %3 is ??000000
    %4 = llvm.and %3, %1 : i8 // %4 is 00000000
    llvm.call @sink(%4) : (i8) -> ()
    llvm.return
  }
  llvm.func @test_lshr(%arg0: i1) {
    %0 = llvm.mlir.constant(64 : i8) : i8 // %0 is 01000000
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.zext %arg0 : i1 to i8 // %2 is 0000000?
    %3 = llvm.lshr %0, %2 : i8 // %3 is 0??00000
    %4 = llvm.and %3, %1 : i8 // %4 is 00000000
    llvm.call @sink(%4) : (i8) -> ()
    llvm.return
  }
  llvm.func @test_ashr(%arg0: i1) {
    %0 = llvm.mlir.constant(-16 : i8) : i8 // %0 is 11110000
    %1 = llvm.mlir.constant(3 : i8) : i8 // %1 is 00000011
    %2 = llvm.zext %arg0 : i1 to i8 // %2 is 0000000?
    %3 = llvm.ashr %0, %2 : i8 // %3 is 1111?000
    %4 = llvm.and %3, %1 : i8 // %4 is 00000000
    llvm.call @sink(%4) : (i8) -> ()
    llvm.return
  }
  llvm.func @test_udiv(%arg0: i8) {
    %0 = llvm.mlir.constant(10 : i8) : i8 // %0 is 00001010
    %1 = llvm.mlir.constant(64 : i8) : i8 // %1 is 01000000
    %2 = llvm.udiv %0, %arg0 : i8
    %3 = llvm.and %2, %1 : i8 // %3 is 0?000000
    llvm.call @sink(%3) : (i8) -> ()
    llvm.return
  }
  llvm.func @test_cond(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.mlir.constant(-4 : i8) : i8 // %2 is 11111100
    %3 = llvm.and %arg0, %0 : i8 // %3 is 000000??
    %4 = llvm.icmp "eq" %3, %1 : i8
    llvm.cond_br %4, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %5 = llvm.or %arg0, %2 : i8 // %5 is 111111??
    llvm.return %5 : i8
  ^bb2:  // pred: ^bb0
    %6 = llvm.or %arg0, %2 : i8 // %6 is 111111??
    llvm.return %6 : i8
  }
  llvm.func @test_cond_inv(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.mlir.constant(-4 : i8) : i8 // %2 is 11111100
    %3 = llvm.and %arg0, %0 : i8 // %3 is 000000??
    %4 = llvm.icmp "ne" %3, %1 : i8
    llvm.call @use(%4) : (i1) -> ()
    llvm.cond_br %4, ^bb2, ^bb1
  ^bb1:  // pred: ^bb0
    %5 = llvm.or %arg0, %2 : i8 // %5 is 111111??
    llvm.return %5 : i8
  ^bb2:  // pred: ^bb0
    %6 = llvm.or %arg0, %2 : i8 // %6 is 111111??
    llvm.return %6 : i8
  }
  llvm.func @test_cond_and(%arg0: i8, %arg1: i1) -> i8 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.mlir.constant(-4 : i8) : i8 // %2 is 11111100
    %3 = llvm.and %arg0, %0 : i8 // %3 is 000000??
    %4 = llvm.icmp "eq" %3, %1 : i8
    %5 = llvm.and %4, %arg1 : i1
    llvm.cond_br %5, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %6 = llvm.or %arg0, %2 : i8 // %6 is 111111??
    llvm.return %6 : i8
  ^bb2:  // pred: ^bb0
    %7 = llvm.or %arg0, %2 : i8 // %7 is 111111??
    llvm.return %7 : i8
  }
  llvm.func @test_cond_and_bothways(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(91 : i8) : i8 // %0 is 01011011
    %1 = llvm.mlir.constant(24 : i8) : i8 // %1 is 00011000
    %2 = llvm.mlir.constant(0 : i8) : i8 // %2 is 00000000
    %3 = llvm.mlir.constant(-4 : i8) : i8 // %3 is 11111100
    %4 = llvm.and %arg0, %0 : i8 // %4 is 0?0??0??
    %5 = llvm.icmp "ne" %4, %1 : i8
    %6 = llvm.icmp "ne" %arg0, %2 : i8
    %7 = llvm.and %5, %6 : i1
    llvm.cond_br %7, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %8 = llvm.or %arg0, %3 : i8 // %8 is 111111??
    llvm.return %8 : i8
  ^bb2:  // pred: ^bb0
    %9 = llvm.or %arg0, %3 : i8 // %9 is 111111??
    llvm.return %9 : i8
  }
  llvm.func @test_cond_or_bothways(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(91 : i8) : i8 // %0 is 01011011
    %1 = llvm.mlir.constant(24 : i8) : i8 // %1 is 00011000
    %2 = llvm.mlir.constant(0 : i8) : i8 // %2 is 00000000
    %3 = llvm.mlir.constant(-4 : i8) : i8 // %3 is 11111100
    %4 = llvm.and %arg0, %0 : i8 // %4 is 0?0??0??
    %5 = llvm.icmp "eq" %4, %1 : i8
    %6 = llvm.icmp "eq" %arg0, %2 : i8
    %7 = llvm.or %5, %6 : i1
    llvm.cond_br %7, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %8 = llvm.or %arg0, %3 : i8 // %8 is 111111??
    llvm.return %8 : i8
  ^bb2:  // pred: ^bb0
    %9 = llvm.or %arg0, %3 : i8 // %9 is 111111??
    llvm.return %9 : i8
  }
  llvm.func @test_cond_and_commuted(%arg0: i8, %arg1: i1, %arg2: i1) -> i8 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.mlir.constant(-4 : i8) : i8 // %2 is 11111100
    %3 = llvm.and %arg0, %0 : i8 // %3 is 000000??
    %4 = llvm.icmp "eq" %3, %1 : i8
    %5 = llvm.and %arg1, %arg2 : i1
    %6 = llvm.and %5, %4 : i1
    llvm.cond_br %6, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %7 = llvm.or %arg0, %2 : i8 // %7 is 111111??
    llvm.return %7 : i8
  ^bb2:  // pred: ^bb0
    %8 = llvm.or %arg0, %2 : i8 // %8 is 111111??
    llvm.return %8 : i8
  }
  llvm.func @test_cond_logical_and(%arg0: i8, %arg1: i1) -> i8 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.mlir.constant(false) : i1 // %2 is 0
    %3 = llvm.mlir.constant(-4 : i8) : i8 // %3 is 11111100
    %4 = llvm.and %arg0, %0 : i8 // %4 is 000000??
    %5 = llvm.icmp "eq" %4, %1 : i8
    %6 = llvm.select %5, %arg1, %2 : i1, i1
    llvm.cond_br %6, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %7 = llvm.or %arg0, %3 : i8 // %7 is 111111??
    llvm.return %7 : i8
  ^bb2:  // pred: ^bb0
    %8 = llvm.or %arg0, %3 : i8 // %8 is 111111??
    llvm.return %8 : i8
  }
  llvm.func @test_cond_or_invalid(%arg0: i8, %arg1: i1) -> i8 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.mlir.constant(-4 : i8) : i8 // %2 is 11111100
    %3 = llvm.and %arg0, %0 : i8 // %3 is 000000??
    %4 = llvm.icmp "eq" %3, %1 : i8
    %5 = llvm.or %4, %arg1 : i1
    llvm.cond_br %5, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %6 = llvm.or %arg0, %2 : i8 // %6 is 111111??
    llvm.return %6 : i8
  ^bb2:  // pred: ^bb0
    %7 = llvm.or %arg0, %2 : i8 // %7 is 111111??
    llvm.return %7 : i8
  }
  llvm.func @test_cond_inv_or(%arg0: i8, %arg1: i1) -> i8 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.mlir.constant(-4 : i8) : i8 // %2 is 11111100
    %3 = llvm.and %arg0, %0 : i8 // %3 is 000000??
    %4 = llvm.icmp "ne" %3, %1 : i8
    %5 = llvm.or %4, %arg1 : i1
    llvm.cond_br %5, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %6 = llvm.or %arg0, %2 : i8 // %6 is 111111??
    llvm.return %6 : i8
  ^bb2:  // pred: ^bb0
    %7 = llvm.or %arg0, %2 : i8 // %7 is 111111??
    llvm.return %7 : i8
  }
  llvm.func @test_cond_inv_logical_or(%arg0: i8, %arg1: i1) -> i8 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.mlir.constant(false) : i1 // %2 is 0
    %3 = llvm.mlir.constant(-4 : i8) : i8 // %3 is 11111100
    %4 = llvm.and %arg0, %0 : i8 // %4 is 000000??
    %5 = llvm.icmp "ne" %4, %1 : i8
    %6 = llvm.select %5, %2, %arg1 : i1, i1
    llvm.cond_br %6, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %7 = llvm.or %arg0, %3 : i8 // %7 is 111111??
    llvm.return %7 : i8
  ^bb2:  // pred: ^bb0
    %8 = llvm.or %arg0, %3 : i8 // %8 is 111111??
    llvm.return %8 : i8
  }
  llvm.func @test_cond_inv_and_invalid(%arg0: i8, %arg1: i1) -> i8 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.mlir.constant(-4 : i8) : i8 // %2 is 11111100
    %3 = llvm.and %arg0, %0 : i8 // %3 is 000000??
    %4 = llvm.icmp "ne" %3, %1 : i8
    %5 = llvm.and %4, %arg1 : i1
    llvm.cond_br %5, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %6 = llvm.or %arg0, %2 : i8 // %6 is 111111??
    llvm.return %6 : i8
  ^bb2:  // pred: ^bb0
    %7 = llvm.or %arg0, %2 : i8 // %7 is 111111??
    llvm.return %7 : i8
  }
  llvm.func @test_icmp_trunc1(%arg0: i32) -> i32 {
    %0 = llvm.mlir.constant(7 : i16) : i16 // %0 is 0000000000000111
    %1 = llvm.mlir.constant(0 : i32) : i32 // %1 is 00000000000000000000000000000000
    %2 = llvm.mlir.constant(15 : i32) : i32 // %2 is 00000000000000000000000000001111
    %3 = llvm.trunc %arg0 : i32 to i16
    %4 = llvm.icmp "eq" %3, %0 : i16
    llvm.cond_br %4, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %5 = llvm.and %arg0, %2 : i32 // %5 is 0000000000000000000000000000????
    llvm.return %5 : i32
  ^bb2:  // pred: ^bb0
    llvm.return %1 : i32
  }
  llvm.func @test_icmp_trunc_assume(%arg0: i32) -> i32 {
    %0 = llvm.mlir.constant(7 : i16) : i16 // %0 is 0000000000000111
    %1 = llvm.mlir.constant(15 : i32) : i32 // %1 is 00000000000000000000000000001111
    %2 = llvm.trunc %arg0 : i32 to i16
    %3 = llvm.icmp "eq" %2, %0 : i16
    llvm.intr.assume %3 : i1
    %4 = llvm.and %arg0, %1 : i32 // %4 is 0000000000000000000000000000????
    llvm.return %4 : i32
  }
  llvm.func @test_icmp_trunc2(%arg0: i64) -> i64 {
    %0 = llvm.mlir.constant(12 : i32) : i32 // %0 is 00000000000000000000000000001100
    %1 = llvm.mlir.constant(0 : i64) : i64 // %1 is 0000000000000000000000000000000000000000000000000000000000000000
    %2 = llvm.mlir.constant(32 : i64) : i64 // %2 is 0000000000000000000000000000000000000000000000000000000000100000
    %3 = llvm.trunc %arg0 : i64 to i32
    %4 = llvm.icmp "sgt" %3, %0 : i32
    llvm.cond_br %4, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %5 = llvm.shl %arg0, %2 : i64 // %5 is ????????????????????????????????00000000000000000000000000000000
    %6 = llvm.ashr exact %5, %2 : i64
    llvm.return %6 : i64
  ^bb2:  // pred: ^bb0
    llvm.return %1 : i64
  }
  llvm.func @test_icmp_trunc3(%arg0: i64) -> i64 {
    %0 = llvm.mlir.constant(96 : i32) : i32 // %0 is 00000000000000000000000001100000
    %1 = llvm.mlir.constant(0 : i64) : i64 // %1 is 0000000000000000000000000000000000000000000000000000000000000000
    %2 = llvm.mlir.constant(4294967295 : i64) : i64 // %2 is 0000000000000000000000000000000011111111111111111111111111111111
    %3 = llvm.trunc %arg0 : i64 to i32
    %4 = llvm.icmp "ult" %3, %0 : i32
    llvm.cond_br %4, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %5 = llvm.and %arg0, %2 : i64 // %5 is 00000000000000000000000000000000????????????????????????????????
    llvm.return %5 : i64
  ^bb2:  // pred: ^bb0
    llvm.return %1 : i64
  }
  llvm.func @test_icmp_trunc4(%arg0: i64) -> i8 {
    %0 = llvm.mlir.constant(10 : i32) : i32 // %0 is 00000000000000000000000000001010
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.mlir.constant(48 : i8) : i8 // %2 is 00110000
    %3 = llvm.trunc %arg0 : i64 to i32
    %4 = llvm.icmp "ult" %3, %0 : i32
    llvm.cond_br %4, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %5 = llvm.trunc %arg0 : i64 to i8
    %6 = llvm.add %5, %2 : i8
    llvm.return %6 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %1 : i8
  }
  llvm.func @test_icmp_trunc5(%arg0: i64) -> i64 {
    %0 = llvm.mlir.constant(47 : i64) : i64 // %0 is 0000000000000000000000000000000000000000000000000000000000101111
    %1 = llvm.mlir.constant(-13 : i32) : i32 // %1 is 11111111111111111111111111110011
    %2 = llvm.mlir.constant(13 : i64) : i64 // %2 is 0000000000000000000000000000000000000000000000000000000000001101
    %3 = llvm.mlir.constant(4294967295 : i64) : i64 // %3 is 0000000000000000000000000000000011111111111111111111111111111111
    %4 = llvm.ashr %arg0, %0 : i64
    %5 = llvm.trunc %4 : i64 to i32
    %6 = llvm.icmp "ugt" %5, %1 : i32
    llvm.cond_br %6, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %7 = llvm.and %4, %3 : i64 // %7 is 00000000000000000000000000000000????????????????????????????????
    %8 = llvm.xor %7, %3 : i64 // %8 is 00000000000000000000000000000000????????????????????????????????
    llvm.return %8 : i64
  ^bb2:  // pred: ^bb0
    llvm.return %2 : i64
  }
  llvm.func @test_icmp_trunc_nuw(%arg0: i64) -> i64 {
    %0 = llvm.mlir.constant(0 : i32) : i32 // %0 is 00000000000000000000000000000000
    %1 = llvm.mlir.constant(0 : i64) : i64 // %1 is 0000000000000000000000000000000000000000000000000000000000000000
    %2 = llvm.mlir.constant(2147483647 : i64) : i64 // %2 is 0000000000000000000000000000000001111111111111111111111111111111
    %3 = llvm.trunc %arg0 overflow<nuw> : i64 to i32
    %4 = llvm.icmp "sgt" %3, %0 : i32
    llvm.cond_br %4, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %5 = llvm.and %arg0, %2 : i64 // %5 is 000000000000000000000000000000000???????????????????????????????
    llvm.return %5 : i64
  ^bb2:  // pred: ^bb0
    llvm.return %1 : i64
  }
  llvm.func @test_icmp_trunc_no_nuw(%arg0: i64) -> i64 {
    %0 = llvm.mlir.constant(0 : i32) : i32 // %0 is 00000000000000000000000000000000
    %1 = llvm.mlir.constant(0 : i64) : i64 // %1 is 0000000000000000000000000000000000000000000000000000000000000000
    %2 = llvm.mlir.constant(2147483647 : i64) : i64 // %2 is 0000000000000000000000000000000001111111111111111111111111111111
    %3 = llvm.trunc %arg0 : i64 to i32
    %4 = llvm.icmp "sgt" %3, %0 : i32
    llvm.cond_br %4, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %5 = llvm.and %arg0, %2 : i64 // %5 is 000000000000000000000000000000000???????????????????????????????
    llvm.return %5 : i64
  ^bb2:  // pred: ^bb0
    llvm.return %1 : i64
  }
  llvm.func @test_icmp_or_distjoint(%arg0: i8, %arg1: i1) -> i1 {
    %0 = llvm.mlir.constant(16 : i8) : i8 // %0 is 00010000
    %1 = llvm.mlir.constant(-111 : i8) : i8 // %1 is 10010001
    %2 = llvm.mlir.constant(0 : i8) : i8 // %2 is 00000000
    %3 = llvm.or disjoint %arg0, %0 : i8 // %3 is ???1????
    %4 = llvm.icmp "ugt" %3, %1 : i8
    llvm.cond_br %4, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %5 = llvm.icmp "slt" %arg0, %2 : i8
    llvm.return %5 : i1
  ^bb2:  // pred: ^bb0
    llvm.return %arg1 : i1
  }
  llvm.func @test_icmp_or_fail_missing_disjoint(%arg0: i8, %arg1: i1) -> i1 {
    %0 = llvm.mlir.constant(16 : i8) : i8 // %0 is 00010000
    %1 = llvm.mlir.constant(-111 : i8) : i8 // %1 is 10010001
    %2 = llvm.mlir.constant(0 : i8) : i8 // %2 is 00000000
    %3 = llvm.or %arg0, %0 : i8 // %3 is ???1????
    %4 = llvm.icmp "ugt" %3, %1 : i8
    llvm.cond_br %4, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %5 = llvm.icmp "slt" %arg0, %2 : i8
    llvm.return %5 : i1
  ^bb2:  // pred: ^bb0
    llvm.return %arg1 : i1
  }
  llvm.func @and_eq_bits_must_be_set(%arg0: i8, %arg1: i8) -> i8 {
    %0 = llvm.mlir.constant(123 : i8) : i8 // %0 is 01111011
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.and %arg0, %arg1 : i8
    %3 = llvm.icmp "eq" %2, %0 : i8
    llvm.intr.assume %3 : i1
    %4 = llvm.and %arg0, %1 : i8 // %4 is 0000000?
    llvm.return %4 : i8
  }
  llvm.func @test_icmp_or(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(32 : i8) : i8 // %0 is 00100000
    %1 = llvm.or %arg0, %arg1 : i8
    %2 = llvm.icmp "ult" %1, %0 : i8
    llvm.cond_br %2, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %3 = llvm.and %arg0, %0 : i8 // %3 is 00?00000
    llvm.return %3 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_or2(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(15 : i8) : i8 // %0 is 00001111
    %1 = llvm.mlir.constant(32 : i8) : i8 // %1 is 00100000
    %2 = llvm.or %arg0, %arg1 : i8
    %3 = llvm.icmp "uge" %2, %0 : i8
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    llvm.return %arg2 : i8
  ^bb2:  // pred: ^bb0
    %4 = llvm.and %arg0, %1 : i8 // %4 is 00?00000
    llvm.return %4 : i8
  }
  llvm.func @test_icmp_or_fail_bad_range(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(32 : i8) : i8 // %0 is 00100000
    %1 = llvm.or %arg0, %arg1 : i8
    %2 = llvm.icmp "ule" %1, %0 : i8
    llvm.cond_br %2, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %3 = llvm.and %arg0, %0 : i8 // %3 is 00?00000
    llvm.return %3 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_or_fail_bad_pred(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(32 : i8) : i8 // %0 is 00100000
    %1 = llvm.or %arg0, %arg1 : i8
    %2 = llvm.icmp "ugt" %1, %0 : i8
    llvm.cond_br %2, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %3 = llvm.and %arg0, %0 : i8 // %3 is 00?00000
    llvm.return %3 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_and(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(-33 : i8) : i8 // %0 is 11011111
    %1 = llvm.mlir.constant(32 : i8) : i8 // %1 is 00100000
    %2 = llvm.and %arg0, %arg1 : i8
    %3 = llvm.icmp "ugt" %2, %0 : i8
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %4 = llvm.and %arg0, %1 : i8 // %4 is 00?00000
    llvm.return %4 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_and2(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(-32 : i8) : i8 // %0 is 11100000
    %1 = llvm.mlir.constant(32 : i8) : i8 // %1 is 00100000
    %2 = llvm.and %arg0, %arg1 : i8
    %3 = llvm.icmp "ule" %2, %0 : i8
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    llvm.return %arg2 : i8
  ^bb2:  // pred: ^bb0
    %4 = llvm.and %arg0, %1 : i8 // %4 is 00?00000
    llvm.return %4 : i8
  }
  llvm.func @test_icmp_and_fail_bad_range(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(-33 : i8) : i8 // %0 is 11011111
    %1 = llvm.mlir.constant(32 : i8) : i8 // %1 is 00100000
    %2 = llvm.and %arg0, %arg1 : i8
    %3 = llvm.icmp "uge" %2, %0 : i8
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %4 = llvm.and %arg0, %1 : i8 // %4 is 00?00000
    llvm.return %4 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_and_fail_bad_pred(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(32 : i8) : i8 // %0 is 00100000
    %1 = llvm.and %arg0, %arg1 : i8
    %2 = llvm.icmp "sge" %1, %0 : i8
    llvm.cond_br %2, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %3 = llvm.and %arg0, %0 : i8 // %3 is 00?00000
    llvm.return %3 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @and_eq_bits_must_be_set2(%arg0: i8, %arg1: i8) -> i8 {
    %0 = llvm.mlir.constant(123 : i8) : i8 // %0 is 01111011
    %1 = llvm.mlir.constant(11 : i8) : i8 // %1 is 00001011
    %2 = llvm.and %arg0, %arg1 : i8
    %3 = llvm.icmp "eq" %2, %0 : i8
    llvm.intr.assume %3 : i1
    %4 = llvm.and %arg1, %1 : i8 // %4 is 0000?0??
    llvm.return %4 : i8
  }
  llvm.func @and_eq_bits_must_be_set2_partial_fail(%arg0: i8, %arg1: i8) -> i8 {
    %0 = llvm.mlir.constant(123 : i8) : i8 // %0 is 01111011
    %1 = llvm.mlir.constant(111 : i8) : i8 // %1 is 01101111
    %2 = llvm.and %arg0, %arg1 : i8
    %3 = llvm.icmp "eq" %2, %0 : i8
    llvm.intr.assume %3 : i1
    %4 = llvm.and %arg1, %1 : i8 // %4 is 0??0????
    llvm.return %4 : i8
  }
  llvm.func @or_eq_bits_must_be_unset(%arg0: i8, %arg1: i8) -> i8 {
    %0 = llvm.mlir.constant(124 : i8) : i8 // %0 is 01111100
    %1 = llvm.mlir.constant(3 : i8) : i8 // %1 is 00000011
    %2 = llvm.or %arg0, %arg1 : i8
    %3 = llvm.icmp "eq" %2, %0 : i8
    llvm.intr.assume %3 : i1
    %4 = llvm.and %arg0, %1 : i8 // %4 is 000000??
    llvm.return %4 : i8
  }
  llvm.func @or_eq_bits_must_be_unset2(%arg0: i8, %arg1: i8) -> i8 {
    %0 = llvm.mlir.constant(124 : i8) : i8 // %0 is 01111100
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.or %arg0, %arg1 : i8
    %3 = llvm.icmp "eq" %2, %0 : i8
    llvm.intr.assume %3 : i1
    %4 = llvm.and %arg1, %1 : i8 // %4 is 0000000?
    llvm.return %4 : i8
  }
  llvm.func @or_eq_bits_must_be_unset2_partial_fail(%arg0: i8, %arg1: i8) -> i8 {
    %0 = llvm.mlir.constant(124 : i8) : i8 // %0 is 01111100
    %1 = llvm.mlir.constant(7 : i8) : i8 // %1 is 00000111
    %2 = llvm.or %arg0, %arg1 : i8
    %3 = llvm.icmp "eq" %2, %0 : i8
    llvm.intr.assume %3 : i1
    %4 = llvm.and %arg1, %1 : i8 // %4 is 00000???
    llvm.return %4 : i8
  }
  llvm.func @or_ne_bits_must_be_unset2_fail(%arg0: i8, %arg1: i8) -> i8 {
    %0 = llvm.mlir.constant(124 : i8) : i8 // %0 is 01111100
    %1 = llvm.mlir.constant(3 : i8) : i8 // %1 is 00000011
    %2 = llvm.or %arg0, %arg1 : i8
    %3 = llvm.icmp "ne" %2, %0 : i8
    llvm.intr.assume %3 : i1
    %4 = llvm.and %arg0, %1 : i8 // %4 is 000000??
    llvm.return %4 : i8
  }
  llvm.func @use.i1(i1)
  llvm.func @use.i8(i8)
  llvm.func @use.2xi1(vector<2xi1>)
  llvm.func @extract_value_uadd(%arg0: vector<2xi8>, %arg1: vector<2xi8>) -> i1 {
    %0 = llvm.mlir.constant(dense<[63, -1]> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(dense<[1, 0]> : vector<2xi8>) : vector<2xi8>
    %2 = llvm.mlir.constant(0 : i32) : i32 // %2 is 00000000000000000000000000000000
    %3 = llvm.mlir.constant(0 : i8) : i8 // %3 is 00000000
    %4 = llvm.and %arg0, %0 : vector<2xi8>
    %5 = llvm.and %arg1, %0 : vector<2xi8>
    %6 = llvm.add %4, %1 overflow<nuw> : vector<2xi8>
    %7 = llvm.add %5, %1 overflow<nuw> : vector<2xi8>
    %8 = "llvm.intr.uadd.with.overflow"(%6, %7) : (vector<2xi8>, vector<2xi8>) -> !llvm.struct<(vector<2xi8>, vector<2xi1>)>
    %9 = llvm.extractvalue %8[0] : !llvm.struct<(vector<2xi8>, vector<2xi1>)> 
    %10 = llvm.extractvalue %8[1] : !llvm.struct<(vector<2xi8>, vector<2xi1>)> 
    llvm.call @use.2xi1(%10) : (vector<2xi1>) -> ()
    %11 = llvm.extractelement %9[%2 : i32] : vector<2xi8>
    %12 = llvm.icmp "eq" %11, %3 : i8
    llvm.return %12 : i1
  }
  llvm.func @extract_value_uadd2(%arg0: vector<2xi8>, %arg1: vector<2xi8>) -> i1 {
    %0 = llvm.mlir.constant(dense<[-1, 63]> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(dense<[0, 1]> : vector<2xi8>) : vector<2xi8>
    %2 = llvm.mlir.constant(1 : i32) : i32 // %2 is 00000000000000000000000000000001
    %3 = llvm.mlir.constant(0 : i8) : i8 // %3 is 00000000
    %4 = llvm.and %arg0, %0 : vector<2xi8>
    %5 = llvm.and %arg1, %0 : vector<2xi8>
    %6 = llvm.add %4, %1 overflow<nuw> : vector<2xi8>
    %7 = llvm.add %5, %1 overflow<nuw> : vector<2xi8>
    %8 = "llvm.intr.uadd.with.overflow"(%6, %7) : (vector<2xi8>, vector<2xi8>) -> !llvm.struct<(vector<2xi8>, vector<2xi1>)>
    %9 = llvm.extractvalue %8[0] : !llvm.struct<(vector<2xi8>, vector<2xi1>)> 
    %10 = llvm.extractvalue %8[1] : !llvm.struct<(vector<2xi8>, vector<2xi1>)> 
    llvm.call @use.2xi1(%10) : (vector<2xi1>) -> ()
    %11 = llvm.extractelement %9[%2 : i32] : vector<2xi8>
    %12 = llvm.icmp "eq" %11, %3 : i8
    llvm.return %12 : i1
  }
  llvm.func @extract_value_uadd_fail(%arg0: vector<2xi8>, %arg1: vector<2xi8>) -> i1 {
    %0 = llvm.mlir.constant(dense<[63, -1]> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(dense<[1, 0]> : vector<2xi8>) : vector<2xi8>
    %2 = llvm.mlir.constant(1 : i32) : i32 // %2 is 00000000000000000000000000000001
    %3 = llvm.mlir.constant(0 : i8) : i8 // %3 is 00000000
    %4 = llvm.and %arg0, %0 : vector<2xi8>
    %5 = llvm.and %arg1, %0 : vector<2xi8>
    %6 = llvm.add %4, %1 overflow<nuw> : vector<2xi8>
    %7 = llvm.add %5, %1 overflow<nuw> : vector<2xi8>
    %8 = "llvm.intr.uadd.with.overflow"(%6, %7) : (vector<2xi8>, vector<2xi8>) -> !llvm.struct<(vector<2xi8>, vector<2xi1>)>
    %9 = llvm.extractvalue %8[0] : !llvm.struct<(vector<2xi8>, vector<2xi1>)> 
    %10 = llvm.extractvalue %8[1] : !llvm.struct<(vector<2xi8>, vector<2xi1>)> 
    llvm.call @use.2xi1(%10) : (vector<2xi1>) -> ()
    %11 = llvm.extractelement %9[%2 : i32] : vector<2xi8>
    %12 = llvm.icmp "eq" %11, %3 : i8
    llvm.return %12 : i1
  }
  llvm.func @extract_value_uadd_fail2(%arg0: vector<2xi8>, %arg1: vector<2xi8>, %arg2: i32) -> i1 {
    %0 = llvm.mlir.constant(dense<[63, -1]> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(dense<[1, 0]> : vector<2xi8>) : vector<2xi8>
    %2 = llvm.mlir.constant(0 : i8) : i8 // %2 is 00000000
    %3 = llvm.and %arg0, %0 : vector<2xi8>
    %4 = llvm.and %arg1, %0 : vector<2xi8>
    %5 = llvm.add %3, %1 overflow<nuw> : vector<2xi8>
    %6 = llvm.add %4, %1 overflow<nuw> : vector<2xi8>
    %7 = "llvm.intr.uadd.with.overflow"(%5, %6) : (vector<2xi8>, vector<2xi8>) -> !llvm.struct<(vector<2xi8>, vector<2xi1>)>
    %8 = llvm.extractvalue %7[0] : !llvm.struct<(vector<2xi8>, vector<2xi1>)> 
    %9 = llvm.extractvalue %7[1] : !llvm.struct<(vector<2xi8>, vector<2xi1>)> 
    llvm.call @use.2xi1(%9) : (vector<2xi1>) -> ()
    %10 = llvm.extractelement %8[%arg2 : i32] : vector<2xi8>
    %11 = llvm.icmp "eq" %10, %2 : i8
    llvm.return %11 : i1
  }
  llvm.func @extract_value_uadd_fail3(%arg0: vector<2xi8>, %arg1: vector<2xi8>) -> i1 {
    %0 = llvm.mlir.constant(dense<127> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(dense<1> : vector<2xi8>) : vector<2xi8>
    %2 = llvm.mlir.constant(0 : i32) : i32 // %2 is 00000000000000000000000000000000
    %3 = llvm.mlir.constant(0 : i8) : i8 // %3 is 00000000
    %4 = llvm.and %arg0, %0 : vector<2xi8>
    %5 = llvm.and %arg1, %0 : vector<2xi8>
    %6 = llvm.add %4, %1 overflow<nuw> : vector<2xi8>
    %7 = llvm.add %5, %1 overflow<nuw> : vector<2xi8>
    %8 = "llvm.intr.uadd.with.overflow"(%6, %7) : (vector<2xi8>, vector<2xi8>) -> !llvm.struct<(vector<2xi8>, vector<2xi1>)>
    %9 = llvm.extractvalue %8[0] : !llvm.struct<(vector<2xi8>, vector<2xi1>)> 
    %10 = llvm.extractvalue %8[1] : !llvm.struct<(vector<2xi8>, vector<2xi1>)> 
    llvm.call @use.2xi1(%10) : (vector<2xi1>) -> ()
    %11 = llvm.extractelement %9[%2 : i32] : vector<2xi8>
    %12 = llvm.icmp "eq" %11, %3 : i8
    llvm.return %12 : i1
  }
  llvm.func @extract_value_sadd(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(1 : i8) : i8 // %0 is 00000001
    %1 = llvm.mlir.constant(-128 : i8) : i8 // %1 is 10000000
    %2 = llvm.mlir.constant(0 : i8) : i8 // %2 is 00000000
    %3 = llvm.add %arg0, %0 overflow<nuw> : i8
    %4 = llvm.add %arg1, %0 overflow<nuw> : i8
    %5 = llvm.icmp "ult" %3, %1 : i8
    %6 = llvm.icmp "ult" %4, %1 : i8
    llvm.intr.assume %5 : i1
    llvm.intr.assume %6 : i1
    %7 = "llvm.intr.sadd.with.overflow"(%3, %4) : (i8, i8) -> !llvm.struct<(i8, i1)>
    %8 = llvm.extractvalue %7[0] : !llvm.struct<(i8, i1)> 
    %9 = llvm.extractvalue %7[1] : !llvm.struct<(i8, i1)> 
    llvm.call @use.i1(%9) : (i1) -> ()
    %10 = llvm.icmp "eq" %8, %2 : i8
    llvm.return %10 : i1
  }
  llvm.func @extract_value_sadd_fail(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(1 : i8) : i8 // %0 is 00000001
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.add %arg0, %0 : i8
    %3 = llvm.add %arg1, %0 : i8
    %4 = "llvm.intr.sadd.with.overflow"(%2, %3) : (i8, i8) -> !llvm.struct<(i8, i1)>
    %5 = llvm.extractvalue %4[0] : !llvm.struct<(i8, i1)> 
    %6 = llvm.extractvalue %4[1] : !llvm.struct<(i8, i1)> 
    llvm.call @use.i1(%6) : (i1) -> ()
    %7 = llvm.icmp "eq" %5, %1 : i8
    llvm.return %7 : i1
  }
  llvm.func @extract_value_usub(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(1 : i8) : i8 // %0 is 00000001
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.add %arg1, %0 overflow<nuw> : i8
    %3 = llvm.add %arg0, %2 : i8
    %4 = "llvm.intr.usub.with.overflow"(%arg0, %3) : (i8, i8) -> !llvm.struct<(i8, i1)>
    %5 = llvm.extractvalue %4[0] : !llvm.struct<(i8, i1)> 
    %6 = llvm.extractvalue %4[1] : !llvm.struct<(i8, i1)> 
    llvm.call @use.i1(%6) : (i1) -> ()
    llvm.call @use.i8(%5) : (i8) -> ()
    %7 = llvm.icmp "eq" %5, %1 : i8
    llvm.return %7 : i1
  }
  llvm.func @extract_value_usub_fail(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(0 : i8) : i8 // %0 is 00000000
    %1 = llvm.add %arg0, %arg1 : i8
    %2 = "llvm.intr.usub.with.overflow"(%arg0, %1) : (i8, i8) -> !llvm.struct<(i8, i1)>
    %3 = llvm.extractvalue %2[0] : !llvm.struct<(i8, i1)> 
    %4 = llvm.extractvalue %2[1] : !llvm.struct<(i8, i1)> 
    llvm.call @use.i1(%4) : (i1) -> ()
    llvm.call @use.i8(%3) : (i8) -> ()
    %5 = llvm.icmp "eq" %3, %0 : i8
    llvm.return %5 : i1
  }
  llvm.func @extract_value_ssub(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(1 : i8) : i8 // %0 is 00000001
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.add %arg1, %0 overflow<nuw> : i8
    %3 = llvm.add %arg0, %2 : i8
    %4 = "llvm.intr.ssub.with.overflow"(%3, %arg0) : (i8, i8) -> !llvm.struct<(i8, i1)>
    %5 = llvm.extractvalue %4[0] : !llvm.struct<(i8, i1)> 
    %6 = llvm.extractvalue %4[1] : !llvm.struct<(i8, i1)> 
    llvm.call @use.i1(%6) : (i1) -> ()
    llvm.call @use.i8(%5) : (i8) -> ()
    %7 = llvm.icmp "eq" %5, %1 : i8
    llvm.return %7 : i1
  }
  llvm.func @extract_value_ssub_fail(%arg0: i8) -> i1 {
    %0 = llvm.mlir.constant(10 : i8) : i8 // %0 is 00001010
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = "llvm.intr.ssub.with.overflow"(%0, %arg0) : (i8, i8) -> !llvm.struct<(i8, i1)>
    %3 = llvm.extractvalue %2[0] : !llvm.struct<(i8, i1)> 
    %4 = llvm.extractvalue %2[1] : !llvm.struct<(i8, i1)> 
    llvm.call @use.i1(%4) : (i1) -> ()
    llvm.call @use.i8(%3) : (i8) -> ()
    %5 = llvm.icmp "eq" %3, %1 : i8
    llvm.return %5 : i1
  }
  llvm.func @extract_value_umul(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(1 : i8) : i8 // %0 is 00000001
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.or %arg0, %0 : i8 // %2 is ???????1
    %3 = llvm.add %arg1, %0 overflow<nuw> : i8
    %4 = "llvm.intr.umul.with.overflow"(%2, %3) : (i8, i8) -> !llvm.struct<(i8, i1)>
    %5 = llvm.extractvalue %4[0] : !llvm.struct<(i8, i1)> 
    %6 = llvm.extractvalue %4[1] : !llvm.struct<(i8, i1)> 
    llvm.call @use.i1(%6) : (i1) -> ()
    llvm.call @use.i8(%5) : (i8) -> ()
    %7 = llvm.icmp "eq" %5, %1 : i8
    llvm.return %7 : i1
  }
  llvm.func @extract_value_umul_fail(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(2 : i8) : i8 // %0 is 00000010
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.mlir.constant(0 : i8) : i8 // %2 is 00000000
    %3 = llvm.or %arg0, %0 : i8 // %3 is ??????1?
    %4 = llvm.add %arg1, %1 overflow<nuw> : i8
    %5 = "llvm.intr.umul.with.overflow"(%3, %4) : (i8, i8) -> !llvm.struct<(i8, i1)>
    %6 = llvm.extractvalue %5[0] : !llvm.struct<(i8, i1)> 
    %7 = llvm.extractvalue %5[1] : !llvm.struct<(i8, i1)> 
    llvm.call @use.i1(%7) : (i1) -> ()
    llvm.call @use.i8(%6) : (i8) -> ()
    %8 = llvm.icmp "eq" %6, %2 : i8
    llvm.return %8 : i1
  }
  llvm.func @extract_value_smul(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(1 : i8) : i8 // %0 is 00000001
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.or %arg0, %0 : i8 // %2 is ???????1
    %3 = llvm.add %arg1, %0 overflow<nuw> : i8
    %4 = "llvm.intr.smul.with.overflow"(%3, %2) : (i8, i8) -> !llvm.struct<(i8, i1)>
    %5 = llvm.extractvalue %4[0] : !llvm.struct<(i8, i1)> 
    %6 = llvm.extractvalue %4[1] : !llvm.struct<(i8, i1)> 
    llvm.call @use.i1(%6) : (i1) -> ()
    llvm.call @use.i8(%5) : (i8) -> ()
    %7 = llvm.icmp "eq" %5, %1 : i8
    llvm.return %7 : i1
  }
  llvm.func @extract_value_smul_fail(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(1 : i8) : i8 // %0 is 00000001
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.or %arg0, %0 : i8 // %2 is ???????1
    %3 = llvm.add %arg1, %0 : i8
    %4 = "llvm.intr.smul.with.overflow"(%3, %2) : (i8, i8) -> !llvm.struct<(i8, i1)>
    %5 = llvm.extractvalue %4[0] : !llvm.struct<(i8, i1)> 
    %6 = llvm.extractvalue %4[1] : !llvm.struct<(i8, i1)> 
    llvm.call @use.i1(%6) : (i1) -> ()
    llvm.call @use.i8(%5) : (i8) -> ()
    %7 = llvm.icmp "eq" %5, %1 : i8
    llvm.return %7 : i1
  }
  llvm.func @known_self_mul_bit_0_set(%arg0: i8 {llvm.noundef}) -> i8 {
    %0 = llvm.mlir.constant(1 : i8) : i8 // %0 is 00000001
    %1 = llvm.mlir.constant(4 : i8) : i8 // %1 is 00000100
    %2 = llvm.or %arg0, %0 : i8 // %2 is ???????1
    %3 = llvm.mul %2, %2 : i8
    %4 = llvm.and %3, %1 : i8 // %4 is 00000?00
    llvm.return %4 : i8
  }
  llvm.func @known_self_mul_bit_0_unset(%arg0: i8 {llvm.noundef}) -> i8 {
    %0 = llvm.mlir.constant(-2 : i8) : i8 // %0 is 11111110
    %1 = llvm.mlir.constant(8 : i8) : i8 // %1 is 00001000
    %2 = llvm.and %arg0, %0 : i8 // %2 is ???????0
    %3 = llvm.mul %2, %2 : i8 // %3 is ??????00
    %4 = llvm.and %3, %1 : i8 // %4 is 0000?000
    llvm.return %4 : i8
  }
  llvm.func @known_self_mul_bit_1_set_bit_0_unset(%arg0: i8 {llvm.noundef}) -> i8 {
    %0 = llvm.mlir.constant(-4 : i8) : i8 // %0 is 11111100
    %1 = llvm.mlir.constant(2 : i8) : i8 // %1 is 00000010
    %2 = llvm.mlir.constant(24 : i8) : i8 // %2 is 00011000
    %3 = llvm.and %arg0, %0 : i8 // %3 is ??????00
    %4 = llvm.or disjoint %3, %1 : i8 // %4 is ??????10
    %5 = llvm.mul %4, %4 : i8 // %5 is ??????00
    %6 = llvm.and %5, %2 : i8 // %6 is 000??000
    llvm.return %6 : i8
  }
  llvm.func @known_self_mul_bit_1_set_bit_0_unset_i4(%arg0: i4 {llvm.noundef}) -> i4 {
    %0 = llvm.mlir.constant(-4 : i4) : i4 // %0 is 1100
    %1 = llvm.mlir.constant(2 : i4) : i4 // %1 is 0010
    %2 = llvm.mlir.constant(-8 : i4) : i4 // %2 is 1000
    %3 = llvm.and %arg0, %0 : i4 // %3 is ??00
    %4 = llvm.or disjoint %3, %1 : i4 // %4 is ??10
    %5 = llvm.mul %4, %4 : i4 // %5 is ??00
    %6 = llvm.and %5, %2 : i4 // %6 is ?000
    llvm.return %6 : i4
  }
  llvm.func @known_reduce_or(%arg0: vector<2xi8>) -> i8 {
    %0 = llvm.mlir.constant(dense<[5, 3]> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.or %arg0, %0 : vector<2xi8>
    %3 = "llvm.intr.vector.reduce.or"(%2) : (vector<2xi8>) -> i8
    %4 = llvm.and %3, %1 : i8 // %4 is 0000000?
    llvm.return %4 : i8
  }
  llvm.func @known_reduce_or_fail(%arg0: vector<2xi8>) -> i8 {
    %0 = llvm.mlir.constant(dense<[5, 3]> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(4 : i8) : i8 // %1 is 00000100
    %2 = llvm.or %arg0, %0 : vector<2xi8>
    %3 = "llvm.intr.vector.reduce.or"(%2) : (vector<2xi8>) -> i8
    %4 = llvm.and %3, %1 : i8 // %4 is 00000?00
    llvm.return %4 : i8
  }
  llvm.func @known_reduce_and(%arg0: vector<2xi8>) -> i8 {
    %0 = llvm.mlir.constant(dense<[5, 3]> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.or %arg0, %0 : vector<2xi8>
    %3 = "llvm.intr.vector.reduce.and"(%2) : (vector<2xi8>) -> i8
    %4 = llvm.and %3, %1 : i8 // %4 is 0000000?
    llvm.return %4 : i8
  }
  llvm.func @known_reduce_and_fail(%arg0: vector<2xi8>) -> i8 {
    %0 = llvm.mlir.constant(dense<[5, 3]> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(2 : i8) : i8 // %1 is 00000010
    %2 = llvm.or %arg0, %0 : vector<2xi8>
    %3 = "llvm.intr.vector.reduce.and"(%2) : (vector<2xi8>) -> i8
    %4 = llvm.and %3, %1 : i8 // %4 is 000000?0
    llvm.return %4 : i8
  }
  llvm.func @known_reduce_xor_even(%arg0: vector<2xi8>) -> i8 {
    %0 = llvm.mlir.constant(dense<[5, 3]> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.or %arg0, %0 : vector<2xi8>
    %3 = "llvm.intr.vector.reduce.xor"(%2) : (vector<2xi8>) -> i8
    %4 = llvm.and %3, %1 : i8 // %4 is 0000000?
    llvm.return %4 : i8
  }
  llvm.func @known_reduce_xor_even2(%arg0: vector<2xi8>) -> i8 {
    %0 = llvm.mlir.constant(dense<15> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(16 : i8) : i8 // %1 is 00010000
    %2 = llvm.and %arg0, %0 : vector<2xi8>
    %3 = "llvm.intr.vector.reduce.xor"(%2) : (vector<2xi8>) -> i8
    %4 = llvm.and %3, %1 : i8 // %4 is 000?0000
    llvm.return %4 : i8
  }
  llvm.func @known_reduce_xor_even_fail(%arg0: vector<2xi8>) -> i8 {
    %0 = llvm.mlir.constant(dense<[5, 3]> : vector<2xi8>) : vector<2xi8>
    %1 = llvm.mlir.constant(2 : i8) : i8 // %1 is 00000010
    %2 = llvm.or %arg0, %0 : vector<2xi8>
    %3 = "llvm.intr.vector.reduce.xor"(%2) : (vector<2xi8>) -> i8
    %4 = llvm.and %3, %1 : i8 // %4 is 000000?0
    llvm.return %4 : i8
  }
  llvm.func @known_reduce_xor_odd(%arg0: vector<3xi8>) -> i8 {
    %0 = llvm.mlir.constant(dense<[5, 3, 9]> : vector<3xi8>) : vector<3xi8>
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.or %arg0, %0 : vector<3xi8>
    %3 = "llvm.intr.vector.reduce.xor"(%2) : (vector<3xi8>) -> i8
    %4 = llvm.and %3, %1 : i8 // %4 is 0000000?
    llvm.return %4 : i8
  }
  llvm.func @known_reduce_xor_odd2(%arg0: vector<3xi8>) -> i8 {
    %0 = llvm.mlir.constant(dense<[15, 15, 31]> : vector<3xi8>) : vector<3xi8>
    %1 = llvm.mlir.constant(32 : i8) : i8 // %1 is 00100000
    %2 = llvm.and %arg0, %0 : vector<3xi8>
    %3 = "llvm.intr.vector.reduce.xor"(%2) : (vector<3xi8>) -> i8
    %4 = llvm.and %3, %1 : i8 // %4 is 00?00000
    llvm.return %4 : i8
  }
  llvm.func @known_reduce_xor_odd2_fail(%arg0: vector<3xi8>) -> i8 {
    %0 = llvm.mlir.constant(dense<[15, 15, 31]> : vector<3xi8>) : vector<3xi8>
    %1 = llvm.mlir.constant(16 : i8) : i8 // %1 is 00010000
    %2 = llvm.and %arg0, %0 : vector<3xi8>
    %3 = "llvm.intr.vector.reduce.xor"(%2) : (vector<3xi8>) -> i8
    %4 = llvm.and %3, %1 : i8 // %4 is 000?0000
    llvm.return %4 : i8
  }
  llvm.func @known_reduce_xor_odd_fail(%arg0: vector<3xi8>) -> i8 {
    %0 = llvm.mlir.constant(dense<[5, 3, 9]> : vector<3xi8>) : vector<3xi8>
    %1 = llvm.mlir.constant(2 : i8) : i8 // %1 is 00000010
    %2 = llvm.or %arg0, %0 : vector<3xi8>
    %3 = "llvm.intr.vector.reduce.xor"(%2) : (vector<3xi8>) -> i8
    %4 = llvm.and %3, %1 : i8 // %4 is 000000?0
    llvm.return %4 : i8
  }
  llvm.func @nonzero_reduce_xor_vscale_even(%arg0: vector<[2]xi8>) -> i8 {
    %0 = llvm.mlir.poison : vector<[2]xi8>
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.mlir.constant(0 : i64) : i64 // %2 is 0000000000000000000000000000000000000000000000000000000000000000
    %3 = llvm.insertelement %1, %0[%2 : i64] : vector<[2]xi8>
    %4 = llvm.shufflevector %3, %0 [0, 0] : vector<[2]xi8> 
    %5 = llvm.or %arg0, %4 : vector<[2]xi8>
    %6 = "llvm.intr.vector.reduce.xor"(%5) : (vector<[2]xi8>) -> i8
    %7 = llvm.and %6, %1 : i8 // %7 is 0000000?
    llvm.return %7 : i8
  }
  llvm.func @nonzero_reduce_xor_vscale_odd_fail(%arg0: vector<[3]xi8>) -> i8 {
    %0 = llvm.mlir.poison : vector<[3]xi8>
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.mlir.constant(0 : i64) : i64 // %2 is 0000000000000000000000000000000000000000000000000000000000000000
    %3 = llvm.insertelement %1, %0[%2 : i64] : vector<[3]xi8>
    %4 = llvm.shufflevector %3, %0 [0, 0, 0] : vector<[3]xi8> 
    %5 = llvm.or %arg0, %4 : vector<[3]xi8>
    %6 = "llvm.intr.vector.reduce.xor"(%5) : (vector<[3]xi8>) -> i8
    %7 = llvm.and %6, %1 : i8 // %7 is 0000000?
    llvm.return %7 : i8
  }
  llvm.func @nonzero_reduce_xor_vscale_even_fail(%arg0: vector<[2]xi8>) -> i8 {
    %0 = llvm.mlir.poison : vector<[2]xi8>
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.mlir.constant(0 : i64) : i64 // %2 is 0000000000000000000000000000000000000000000000000000000000000000
    %3 = llvm.mlir.constant(2 : i8) : i8 // %3 is 00000010
    %4 = llvm.insertelement %1, %0[%2 : i64] : vector<[2]xi8>
    %5 = llvm.shufflevector %4, %0 [0, 0] : vector<[2]xi8> 
    %6 = llvm.or %arg0, %5 : vector<[2]xi8>
    %7 = "llvm.intr.vector.reduce.xor"(%6) : (vector<[2]xi8>) -> i8
    %8 = llvm.and %7, %3 : i8 // %8 is 000000?0
    llvm.return %8 : i8
  }
  llvm.func @nonzero_reduce_xor_vscale_odd(%arg0: vector<[3]xi8>) -> i8 {
    %0 = llvm.mlir.poison : vector<[3]xi8>
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.mlir.constant(0 : i64) : i64 // %2 is 0000000000000000000000000000000000000000000000000000000000000000
    %3 = llvm.mlir.constant(2 : i8) : i8 // %3 is 00000010
    %4 = llvm.insertelement %1, %0[%2 : i64] : vector<[3]xi8>
    %5 = llvm.shufflevector %4, %0 [0, 0, 0] : vector<[3]xi8> 
    %6 = llvm.and %arg0, %5 : vector<[3]xi8>
    %7 = "llvm.intr.vector.reduce.xor"(%6) : (vector<[3]xi8>) -> i8
    %8 = llvm.and %7, %3 : i8 // %8 is 000000?0
    llvm.return %8 : i8
  }
  llvm.func @test_sign_pos(%arg0: f32) -> i1 {
    %0 = llvm.mlir.constant(-1 : i32) : i32 // %0 is 11111111111111111111111111111111
    %1 = llvm.intr.fabs(%arg0) : (f32) -> f32
    %2 = llvm.bitcast %1 : f32 to i32
    %3 = llvm.icmp "sgt" %2, %0 : i32
    llvm.return %3 : i1
  }
  llvm.func @test_sign_pos_half(%arg0: f16) -> i1 {
    %0 = llvm.mlir.constant(-1 : i16) : i16 // %0 is 1111111111111111
    %1 = llvm.intr.fabs(%arg0) : (f16) -> f16
    %2 = llvm.bitcast %1 : f16 to i16
    %3 = llvm.icmp "sgt" %2, %0 : i16
    llvm.return %3 : i1
  }
  llvm.func @test_sign_pos_half_non_elementwise(%arg0: vector<2xf16>) -> i1 {
    %0 = llvm.mlir.constant(-1 : i32) : i32 // %0 is 11111111111111111111111111111111
    %1 = llvm.intr.fabs(%arg0) : (vector<2xf16>) -> vector<2xf16>
    %2 = llvm.bitcast %1 : vector<2xf16> to i32
    %3 = llvm.icmp "sgt" %2, %0 : i32
    llvm.return %3 : i1
  }
  llvm.func @test_sign_neg(%arg0: f32) -> i1 {
    %0 = llvm.mlir.constant(0 : i32) : i32 // %0 is 00000000000000000000000000000000
    %1 = llvm.intr.fabs(%arg0) : (f32) -> f32
    %2 = llvm.fneg %1 : f32
    %3 = llvm.bitcast %2 : f32 to i32
    %4 = llvm.icmp "slt" %3, %0 : i32
    llvm.return %4 : i1
  }
  llvm.func @test_sign_pos_vec(%arg0: vector<2xf32>) -> vector<2xi1> {
    %0 = llvm.mlir.constant(0 : i32) : i32 // %0 is 00000000000000000000000000000000
    %1 = llvm.mlir.constant(dense<0> : vector<2xi32>) : vector<2xi32>
    %2 = llvm.intr.fabs(%arg0) : (vector<2xf32>) -> vector<2xf32>
    %3 = llvm.bitcast %2 : vector<2xf32> to vector<2xi32>
    %4 = llvm.icmp "slt" %3, %1 : vector<2xi32>
    llvm.return %4 : vector<2xi1>
  }
  llvm.func @test_inf_only(%arg0: f32 {llvm.nofpclass = 507 : i64}) -> i32 {
    %0 = llvm.mlir.constant(2147483647 : i32) : i32 // %0 is 01111111111111111111111111111111
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 0???????????????????????????????
    llvm.return %2 : i32
  }
  llvm.func @test_inf_only_bfloat(%arg0: bf16 {llvm.nofpclass = 507 : i64}) -> i16 {
    %0 = llvm.mlir.constant(32767 : i16) : i16 // %0 is 0111111111111111
    %1 = llvm.bitcast %arg0 : bf16 to i16
    %2 = llvm.and %1, %0 : i16 // %2 is 0???????????????
    llvm.return %2 : i16
  }
  llvm.func @test_inf_only_ppc_fp128(%arg0: !llvm.ppc_fp128 {llvm.nofpclass = 507 : i64}) -> i128 {
    %0 = llvm.mlir.constant(170141183460469231731687303715884105727 : i128) : i128 // %0 is 01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
    %1 = llvm.bitcast %arg0 : !llvm.ppc_fp128 to i128
    %2 = llvm.and %1, %0 : i128 // %2 is 0???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
    llvm.return %2 : i128
  }
  llvm.func @test_zero_only(%arg0: f32 {llvm.nofpclass = 927 : i64}) -> i32 {
    %0 = llvm.mlir.constant(2147483647 : i32) : i32 // %0 is 01111111111111111111111111111111
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 0???????????????????????????????
    llvm.return %2 : i32
  }
  llvm.func @test_zero_only_non_ieee(%arg0: f80 {llvm.nofpclass = 927 : i64}) -> i80 {
    %0 = llvm.mlir.constant(604462909807314587353087 : i80) : i80 // %0 is 01111111111111111111111111111111111111111111111111111111111111111111111111111111
    %1 = llvm.bitcast %arg0 : f80 to i80
    %2 = llvm.and %1, %0 : i80 // %2 is 0???????????????????????????????????????????????????????????????????????????????
    llvm.return %2 : i80
  }
  llvm.func @test_inf_nan_only(%arg0: f32 {llvm.nofpclass = 504 : i64}) -> i32 {
    %0 = llvm.mlir.constant(2130706432 : i32) : i32 // %0 is 01111111000000000000000000000000
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 0???????000000000000000000000000
    llvm.return %2 : i32
  }
  llvm.func @test_sub_zero_only(%arg0: f32 {llvm.nofpclass = 783 : i64}) -> i32 {
    %0 = llvm.mlir.constant(2130706432 : i32) : i32 // %0 is 01111111000000000000000000000000
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 0???????000000000000000000000000
    llvm.return %2 : i32
  }
  llvm.func @test_inf_zero_only(%arg0: f32 {llvm.nofpclass = 411 : i64}) -> i32 {
    %0 = llvm.mlir.constant(16777215 : i32) : i32 // %0 is 00000000111111111111111111111111
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 00000000????????????????????????
    llvm.return %2 : i32
  }
  llvm.func @test_ninf_only(%arg0: f64) -> i32 {
    %0 = llvm.mlir.constant(0xFFF0000000000000 : f64) : f64
    %1 = llvm.mlir.constant(0 : i32) : i32 // %1 is 00000000000000000000000000000000
    %2 = llvm.fcmp "oeq" %arg0, %0 : f64
    llvm.cond_br %2, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %3 = llvm.bitcast %arg0 : f64 to i64
    %4 = llvm.trunc %3 : i64 to i32
    llvm.return %4 : i32
  ^bb2:  // pred: ^bb0
    llvm.return %1 : i32
  }
  llvm.func @test_simplify_icmp(%arg0: i32) -> i1 {
    %0 = llvm.mlir.constant(-140737488355328 : i64) : i64 // %0 is 1111111111111111100000000000000000000000000000000000000000000000
    %1 = llvm.mlir.constant(-1970324836974592 : i64) : i64 // %1 is 1111111111111001000000000000000000000000000000000000000000000000
    %2 = llvm.uitofp %arg0 : i32 to f64
    %3 = llvm.bitcast %2 : f64 to i64
    %4 = llvm.and %3, %0 : i64 // %4 is ?????????????????00000000000000000000000000000000000000000000000
    %5 = llvm.icmp "eq" %4, %1 : i64
    llvm.return %5 : i1
  }
  llvm.func @test_snan_quiet_bit1(%arg0: f32 {llvm.nofpclass = 926 : i64}) -> i32 {
    %0 = llvm.mlir.constant(4194304 : i32) : i32 // %0 is 00000000010000000000000000000000
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 000000000?0000000000000000000000
    llvm.return %2 : i32
  }
  llvm.func @test_snan_quiet_bit2(%arg0: f32 {llvm.nofpclass = 926 : i64}) -> i32 {
    %0 = llvm.mlir.constant(2097152 : i32) : i32 // %0 is 00000000001000000000000000000000
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 0000000000?000000000000000000000
    llvm.return %2 : i32
  }
  llvm.func @test_qnan_quiet_bit1(%arg0: f32 {llvm.nofpclass = 925 : i64}) -> i32 {
    %0 = llvm.mlir.constant(4194304 : i32) : i32 // %0 is 00000000010000000000000000000000
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 000000000?0000000000000000000000
    llvm.return %2 : i32
  }
  llvm.func @test_qnan_quiet_bit2(%arg0: f32 {llvm.nofpclass = 925 : i64}) -> i32 {
    %0 = llvm.mlir.constant(2097152 : i32) : i32 // %0 is 00000000001000000000000000000000
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 0000000000?000000000000000000000
    llvm.return %2 : i32
  }
  llvm.func @test_simplify_mask(%arg0: i32, %arg1: f32) -> i16 {
    %0 = llvm.mlir.constant(16 : i32) : i32 // %0 is 00000000000000000000000000010000
    %1 = llvm.mlir.constant(-32768 : i16) : i16 // %1 is 1000000000000000
    %2 = llvm.mlir.constant(31744 : i16) : i16 // %2 is 0111110000000000
    %3 = llvm.mlir.constant(0 : i16) : i16 // %3 is 0000000000000000
    %4 = llvm.uitofp %arg0 : i32 to f32
    %5 = llvm.fcmp "olt" %arg1, %4 : f32
    llvm.cond_br %5, ^bb2, ^bb1
  ^bb1:  // pred: ^bb0
    %6 = llvm.bitcast %4 : f32 to i32
    %7 = llvm.lshr %6, %0 : i32 // %7 is 0000000000000000????????????????
    %8 = llvm.trunc %7 : i32 to i16
    %9 = llvm.and %8, %1 : i16 // %9 is ?000000000000000
    %10 = llvm.or disjoint %9, %2 : i16 // %10 is ?111110000000000
    llvm.return %10 : i16
  ^bb2:  // pred: ^bb0
    llvm.return %3 : i16
  }
  llvm.func @test_simplify_icmp2(%arg0: f64) -> i1 {
    %0 = llvm.mlir.constant(0x7FF0000000000000 : f64) : f64
    %1 = llvm.mlir.constant(false) : i1 // %1 is 0
    %2 = llvm.mlir.constant(3458764513820540928 : i64) : i64 // %2 is 0011000000000000000000000000000000000000000000000000000000000000
    %3 = llvm.intr.fabs(%arg0) : (f64) -> f64
    %4 = llvm.fcmp "oeq" %3, %0 : f64
    llvm.cond_br %4, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %5 = llvm.bitcast %arg0 : f64 to i64
    %6 = llvm.icmp "eq" %5, %2 : i64
    llvm.return %6 : i1
  ^bb2:  // pred: ^bb0
    llvm.return %1 : i1
  }
  llvm.func @test_snan_only(%arg0: f32 {llvm.nofpclass = 1022 : i64}) -> i32 {
    %0 = llvm.mlir.constant(4194304 : i32) : i32 // %0 is 00000000010000000000000000000000
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 000000000?0000000000000000000000
    llvm.return %2 : i32
  }
  llvm.func @test_qnan_only(%arg0: f32 {llvm.nofpclass = 1021 : i64}) -> i32 {
    %0 = llvm.mlir.constant(4194304 : i32) : i32 // %0 is 00000000010000000000000000000000
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 000000000?0000000000000000000000
    llvm.return %2 : i32
  }
  llvm.func @pr92084(%arg0: f64) -> i64 {
    %0 = llvm.mlir.constant(0.000000e+00 : f64) : f64
    %1 = llvm.mlir.constant(1 : i64) : i64 // %1 is 0000000000000000000000000000000000000000000000000000000000000001
    %2 = llvm.mlir.constant(0 : i64) : i64 // %2 is 0000000000000000000000000000000000000000000000000000000000000000
    %3 = llvm.fcmp "uno" %arg0, %0 : f64
    llvm.cond_br %3, ^bb1, ^bb3
  ^bb1:  // pred: ^bb0
    llvm.cond_br %3, ^bb3, ^bb2
  ^bb2:  // pred: ^bb1
    %4 = llvm.bitcast %arg0 : f64 to i64
    %5 = llvm.and %4, %1 : i64 // %5 is 000000000000000000000000000000000000000000000000000000000000000?
    llvm.return %5 : i64
  ^bb3:  // 2 preds: ^bb0, ^bb1
    llvm.return %2 : i64
  }
  llvm.func @test_none(%arg0: f32 {llvm.nofpclass = 1023 : i64}) -> i32 {
    %0 = llvm.mlir.constant(4194304 : i32) : i32 // %0 is 00000000010000000000000000000000
    %1 = llvm.bitcast %arg0 : f32 to i32
    %2 = llvm.and %1, %0 : i32 // %2 is 000000000?0000000000000000000000
    llvm.return %2 : i32
  }
  llvm.func @pr92217() -> i1 {
    %0 = llvm.mlir.constant(-2.49429861E+33 : f32) : f32
    %1 = llvm.mlir.constant(0 : i32) : i32 // %1 is 00000000000000000000000000000000
    %2 = llvm.intr.sqrt(%0) : (f32) -> f32
    %3 = llvm.bitcast %2 : f32 to i32
    %4 = llvm.icmp "slt" %3, %1 : i32
    llvm.return %4 : i1
  }
  llvm.func @sqrt_negative_input(%arg0: f32 {llvm.nofpclass = 995 : i64}) -> i1 {
    %0 = llvm.mlir.constant(0 : i32) : i32 // %0 is 00000000000000000000000000000000
    %1 = llvm.intr.sqrt(%arg0) : (f32) -> f32
    %2 = llvm.bitcast %1 : f32 to i32
    %3 = llvm.icmp "slt" %2, %0 : i32
    llvm.return %3 : i1
  }
  llvm.func @sqrt_negative_input_nnan(%arg0: f32 {llvm.nofpclass = 995 : i64}) -> i1 {
    %0 = llvm.mlir.constant(0 : i32) : i32 // %0 is 00000000000000000000000000000000
    %1 = llvm.intr.sqrt(%arg0) {fastmathFlags = #llvm.fastmath<nnan>} : (f32) -> f32
    %2 = llvm.bitcast %1 : f32 to i32
    %3 = llvm.icmp "slt" %2, %0 : i32
    llvm.return %3 : i1
  }
  llvm.func @test_icmp_add(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(32 : i8) : i8 // %0 is 00100000
    %1 = llvm.add %arg0, %arg1 overflow<nuw> : i8
    %2 = llvm.icmp "ult" %1, %0 : i8
    llvm.cond_br %2, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %3 = llvm.and %arg0, %0 : i8 // %3 is 00?00000
    llvm.return %3 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_add_fail_nsw(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(32 : i8) : i8 // %0 is 00100000
    %1 = llvm.add %arg0, %arg1 overflow<nsw> : i8
    %2 = llvm.icmp "ult" %1, %0 : i8
    llvm.cond_br %2, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %3 = llvm.and %arg0, %0 : i8 // %3 is 00?00000
    llvm.return %3 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_add2(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(15 : i8) : i8 // %0 is 00001111
    %1 = llvm.mlir.constant(32 : i8) : i8 // %1 is 00100000
    %2 = llvm.add %arg0, %arg1 overflow<nsw, nuw> : i8
    %3 = llvm.icmp "uge" %2, %0 : i8
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    llvm.return %arg2 : i8
  ^bb2:  // pred: ^bb0
    %4 = llvm.and %arg0, %1 : i8 // %4 is 00?00000
    llvm.return %4 : i8
  }
  llvm.func @test_icmp_add_fail_bad_range(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(32 : i8) : i8 // %0 is 00100000
    %1 = llvm.add %arg0, %arg1 overflow<nuw> : i8
    %2 = llvm.icmp "ule" %1, %0 : i8
    llvm.cond_br %2, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %3 = llvm.and %arg0, %0 : i8 // %3 is 00?00000
    llvm.return %3 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_add_fail_bad_pred(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(32 : i8) : i8 // %0 is 00100000
    %1 = llvm.add %arg0, %arg1 overflow<nuw> : i8
    %2 = llvm.icmp "ugt" %1, %0 : i8
    llvm.cond_br %2, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %3 = llvm.and %arg0, %0 : i8 // %3 is 00?00000
    llvm.return %3 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_sub(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(-33 : i8) : i8 // %0 is 11011111
    %1 = llvm.mlir.constant(32 : i8) : i8 // %1 is 00100000
    %2 = llvm.sub %arg0, %arg1 overflow<nuw> : i8
    %3 = llvm.icmp "ugt" %2, %0 : i8
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %4 = llvm.and %arg0, %1 : i8 // %4 is 00?00000
    llvm.return %4 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_sub_fail_wrong_arg(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(-33 : i8) : i8 // %0 is 11011111
    %1 = llvm.mlir.constant(32 : i8) : i8 // %1 is 00100000
    %2 = llvm.sub %arg0, %arg1 overflow<nuw> : i8
    %3 = llvm.icmp "ugt" %2, %0 : i8
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %4 = llvm.and %arg1, %1 : i8 // %4 is 00?00000
    llvm.return %4 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_sub2(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(-32 : i8) : i8 // %0 is 11100000
    %1 = llvm.mlir.constant(32 : i8) : i8 // %1 is 00100000
    %2 = llvm.sub %arg0, %arg1 overflow<nuw> : i8
    %3 = llvm.icmp "ule" %2, %0 : i8
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    llvm.return %arg2 : i8
  ^bb2:  // pred: ^bb0
    %4 = llvm.and %arg0, %1 : i8 // %4 is 00?00000
    llvm.return %4 : i8
  }
  llvm.func @test_icmp_sub2_fail_nsw(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(-32 : i8) : i8 // %0 is 11100000
    %1 = llvm.mlir.constant(32 : i8) : i8 // %1 is 00100000
    %2 = llvm.sub %arg0, %arg1 overflow<nsw> : i8
    %3 = llvm.icmp "ule" %2, %0 : i8
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    llvm.return %arg2 : i8
  ^bb2:  // pred: ^bb0
    %4 = llvm.and %arg0, %1 : i8 // %4 is 00?00000
    llvm.return %4 : i8
  }
  llvm.func @test_icmp_sub_fail_bad_range(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(-33 : i8) : i8 // %0 is 11011111
    %1 = llvm.mlir.constant(32 : i8) : i8 // %1 is 00100000
    %2 = llvm.sub %arg0, %arg1 overflow<nuw> : i8
    %3 = llvm.icmp "uge" %2, %0 : i8
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %4 = llvm.and %arg0, %1 : i8 // %4 is 00?00000
    llvm.return %4 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @test_icmp_sub_fail_bad_pred(%arg0: i8, %arg1: i8, %arg2: i8) -> i8 {
    %0 = llvm.mlir.constant(32 : i8) : i8 // %0 is 00100000
    %1 = llvm.sub %arg0, %arg1 overflow<nuw> : i8
    %2 = llvm.icmp "sge" %1, %0 : i8
    llvm.cond_br %2, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %3 = llvm.and %arg0, %0 : i8 // %3 is 00?00000
    llvm.return %3 : i8
  ^bb2:  // pred: ^bb0
    llvm.return %arg2 : i8
  }
  llvm.func @simplifydemanded_context(%arg0: i8, %arg1: i8) -> i8 {
    %0 = llvm.mlir.constant(1 : i8) : i8 // %0 is 00000001
    %1 = llvm.mlir.constant(3 : i8) : i8 // %1 is 00000011
    %2 = llvm.mlir.constant(0 : i8) : i8 // %2 is 00000000
    %3 = llvm.and %arg0, %0 : i8 // %3 is 0000000?
    llvm.call @dummy() : () -> ()
    %4 = llvm.and %arg0, %1 : i8 // %4 is 000000??
    %5 = llvm.icmp "eq" %4, %2 : i8
    llvm.intr.assume %5 : i1
    %6 = llvm.and %3, %arg1 : i8 // %6 is 0000000?
    llvm.return %6 : i8
  }
  llvm.func @pr97330(%arg0: i1, %arg1: !llvm.ptr, %arg2: !llvm.ptr) -> i16 {
    %0 = llvm.mlir.constant(1 : i16) : i16 // %0 is 0000000000000001
    %1 = llvm.mlir.constant(1 : i64) : i64 // %1 is 0000000000000000000000000000000000000000000000000000000000000001
    %2 = llvm.load %arg1 {alignment = 8 : i64} : !llvm.ptr -> i64
    %3 = llvm.trunc %2 : i64 to i16
    llvm.cond_br %arg0, ^bb2, ^bb1
  ^bb1:  // pred: ^bb0
    %4 = llvm.icmp "ne" %3, %0 : i16
    %5 = llvm.zext %4 : i1 to i32 // %5 is 0000000000000000000000000000000?
    llvm.store %5, %arg2 {alignment = 4 : i64} : i32, !llvm.ptr
    %6 = llvm.icmp "eq" %2, %1 : i64
    llvm.intr.assume %6 : i1
    llvm.unreachable
  ^bb2:  // pred: ^bb0
    llvm.return %3 : i16
  }
  llvm.func @mul_nuw_nsw_nonneg_const(%arg0: i8) -> i1 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(-1 : i8) : i8 // %1 is 11111111
    %2 = llvm.mul %arg0, %0 overflow<nsw, nuw> : i8
    %3 = llvm.icmp "sgt" %2, %1 : i8
    llvm.return %3 : i1
  }
  llvm.func @mul_nuw_nsw_nonneg_const_missing_nuw(%arg0: i8) -> i1 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(-1 : i8) : i8 // %1 is 11111111
    %2 = llvm.mul %arg0, %0 overflow<nsw> : i8
    %3 = llvm.icmp "sgt" %2, %1 : i8
    llvm.return %3 : i1
  }
  llvm.func @mul_nuw_nsw_nonneg_const_missing_nsw(%arg0: i8) -> i1 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(-1 : i8) : i8 // %1 is 11111111
    %2 = llvm.mul %arg0, %0 overflow<nuw> : i8
    %3 = llvm.icmp "sgt" %2, %1 : i8
    llvm.return %3 : i1
  }
  llvm.func @mul_nuw_nsw_nonneg_can_be_one(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(127 : i8) : i8 // %0 is 01111111
    %1 = llvm.mlir.constant(-1 : i8) : i8 // %1 is 11111111
    %2 = llvm.and %arg1, %0 : i8 // %2 is 0???????
    %3 = llvm.mul %arg0, %2 overflow<nsw, nuw> : i8
    %4 = llvm.icmp "sgt" %3, %1 : i8
    llvm.return %4 : i1
  }
  llvm.func @mul_nuw_nsw_nonneg_cant_be_one(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(127 : i8) : i8 // %0 is 01111111
    %1 = llvm.mlir.constant(2 : i8) : i8 // %1 is 00000010
    %2 = llvm.mlir.constant(-1 : i8) : i8 // %2 is 11111111
    %3 = llvm.and %arg1, %0 : i8 // %3 is 0???????
    %4 = llvm.or %3, %1 : i8 // %4 is 0?????1?
    %5 = llvm.mul %arg0, %4 overflow<nsw, nuw> : i8
    %6 = llvm.icmp "sgt" %5, %2 : i8
    llvm.return %6 : i1
  }
  llvm.func @mul_nuw_nsw_nonneg_cant_be_one_commuted(%arg0: i8, %arg1: i8) -> i1 {
    %0 = llvm.mlir.constant(127 : i8) : i8 // %0 is 01111111
    %1 = llvm.mlir.constant(2 : i8) : i8 // %1 is 00000010
    %2 = llvm.mlir.constant(-1 : i8) : i8 // %2 is 11111111
    %3 = llvm.and %arg1, %0 : i8 // %3 is 0???????
    %4 = llvm.or %3, %1 : i8 // %4 is 0?????1?
    %5 = llvm.mul %4, %arg0 overflow<nsw, nuw> : i8
    %6 = llvm.icmp "sgt" %5, %2 : i8
    llvm.return %6 : i1
  }
  llvm.func @test_trunc_and_1(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(1 : i8) : i8 // %0 is 00000001
    %1 = llvm.trunc %arg0 : i8 to i1
    llvm.cond_br %1, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %2 = llvm.and %arg0, %0 : i8 // %2 is 0000000?
    llvm.return %2 : i8
  ^bb2:  // pred: ^bb0
    %3 = llvm.and %arg0, %0 : i8 // %3 is 0000000?
    llvm.return %3 : i8
  }
  llvm.func @test_not_trunc_and_1(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(true) : i1 // %0 is 1
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.trunc %arg0 : i8 to i1
    %3 = llvm.xor %2, %0 : i1
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %4 = llvm.and %arg0, %1 : i8 // %4 is 0000000?
    llvm.return %4 : i8
  ^bb2:  // pred: ^bb0
    %5 = llvm.and %arg0, %1 : i8 // %5 is 0000000?
    llvm.return %5 : i8
  }
  llvm.func @neg_test_trunc_or_2(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(2 : i8) : i8 // %0 is 00000010
    %1 = llvm.trunc %arg0 : i8 to i1
    llvm.cond_br %1, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %2 = llvm.or %arg0, %0 : i8 // %2 is ??????1?
    llvm.return %2 : i8
  ^bb2:  // pred: ^bb0
    %3 = llvm.or %arg0, %0 : i8 // %3 is ??????1?
    llvm.return %3 : i8
  }
  llvm.func @test_trunc_nuw_and_1(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(1 : i8) : i8 // %0 is 00000001
    %1 = llvm.trunc %arg0 overflow<nuw> : i8 to i1
    llvm.cond_br %1, ^bb2, ^bb1
  ^bb1:  // pred: ^bb0
    %2 = llvm.and %arg0, %0 : i8 // %2 is 0000000?
    llvm.return %2 : i8
  ^bb2:  // pred: ^bb0
    %3 = llvm.and %arg0, %0 : i8 // %3 is 0000000?
    llvm.return %3 : i8
  }
  llvm.func @test_trunc_nuw_or_2(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(2 : i8) : i8 // %0 is 00000010
    %1 = llvm.trunc %arg0 overflow<nuw> : i8 to i1
    llvm.cond_br %1, ^bb2, ^bb1
  ^bb1:  // pred: ^bb0
    %2 = llvm.or %arg0, %0 : i8 // %2 is ??????1?
    llvm.return %2 : i8
  ^bb2:  // pred: ^bb0
    %3 = llvm.or %arg0, %0 : i8 // %3 is ??????1?
    llvm.return %3 : i8
  }
  llvm.func @test_not_trunc_nuw_and_1(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(true) : i1 // %0 is 1
    %1 = llvm.mlir.constant(1 : i8) : i8 // %1 is 00000001
    %2 = llvm.trunc %arg0 overflow<nuw> : i8 to i1
    %3 = llvm.xor %2, %0 : i1
    llvm.cond_br %3, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %4 = llvm.and %arg0, %1 : i8 // %4 is 0000000?
    llvm.return %4 : i8
  ^bb2:  // pred: ^bb0
    %5 = llvm.and %arg0, %1 : i8 // %5 is 0000000?
    llvm.return %5 : i8
  }
  llvm.func @test_trunc_cond_and(%arg0: i8, %arg1: i1) -> i8 {
    %0 = llvm.mlir.constant(-2 : i8) : i8 // %0 is 11111110
    %1 = llvm.trunc %arg0 : i8 to i1
    %2 = llvm.and %1, %arg1 : i1
    llvm.cond_br %2, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %3 = llvm.or %arg0, %0 : i8 // %3 is 1111111?
    llvm.return %3 : i8
  ^bb2:  // pred: ^bb0
    %4 = llvm.or %arg0, %0 : i8 // %4 is 1111111?
    llvm.return %4 : i8
  }
  llvm.func @test_not_trunc_cond_and(%arg0: i8, %arg1: i1) -> i8 {
    %0 = llvm.mlir.constant(true) : i1 // %0 is 1
    %1 = llvm.mlir.constant(-2 : i8) : i8 // %1 is 11111110
    %2 = llvm.trunc %arg0 : i8 to i1
    %3 = llvm.xor %2, %0 : i1
    %4 = llvm.and %3, %arg1 : i1
    llvm.cond_br %4, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %5 = llvm.or %arg0, %1 : i8 // %5 is 1111111?
    llvm.return %5 : i8
  ^bb2:  // pred: ^bb0
    %6 = llvm.or %arg0, %1 : i8 // %6 is 1111111?
    llvm.return %6 : i8
  }
  llvm.func @test_inv_cond_and(%arg0: i8, %arg1: i1) -> i8 {
    %0 = llvm.mlir.constant(3 : i8) : i8 // %0 is 00000011
    %1 = llvm.mlir.constant(0 : i8) : i8 // %1 is 00000000
    %2 = llvm.mlir.constant(true) : i1 // %2 is 1
    %3 = llvm.mlir.constant(-4 : i8) : i8 // %3 is 11111100
    %4 = llvm.and %arg0, %0 : i8 // %4 is 000000??
    %5 = llvm.icmp "ne" %4, %1 : i8
    llvm.call @use(%5) : (i1) -> ()
    %6 = llvm.xor %5, %2 : i1
    %7 = llvm.and %6, %arg1 : i1
    llvm.cond_br %7, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    %8 = llvm.or %arg0, %3 : i8 // %8 is 111111??
    llvm.return %8 : i8
  ^bb2:  // pred: ^bb0
    %9 = llvm.or %arg0, %3 : i8 // %9 is 111111??
    llvm.return %9 : i8
  }
  llvm.func @scalable_add_to_disjoint_or(%arg0: i8, %arg1: vector<[4]xi32> {llvm.range = #llvm.constant_range<i32, 0, 256>}) -> vector<[4]xi32> {
    %0 = llvm.mlir.constant(8 : i32) : i32 // %0 is 00000000000000000000000000001000
    %1 = llvm.mlir.poison : vector<[4]xi32>
    %2 = llvm.mlir.constant(0 : i32) : i32 // %2 is 00000000000000000000000000000000
    %3 = llvm.zext %arg0 : i8 to i32 // %3 is 000000000000000000000000????????
    %4 = llvm.shl %3, %0 overflow<nsw, nuw> : i32 // %4 is 0000000000000000????????00000000
    %5 = llvm.insertelement %4, %1[%2 : i32] : vector<[4]xi32>
    %6 = llvm.shufflevector %5, %1 [0, 0, 0, 0] : vector<[4]xi32> 
    %7 = llvm.add %6, %arg1 : vector<[4]xi32>
    llvm.return %7 : vector<[4]xi32>
  }
  llvm.func @dummy()
  llvm.func @use(i1)
  llvm.func @sink(i8)
}
