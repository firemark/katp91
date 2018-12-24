.MEM:
    val: db 0x0AA0
.BOOT:
    MOV AH @high@val
    MOV AL @low@val
    LD BX AX
    MOV AH 0x90  ; led register
    MOV AL 0x00
    MOV DH 0xA0  ; digits register
    MOV DL 0x00
loop:
    ST BX AX
    ST BX DX
    INC BX
    MOV CL 0
counter1:
    INC CL
    CMP CL 0x20
    BRNE counter1
    RJMP loop
