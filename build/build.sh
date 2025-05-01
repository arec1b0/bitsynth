# File: bitsynth/build/build.sh
# Description: Compile BitSynth using NASM and output a DOS-compatible .COM binary

#!/bin/bash
set -e

OUT=../output/bitsynth.com
SRC=../src/main.asm

nasm -f bin "$SRC" -o "$OUT"
echo "Build complete: $OUT"
