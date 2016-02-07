# katp91
simple computer written in Verilog to FPGA

## Run

### Compile emulator

```bash
./verilator.sh  # required verilator
cp obj_dir/Vcpu . 
```
### Compile asm to bytecode and run

```bash
./asm.py asm.code > asm.hex  # required python3
./Vcpu asm.hex 
```

## ASM

### Description

* Rx - 8bit register where X is from 0 to F
* K - constant 8bit value
* Ry/K - 8bit register or constant value
* Ar - Address Relative - signed 9bit value
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

#Instructions

```
Instruction     Operation               Changed flags 
##Arithmetic and Logic##
ADD Rx ERy/K    Rx ← Rx + ERy/K         C V N Z     
ADD ERx ERy     ERx ← ERx + ERy         C V N Z 
ADC Rx Ry/K     Rx ← Rx + Ry/K + C      C V N Z
ADC ERx ERy     ERx ← ERx + ERy + C     C V N Z 
SUB Rx Ry/K     Rx ← Rx - Ry/K          C V N Z
SUB ERx ERy     ERx ← ERx - ERy         C V N Z 
SBC Rx Ry/K     Rx ← Rx - Ry/K - C      C V N Z
SUB ERx ERy     ERx ← ERx - ERy - C     C V N Z 
OR  Rx Ry/K     Rx ← Rx ∨ Ry/K          C V N Z
OR  ERx ERy     ERx ← ERx ∨ ERy         C V N Z
AND Rx Ry/K     Rx ← Rx ∧ Ry/K          C V N Z
AND ERx ERy     ERx ← ERx ∧ ERy         C V N Z
XOR Rx Ry/K     Rx ← Rx ⊕ Ry/K          C V N Z
XOR ERx ERy/K   ERx ← ERx ⊕ ERy/K       C V N Z
MOV Rx Ry/K     Rx ← Ry/K               -
MOV ERx ERy     ERx ← ERy               -
CMP Rx Ry/K     Rx ⊕ Ry                 C V N Z
CMP ERx ERy     ERx ⊕ ERy               C V N Z
##Relative Jumps##
RJMP Ar         PC ← PC + Ar            -  
BREQ Ar         if(Z=1) PC ← PC + Ar    -
BRNE Ar         if(Z=0) PC ← PC + Ar    -  
BRLT Ar         if(N⊕V=1) PC ← PC + Ar  -  
BRGE Ar         if(N⊕V=0) PC ← PC + Ar  -  
BRO Ar          if(V=1) PC ← PC + Ar    -  
BRNO Ar         if(V=0) PC ← PC + Ar    -  
BRN Ar          if(N=1) PC ← PC + Ar    -  
BRNN Ar         if(N=0) PC ← PC + Ar    -  
BRLO Ar         if(C=1) PC ← PC + Ar    -
BRSH Ar         if(C=0) PC ← PC + Ar    -
##Other commands##
HLT             H ← 1                   H 
NOP             nothing
```
