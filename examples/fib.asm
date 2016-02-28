main:
    MOV R0 10; n value
    CALL fib; result will be in R1
    JMP lol
fib:
    PUSH R0; save n
    PUSH R2; save temp value
    CMP R0 2
    BRNC fib_continue; if R0 >= 2
    MOV R1 R0; result
    RJMP fib_finish
fib_continue:
    SUB R0 1
    CALL fib; R1 = F(R0-1)
    MOV R2 R1
    SUB R0 1
    CALL fib; R1 = F(R0-2)
    ADD R1 R2; F(R0-1) + F(R0-2)
fib_finish:
    POP R2; restore temp
    POP R0; restore n
    RET
lol:
    HLT
