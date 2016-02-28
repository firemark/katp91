main:
    MOV R0 5
    MOV R1 5
    call .adder; result in R2
    HLT
.adder:
    PUSH R0
    PUSH R1
    MOV R2 R0
    ADD R2 R1
    POP R1
    POP R0
    RET