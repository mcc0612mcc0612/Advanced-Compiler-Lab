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
out=$("$ROOT/run.sh" "$tmp")
and_result=$(printf '%s\n' "$out" |
  awk '/llvm\.and .*\/\/ .*00000\?\?\?/ { print $1; exit }')
[ -n "$and_result" ]

cmp_result=$(printf '%s\n' "$out" |
  awk -v v="$and_result" '/llvm\.icmp "ult"/ && /\/\/ .*1/ && index($0, v ",") { print $1; exit }')
[ -n "$cmp_result" ]

printf '%s\n' "$out" |
  awk -v v="$cmp_result" '/llvm\.select/ && /\/\/ .*00101010/ && index($0, "llvm.select " v ",") { found = 1 } END { exit !found }'
