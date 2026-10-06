module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, i64 = dense<[32, 64]> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little">, llvm.module_asm = [], llvm.target_triple = ""} {
  llvm.func @keep_shift(%arg0: i32) -> i32 {
    %0 = llvm.mlir.constant(255 : i32) : i32 // %0 is 00000000000000000000000011111111
    %1 = llvm.mlir.constant(8 : i32) : i32 // %1 is 00000000000000000000000000001000
    %2 = llvm.mlir.constant(4 : i32) : i32 // %2 is 00000000000000000000000000000100
    %3 = llvm.and %arg0, %0 : i32 // %3 is 000000000000000000000000????????
    %4 = llvm.shl %3, %1 : i32 // %4 is 0000000000000000????????00000000
    %5 = llvm.lshr %4, %2 : i32 // %5 is 00000000000000000000????????0000
    llvm.return %5 : i32
  }
}
