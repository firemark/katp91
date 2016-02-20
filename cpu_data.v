`ifndef CPU_DATA
`define CPU_DATA

typedef enum bit [3:0] {
    OP_ADD = 'b0000,
    OP_ADC = 'b0001,
    OP_SUB = 'b0010,
    OP_SBC = 'b0011,
    OP_AND = 'b0100,
    OP_OR = 'b0110,
    OP_XOR = 'b1000,
    OP_MOV = 'b1010,
    OP_CMP = 'b1100
} Math_operator;

typedef enum bit [3:0] {
    OP_BREQ = 'b0000, //equality
    OP_BRNE = 'b0001, //not equality
    OP_BRLT = 'b0010, //less than
    OP_BRGE = 'b0011, //great and eq
    OP_BRC = 'b00100, //carry
    OP_BRO = 'b0101, //overflow
    OP_BRN = 'b0110, //negative
    OP_BRNC = 'b0111, //not carry
    OP_BRNO = 'b1000, //not  overflow
    OP_BRNN = 'b1001, //not negative
    OP_BRLO = 'b1010, //lower 
    OP_BRSH = 'b1011, //same and higher
    OP_RJMP = 'b1100, //restricted jump
    OP_RCALL = 'b1101 //restricted call
} Branch_operator;

typedef enum bit [3:0] {
    OP_NEG = 'b0000,
    OP_COM = 'b0001,
    OP_LSL = 'b0010,
    OP_LSR = 'b0011,
    OP_ROL = 'b0100,
    OP_ROR = 'b0101,
    OP_RLC = 'b0110,
    OP_RRC = 'b0111,
    OP_PUSH = 'b1000,
    OP_POP = 'b1001
} Single_operator;

typedef enum bit [2:0] {
    OP_LD = 'b000,
    OP_LDI = 'b001,
    OP_LDD = 'b010,
    OP_ST = 'b100,
    OP_STI = 'b101,
    OP_STD = 'b110
} Reg_memory_operator;

typedef enum bit [3:0] {
    OP_JMP = 'b0000,
    OP_CALL = 'b0001
} Extended_operator;

typedef enum bit [3:0] {
    OP_CLC = 'b0000,
    OP_CLZ = 'b0001,
    OP_CLO = 'b0010,
    OP_CLN = 'b0011,
    OP_RET = 'b0111,
    OP_STC = 'b1000,
    OP_STZ = 'b1001,
    OP_STO = 'b1010,
    OP_STN = 'b1011,
    OP_NOP = 'b1100,
    OP_HLT = 'b1111
} Other_operator;

typedef enum {
    GROUP_MATH_CONSTANT,
    GROUP_MATH_REG,
    GROUP_MATH_EREG,
    GROUP_BRANCH_JUMPS,
    GROUP_SINGLE_REG,
    GROUP_REG_MEMORY,
    GROUP_SINGLE_EREG,
    GROUP_EXTENDED,
    GROUP_OTHERS,
    GROUP_WRONG
} Operator_group;

`endif