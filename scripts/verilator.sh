#!/bin/bash

rm -rf obj_dir/
verilator \
    --cc cpu.v\
    --exe main.cpp
cd obj_dir
make -j -f Vcpu.mk Vcpu
