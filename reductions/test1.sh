#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
LLVM_BIN=/opt/homebrew/opt/llvm/bin
MLIR_TRANSLATE=${MLIR_TRANSLATE:-$LLVM_BIN/mlir-translate}
export PATH="$LLVM_BIN:$PATH"
export BUILD_DIR="${BUILD_DIR:-$ROOT/build}"

tmp=$(mktemp "${TMPDIR:-/tmp}/known-bits.XXXXXX")
trap 'rm -f "$tmp"' EXIT INT TERM

"$MLIR_TRANSLATE" --import-llvm "$1" > "$tmp"
"$ROOT/run.sh" "$tmp" | grep -Eq 'llvm\.or .*// .*0100\?\?\?\?'
