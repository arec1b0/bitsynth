#!/bin/bash
# Build script for BitSynth Tracker

set -e

OUT=../output/tracker.com
SRC=note_tracker.asm

echo "Building BitSynth Tracker..."
nasm -f bin "$SRC" -o "$OUT"
echo "Build complete: $OUT"