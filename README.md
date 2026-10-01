# Known-bits analysis for MLIR's LLVM dialect

A dataflow analysis, built as a loadable `mlir-opt` plugin, that works out
which bits of each integer value in the LLVM dialect are known to be zero or
known to be one.

## Building

```sh
cmake -S . -B build
cmake --build build
```

That is the whole procedure on Linux, macOS, and WSL2. There is no platform
flag to set and no path to edit. `CMakeLists.txt` finds MLIR by asking
whichever `llvm-config` is on your `PATH` where its CMake package lives, so if
`mlir-opt` runs, the build should configure.

To build against a specific MLIR instead:

```sh
cmake -S . -B build -DMLIR_DIR=/path/to/prefix/lib/cmake/mlir
```

You need an LLVM built with MLIR enabled and plugins enabled
(`-DLLVM_ENABLE_PROJECTS=mlir -DLLVM_ENABLE_PLUGINS=ON`; both are ordinary on
Linux and macOS). Distribution packages work: on Debian and Ubuntu that is
`libmlir-dev` alongside `llvm-dev`. On macOS, Homebrew's `llvm` is the easy
route if it ships `mlir-opt` for your version; otherwise build LLVM yourself.
The configure step diagnoses the cases it can detect — no MLIR
found, plugins disabled in the host LLVM, or an `mlir-opt` on `PATH` whose
version does not match what you are building against.

## What is where

| File | |
|---|---|
| `KnownBitsDomain.h` | The abstract domain: the lattice elements and their join. |
| `KnownBitsTransfer.h` | One transfer function per operation, on plain bit masks. |
| `KnownBitsAnalysis.cpp` | Maps LLVM dialect operations to those transfer functions. |
| `KnownBitsAnalysis.h` | Ties the domain to MLIR's sparse forward analysis. |
| `Annotate.{h,cpp}` | Prints IR with a comment on each value. Domain-agnostic. |
| `Plugin.cpp` | The pass, the solver setup, and the `mlir-opt` entry point. |
| `test/llvm-known-bits.ll` | The test input: LLVM's own known-bits test. |
| `test/llvm-known-bits.annotated.mlir` | What the pass prints for that input. |
| `cmake/RunTest.cmake` | The template's test runner. Not used by any test at present. |

## Test input and output

`test/llvm-known-bits.ll` is LLVM's InstCombine test for known bits, copied
unmodified from `llvm/test/Transforms/InstCombine/known-bits.ll`. It has 131
functions. `test/llvm-known-bits.annotated.mlir` is the listing the pass
produces for it, with known bits on 410 values; regenerate it with:

```sh
mlir-translate --import-llvm test/llvm-known-bits.ll | ./run.sh - \
    > test/llvm-known-bits.annotated.mlir
```

There is no automated test yet: `ctest` has nothing to run, and the listing has
not been checked against LLVM's expectations.

## To be done

- **Comparison with LLVM.** The `CHECK` lines in `llvm-known-bits.ll` show each
  function after LLVM's `instcombine`. Where LLVM proved a value constant, the
  function collapses to that constant (for example `call void @sink(i8 0)`).
- **Transformation.** The pass only prints. A follow-up pass should replace
  every value whose bits are all known with a constant and erase the operations
  left unused, as `instcombine` does, so its output can be compared with the
  `CHECK` lines directly.

## Notes on portability

Most of the platform-specific knowledge lives in `CMakeLists.txt`, next to the
code it affects. The parts worth knowing about:

**The plugin's file name differs.** It is `KnownBitsAnalysis.dylib` on macOS and
`KnownBitsAnalysis.so` on Linux and WSL2. Nothing in this project spells that out:
CMake is asked via `$<TARGET_FILE:KnownBitsAnalysis>`, and `run.sh` probes for both.

**Linking a plugin on macOS needs special flags.** The plugin deliberately
leaves its MLIR symbols undefined, to be resolved from the `mlir-opt` process
that loads it. On macOS that requires `-undefined dynamic_lookup`, which
`include(HandleLLVMOptions)` supplies. The same include also matches LLVM's
RTTI and exception settings, which differ between distribution packages and
local builds and cause link errors or silent ODR violations when they are
wrong. That is also why `project()` enables C: `HandleLLVMOptions` probes flags
with the C compiler and fails if none is configured.

**A plugin only loads into the LLVM it was built against.** The version is
recorded at compile time and checked at load time, so a mismatch is a clear
error rather than a crash. The configure step warns about it earlier still, by
comparing against the `mlir-opt` it finds.

**Under WSL2, build on the Linux filesystem.** A tree under `/mnt/c` is
slow enough to be noticeable and does not reliably carry execute bits.
`.gitattributes` forces LF endings, which keeps `run.sh` working when a
repository is cloned by a Windows git and built inside WSL2.

## How the analysis works

One lattice element covers all the bits of one operation's result. Its state is
the product of the states of the bits it contains, where each bit is known
zero, known one, or unknown (`?`). Unknown is the top of a bit's lattice, with
known zero and known one beneath it.

We use masks to represent the state of an `op`. For example, the zero mask of
`0000??10` is `11110001` and its one mask is `00000010`. Join works bit by bit:
a bit stays known only if both sides agree on it, and is unknown otherwise. So
the analysis is sound. Transfer functions cover `and`, `or`, `xor`, `add`,
`sub`, `mul`, the shifts, `trunc`, `zext`, `sext`, unsigned `icmp` and
`select`. 

For testing, the pass prints each value's bits as a comment.
