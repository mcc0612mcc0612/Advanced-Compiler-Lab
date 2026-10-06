module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, i64 = dense<[32, 64]> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little">, llvm.module_asm = [], llvm.target_triple = ""} {
  llvm.func @keep_bitwise(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(15 : i8) : i8 // %0 is 00001111
    %1 = llvm.mlir.constant(64 : i8) : i8 // %1 is 01000000
    %2 = llvm.and %arg0, %0 : i8 // %2 is 0000????
    %3 = llvm.or %2, %1 : i8 // %3 is 0100????
    llvm.return %3 : i8
  }
}
