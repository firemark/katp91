#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
SRC=$DIR/src

rm -rf obj_dir/
verilator \
    --cc $SRC/board.v \
    --cc $SRC/alu.v \
    --cc $SRC/check_branch.v \
    --cc $SRC/cpu_decode_first_byte.v \
    --top-module Board \
    --stats\
    --noassert\
    -O3\
    -I$SRC \
    -CFLAGS "-O3 -m64"\
    -LDFLAGS "-lsfml-graphics -lsfml-window -lsfml-system -lrt"\
    --exe $DIR/src-emulator/main-board.cpp
cd obj_dir
make -j -f VBoard.mk VBoard
