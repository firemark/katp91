#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

rm -rf obj_dir/
verilator \
    --cc $DIR/src/board.v\
    --top-module Board\
    --stats\
    --noassert\
    -O3\
    -I$DIR/src\
    -CFLAGS "-O3 -m64"\
    -LDFLAGS "-lsfml-graphics -lsfml-window -lsfml-system -lrt"\
    --exe $DIR/src-emulator/main-board.cpp
cd obj_dir
make -j -f VBoard.mk VBoard
