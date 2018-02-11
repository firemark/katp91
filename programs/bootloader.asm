main:
    MOV R1 0xAA
    MOV R9 0x90
    MOV R8 0x00
    ST R1 ER0
loop:
    RJMP loop
