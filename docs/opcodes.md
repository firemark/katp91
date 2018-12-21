# Opcodes groups
```
Register-Value 8bit operation
CRVMATH   .0XXX.VVVV.VVVV.AAAA.
          0    4    8   12   16
X - number of 8bit register
A - operation
V - 8bit Value

Relative Jump
RJMP      .10VV.VVVV.VVVV.AAAA.
          0    4    8   12   16
A - operation
V - relative ADDR to JUMP

Register-Register 8bit operation
CRRMATH   .1110.0XXX.YYY-.AAAA.
          0    4    8   12   16
A - operation
X - number of first 8bit register
Y - number of second 8bit register

Register single 8bit operation
CRSMATH   .1111.0XXX.----.AAAA.
          0    4    8   12   16
A - operation
X - number of 16bit register

Register-Register 16bit operation
WRRMATH   .1111.1XX-.YY--.AAAA.
          0    4    8   12   16
A - operation
X - number of first 16bit register
Y - number of second 16bit register

Register single 16bit operation
WRSMATH   .1111.1XX-.----.AAAA.
          0    4    8   12   16
A - operation
X - number of 16bit register

Set CPU Flags
SFLAG     .1100.0---.FFFF.FFFF. 
          0    4    8   12   16
F - bit of flag

Unset CPU Flags
UFLAG     .1100.1---.FFFF.FFFF. 
          0    4    8   12   16
F - bit of flag

Special operation
SPECIAL   .1101.1---.----.AAAA.
A - operation
```
