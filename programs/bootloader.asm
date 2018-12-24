.MEM:
    val: db 0xAAAA
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
    MOV CH 0
    MOV CL 0
counter1:
    INC CH 
    CMP CH 0xFF
    BRNE counter2
    RJMP loop
counter2:
    INC CL
    CMP CL 0xFF
    BRNE counter2
    RJMP counter1
