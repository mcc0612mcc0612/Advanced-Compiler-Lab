module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, i64 = dense<[32, 64]> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little">, llvm.module_asm = [], llvm.target_triple = ""} {
  llvm.func @keep_select(%arg0: i8) -> i8 {
    %0 = llvm.mlir.constant(7 : i8) : i8 // %0 is 00000111
    %1 = llvm.mlir.constant(8 : i8) : i8 // %1 is 00001000
    %2 = llvm.mlir.constant(42 : i8) : i8 // %2 is 00101010
    %3 = llvm.mlir.constant(0 : i8) : i8 // %3 is 00000000
    %4 = llvm.and %arg0, %0 : i8 // %4 is 00000???
    %5 = llvm.icmp "ult" %4, %1 : i8 // %5 is 1
    %6 = llvm.select %5, %2, %3 : i1, i8 // %6 is 00101010
    llvm.return %6 : i8
  }
}
