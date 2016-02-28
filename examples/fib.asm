main:
    MOV R0 5; n value
    CALL .fib; result will be in R1
    JMP .lol
.fib:
    PUSH R0; save n
    CMP R0 2
    BRNC fib_continue; if R0 >= 2
    MOV R1 R0; result
    POP R0; restore n
    RET
fib_continue:
    SUB R0 1
    PUSH R0
    CALL .fib; R1 = F(R0-1)
    MOV R2 R1
    SUB R0 1
    PUSH R0
    CALL .fib; R1 = F(R0-2)
    ADD R1 R2; F(R0-1) + F(R0-2)
    POP R0; restore n
    RET
.lol:
    HLT