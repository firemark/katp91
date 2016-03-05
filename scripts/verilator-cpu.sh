#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

rm -rf obj_dir/
verilator \
    --cc $DIR/src/cpu.v\
    -I$DIR/src\
    --exe $DIR/src-emulator/main.cpp
cd obj_dir
make -j -f Vcpu.mk Vcpu
