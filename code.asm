MOV R9 127
loop: ;prepare loop
    ADD R8 1
    ADD R9 1
    BRO _loop2
    RJMP loop

_loop2: ;check CMP
MOV R8 0
loop2:
    ADD R8 1
    CMP R8 4
    BREQ main
    RJMP loop2
main: 
MOV RF 0xBE ;print funny text in hex
MOV RE 0xEF
MOV RD 0xDE
MOV RC 0xAD
MOV ER0 ER3
ADD ER0 ER2
MOV R4 0x0F
MOV R5 0xF0
ADD R4 R5
SUB R4 0xF0
ADD R5 0xF0
MOV R6 0xFF
ADD R6 0x01
ADC R7 0x01
MOV R8 0
MOV R9 0
HLT
