#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
SRC=$DIR/src

rm -rf obj_dir/
verilator \
    --cc $SRC/cpu.v \
    --cc $SRC/alu8.v \
    --cc $SRC/alu16.v \
    --cc $SRC/check_branch.v \
    --cc $SRC/decoder.v \
    --cc $SRC/set_flager.v \
    -I$SRC\
    --top-module Cpu \
    --exe $DIR/src-emulator/main.cpp
cd obj_dir
make -j -f VCpu.mk VCpu
