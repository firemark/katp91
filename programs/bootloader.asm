main:
    MOV R1 0x0A
    MOV R8 0x00
    MOV R8 0x01
    LD R2 ER0
    ADD R2 0xA0
loop:
    MOV R9 0x90
    MOV R8 0x00
    ST R2 ER0
    MOV R9 0xA0
    ST R2 ER0
    ADD R2 0x01
    MOV R3 0x00
    MOV R4 0x00
    MOV R5 0x00
counter1:
    ADD R3 0x01
    ADC R4 0x00
    ADC R5 0x00
    CMP R5 0x05
    BRNE counter1
    RJMP loop
