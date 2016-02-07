`ifndef CPU_DATA
`define CPU_DATA

typedef enum bit [3:0] {
    OP_ADD = 'b0000,
    OP_SUB = 'b0010,
    OP_AND = 'b0100,
    OP_OR = 'b0110,
    OP_XOR = 'b1000,
    OP_MOV = 'b1010,
    OP_CMP = 'b1100,
    OP_ADC = 'b0001,
    OP_SBC = 'b0011
    //OP_SWP = 'b1000
} Math_operator;

typedef enum bit [2:0] {
    OP_CLC = 'b000,
    OP_CLZ = 'b001,
    OP_CLO = 'b010,
    OP_CLN = 'b011,
    OP_WTF = 'b100,
    OP_NOP = 'b110,
    OP_HLT = 'b111
} Other_operator;

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
    OP_RJMP = 'b1100 //restricted jump
} Branch_operator;

typedef enum bit [2:0] {
    GROUP_MATH_CONSTANT,
    GROUP_MATH_REG,
    GROUP_MATH_EREG,
    GROUP_BRANCH_JUMPS,
    GROUP_OTHERS,
    GROUP_WRONG
} Operator_group;


`endif