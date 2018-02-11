# Legend

* `WRITE` write signal
* `READ` read signal
* `ADDR` address bus
* `DATA` data bus
* `PC` program counter
* `SP` stack pointer
* `RX` 8 bit X register
* `ERY` 16 bit Y register
* `BYTE1` First byte to decode
* `BYTE2` Second byte to decode

# Cycling

## Read opcode

```
1° ADDR ← PC
2° READ ← 1
   PC ← PC + 1
3° BYTE1 ← DATA
4° READ ← 0
5° ADDR ← PC
6° READ ← 1
   PC ← PC + 1
7° BYTE1 ← DATA
8° READ ← 0
```

## Read from memory

```
1° ADDR ← ERY
2° READ ← 1
3° RX ← DATA
4° READ ← 0
   if inc: ERY ← ERY + 1
   if dec: ERY ← ERY + 1
```

## Write to memory

```
1° ADDR ← ERY
   DATA ← RX
2° WRITE ← 1
4° WRITE ← 0
   if inc: ERY ← ERY + 1
   if dec: ERY ← ERY + 1
```
