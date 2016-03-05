# katp91
simple computer written in Verilog to FPGA

## Run

### Compile emulator

```bash
scripts/verilator-cpu.sh  # required verilator
cp obj_dir/Vcpu . 
```
### Compile asm to bytecode and run

```bash
scripts/asm.py asm.code > asm.hex  # required python3
./Vcpu asm.hex 
```

## ASM

### Description

* Rx - 8bit register where X is from 0 to F
* K - constant 8bit value
* Ry/K - 8bit register or constant value
* Ar - Address Relative - signed 9bit value
* A - Address - unsigned 16bit value
* ERx, ERy - 16 bit register where x, y is from 0 to 3
```
ER0 = {R9, R8}
ER1 = {RB. RA}
ER2 = {RD, RC}
ER3 = {RF, RE}
```
* V - Overflow N - Negative Z - Zero C - Carry
* H - Halt flag
* PC - Program counter
* SP - Stack pointer

#Instructions

```
Instruction     Operation               Changed flags   Cycles
##Arithmetic and Logic##
ADD Rx ERy/K    Rx ← Rx + ERy/K         C V N Z         2
ADD ERx ERy     ERx ← ERx + ERy         C V N Z         2
ADC Rx Ry/K     Rx ← Rx + Ry/K + C      C V N Z         2
ADC ERx ERy     ERx ← ERx + ERy + C     C V N Z         2
SUB Rx Ry/K     Rx ← Rx - Ry/K          C V N Z         2
SUB ERx ERy     ERx ← ERx - ERy         C V N Z         2
SBC Rx Ry/K     Rx ← Rx - Ry/K - C      C V N Z         2
SUB ERx ERy     ERx ← ERx - ERy - C     C V N Z         2
OR  Rx Ry/K     Rx ← Rx ∨ Ry/K          C V N Z         2
OR  ERx ERy     ERx ← ERx ∨ ERy         C V N Z         2
AND Rx Ry/K     Rx ← Rx ∧ Ry/K          C V N Z         2
AND ERx ERy     ERx ← ERx ∧ ERy         C V N Z         2
XOR Rx Ry/K     Rx ← Rx ⊕ Ry/K          C V N Z         2
XOR ERx ERy/K   ERx ← ERx ⊕ ERy/K       C V N Z         2
MOV Rx Ry/K     Rx ← Ry/K               -               2
MOV ERx ERy     ERx ← ERy               -               2
CMP Rx Ry/K     Rx ⊕ Ry                 C V N Z         2
CMP ERx ERy     ERx ⊕ ERy               C V N Z         2
NEG (E)Rx       0x00 - (E)Rx            V N Z           2
COM Rx          0xFF - (E)Rx            V N Z           2
COM ERx         0xFFFF - ERx            V N Z           2
LSL (E)Rx       (E)Rx[n+1] ← (E)Rx[n]   C V N Z         2
                (E)Rx[0] ← 0
                C ← (E)Rx[last bit]
LSR (E)Rx       (E)Rx[n] ← (E)Rx[n+1]   C V N Z         2
                (E)Rx[last bit] ← 0
                C ← (E)Rx[0]
ROL (E)Rx       (E)Rx[n+1] ← (E)Rx[n]   V N Z           2
                (E)Rx[0] ← (E)Rx[last]
ROR (E)Rx       (E)Rx[n] ← (E)Rx[n+1]   V N Z           2
                (E)Rx[last] ← (E)Rx[0]
RLC (E)Rx       (E)Rx[n+1] ← (E)Rx[n]   C V N Z         2
                (E)Rx[0] ← C
                C ← (E)Rx[last bit]
RRC (E)Rx       (E)Rx[n] ← (E)Rx[n+1]   C V N Z         2
                (E)Rx[last bit] ← C
                C ← (E)Rx[0]
##Relative Jumps##
RJMP Ar         PC ← PC + Ar            -               2
JMP A           PC ← A                  -               4
BREQ Ar         if(Z=1) PC ← PC + Ar    -               2
BRNE Ar         if(Z=0) PC ← PC + Ar    -               2
BRLT Ar         if(N⊕V=1) PC ← PC + Ar  -               2
BRGE Ar         if(N⊕V=0) PC ← PC + Ar  -               2
BRO Ar          if(V=1) PC ← PC + Ar    -               2
BRNO Ar         if(V=0) PC ← PC + Ar    -               2
BRN Ar          if(N=1) PC ← PC + Ar    -               2
BRNN Ar         if(N=0) PC ← PC + Ar    -               2
BRC Ar          if(C=1) PC ← PC + Ar    -               2
BRNC Ar         if(C=0) PC ← PC + Ar    -               2
##Load/Storage##
LD Rx ERy       Rx ← (ERy)              -               3
LDI Rx ERy      Rx ← (ERy); ERy ← ERy+1 -               3
LDD Rx ERy      Rx ← (ERy); ERy ← ERy-1 -               3
ST Rx ERy       (ERy) ← Rx              -               3
STI Rx ERy      (ERy) ← Rx; ERy ← ERy+1 -               3
STD Rx ERy      (ERy) ← Rx; ERy ← ERy-1 -               3
##Stack Command##
POP Rx          Rx ← (SP); SP ← SP - 1  -               3
PUSH Rx         (SP) ← Rx; SP ← SP + 1  -               3
CALL A          PUSH PC; JMP A          -               6
RET             POP PC                  -               3
##Other commands##
HLT             H ← 1                   H               2
NOP             nothing                 -               2
```
