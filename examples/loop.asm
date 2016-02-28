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
    MOV R0 0xFF
    HLT