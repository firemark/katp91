#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

rm -rf obj_dir/
verilator \
    --cc $DIR/src/board.v\
    --top-module Board\
    -O2\
    -I$DIR/src\
    -LDFLAGS "-lsfml-graphics -lsfml-window -lsfml-system"\
    --exe $DIR/src-emulator/main-board.cpp
cd obj_dir
make -j -f VBoard.mk VBoard
