.MEM:
    val: db 0xA00A
.INT_BUTTONS:
    PUSH AX
    PUSH CX
    PUSH DX
    MOV AH 0xB0  ; buttons register
    MOV AL 0x00
    LD CX AX
    MOV CH CL
    AND CH 0x01 ; if first button is clicked
    ;BREQ buttons_end  ; if result is zero - jump to end
    ; reset counter
    ADD BL 0x0F
    ADC BH 0

    MOV AH 0x90  ; led register
    MOV AL 0x00
    ST BX AX

    buttons_end:
        POP DX
        POP CX
        POP AX
        RETI
.BOOT:
    CALL load_init_val
    MOV AH 0x90  ; led register
    MOV AL 0x00
    MOV DH 0xA0  ; digits register
    MOV DL 0x00
    SFLAG I
loop:
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
load_init_val:
    PUSH AX
    PUSH CX
    PUSH DX
    MOV AH @high@val
    MOV AL @low@val
    LD BX AX
    POP AX
    POP CX
    POP DX
    RET
