`ifndef CPU_DATA
`define CPU_DATA

// Math operators
`define OP_ADD 4'b0000
`define OP_ADC 4'b0001
`define OP_SUB 4'b0010
`define OP_SBC 4'b0011
`define OP_AND 4'b0100
`define OP_OR  4'b0110
`define OP_XOR 4'b0111
`define OP_MOV 4'b1011
`define OP_CMP 4'b1111

// Reg memory operators (operators for 16bit)
`define OP_LD 4'b1000
`define OP_LDI 4'b1001
`define OP_LDD 4'b1010
`define OP_ST 4'b1100
`define OP_STI 4'b1101
`define OP_STD 4'b1110

// Branch operators
`define OP_BREQ 4'b0000 //equality
`define OP_BRNE 4'b0001 //not equality
`define OP_BRLT 4'b0010 //less than
`define OP_BRGE 4'b0011 //great and eq
`define OP_BRC  4'b0100 //carry
`define OP_BRO  4'b0101 //overflow
`define OP_BRN  4'b0110 //negative
`define OP_BRNC 4'b0111 //not carry
`define OP_BRNO 4'b1000 //not overflow
`define OP_BRNN 4'b1001 //not negative
`define OP_RJMP 4'b1100 //restricted jump
`define OP_RCALL 4'b1101 //restricted call

// Single operators
`define OP_NEG 4'b0000
`define OP_COM 4'b0001
`define OP_LSL 4'b0010
`define OP_LSR 4'b0011
`define OP_ROL 4'b0100
`define OP_ROR 4'b0101
`define OP_RLC 4'b0110
`define OP_RRC 4'b0111
`define OP_INC 4'b1000
`define OP_DEC 4'b1001

// Stack operators (Single operators for 16bit)
`define OP_PUSH 4'b1110
`define OP_POP 4'b1111

// Long operators
`define OP_JMP 4'b1110
`define OP_CALL 4'b1111

// Special operators
`define OP_NOP 4'b0000
`define OP_RET 4'b0001
`define OP_HLT 4'b0111

// Operator groups
`define GROUP_CRVMATH 4'h0
`define GROUP_RJMP 4'h1
`define GROUP_CRRMATH 4'h2
`define GROUP_CRSMATH 4'h3
`define GROUP_WRRMATH 4'h4
`define GROUP_WRSMATH 4'h5
`define GROUP_SFLAG 4'h6
`define GROUP_UFLAG 4'h7
`define GROUP_SPECIAL 4'h8
`define GROUP_WRRMATH_MEM 4'h9
`define GROUP_WRSMATH_STACK 4'hA
`define GROUP_SPECIAL_LONG 4'hB

`endif