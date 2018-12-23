.MEM:
    val: db 0xA0A0
.BOOT:
    MOV AH @low@val
    MOV AL @high@val
    LD BX AX
    MOV AH 0x90  ; led register
    MOV AL 0x00
loop:
    ST BX AX
    INC BX
    MOV CL 0
counter1:
    INC CL
    CMP CL 0x10
    BRNE counter1
    RJMP loop
