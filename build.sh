#!/bin/bash
./scripts/asm.py programs/bootloader.asm | ./scripts/bin2readmemh.py > bootloader.dat

