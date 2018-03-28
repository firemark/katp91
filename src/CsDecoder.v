`include "cpu_data.v"
`include "cpu_cs.v"

(* bram_map="yes" *)
module CsDecoder(
    reset,
    cycle,
    operator_group,
    operator,
    check_branch,
    cs);

    input reset;
    input [3:0] cycle;
    input [3:0] operator_group;
    input [3:0] operator;
    input check_branch;
    output reg [35:0] cs;
    
    initial cs = 0;

    parameter [3:0]
        CYCLE_0 = 4'b0000,
        CYCLE_1 = 4'b0001,
        CYCLE_2 = 4'b0011,
        CYCLE_3 = 4'b0010,
        CYCLE_4 = 4'b0110,
        CYCLE_5 = 4'b0111,
        CYCLE_6 = 4'b0101,
        CYCLE_7 = 4'b0100,
        CYCLE_8 = 4'b1100,
        CYCLE_9 = 4'b1101,
        CYCLE_10 = 4'b1111,
        CYCLE_11 = 4'b1110,
        CYCLE_12 = 4'b1010,
        CYCLE_13 = 4'b1011,
        CYCLE_14 = 4'b1001,
        CYCLE_15 = 4'b1000;

    always @ (reset or cycle or operator_group or operator or check_branch)
        if (reset)
            cs = 0;
        else casez ({cycle, operator_group})
            {CYCLE_0, `GROUP_BRANCH_JUMPS}:
                if (check_branch)
                    cs = `CS_NEW_PC | `CS_INC | `CS_IN_ADDR;
                else
                    cs = `CS_OUT_PC | `CS_INC | `CS_IN_ADDR;
            {CYCLE_0, 4'b????}:
                cs = `CS_OUT_PC | `CS_INC | `CS_IN_ADDR;
            {CYCLE_1, 4'b????}:
                cs = `CS_OUT_INC_DEC | `CS_IN_PC;
            {CYCLE_2, 4'b????}:
                cs = `CS_OUT_PC | `CS_INC | `CS_IN_ADDR;
            {CYCLE_3, 4'b????}:
                cs = `CS_OUT_INC_DEC | `CS_IN_PC | `CS_DECODER;
            {CYCLE_4, `GROUP_SINGLE_REG},
            {CYCLE_4, `GROUP_MATH_CONSTANT},
            {CYCLE_4, `GROUP_MATH_REG}:
                cs = `CS_OUT_RG1 | `CS_OUT_RG2 | `CS_IN_ALU8;
            {CYCLE_5, `GROUP_SINGLE_REG},
            {CYCLE_5, `GROUP_MATH_CONSTANT},
            {CYCLE_5, `GROUP_MATH_REG}:
                if (operator != `OP_CMP)
                    cs = `CS_OUT_FLAGS_ALU8 | `CS_IN_FLAGS | `CS_OUT_ALU8 | `CS_IN_RG1;
                else
                    cs = `CS_OUT_FLAGS_ALU8 | `CS_IN_FLAGS;
            {CYCLE_4, `GROUP_REG_MEMORY}:
                if (operator[2])
                    case (operator[1:0])
                        2'b01: cs = `CS_WRITE | `CS_INC | `CS_OUT_RG1 | `CS_OUT_ERG2 | `CS_IN_ADDR;
                        2'b10: cs = `CS_WRITE | `CS_DEC | `CS_OUT_RG1 | `CS_OUT_ERG2 | `CS_IN_ADDR;
                        default: cs = `CS_WRITE | `CS_OUT_RG1 | `CS_OUT_ERG2 | `CS_IN_ADDR; 
                    endcase
                else
                    case (operator[1:0])
                        2'b01: cs = `CS_INC | `CS_OUT_ERG2 | `CS_IN_ADDR;
                        2'b10: cs = `CS_DEC | `CS_OUT_ERG2 | `CS_IN_ADDR;
                        default: cs = `CS_OUT_ERG2 | `CS_IN_ADDR; 
                    endcase
            {CYCLE_5, `GROUP_REG_MEMORY}:
                if (operator[2])
                    case (operator[1:0])
                        2'b01, 2'b10: cs = `CS_WRITE | `CS_OUT_RG1 | `CS_IN_ERG2 | `CS_OUT_INC_DEC;
                        default: cs = `CS_WRITE | `CS_OUT_RG1;
                    endcase
                else
                    case (operator[1:0])
                        2'b01, 2'b10: cs = `CS_READ | `CS_IN_RG1 | `CS_IN_ERG2 | `CS_OUT_INC_DEC;
                        default: cs = `CS_READ | `CS_IN_RG1;
                    endcase
            {CYCLE_4, `GROUP_STACK}:
                case (operator)
                    `OP_PUSH: cs = `CS_OUT_SP | `CS_OUT_RG1 | `CS_IN_ADDR | `CS_DEC;
                    `OP_POP: cs = `CS_OUT_SP | `CS_IN_ADDR | `CS_INC;
                    default: cs = 32'hx;
                endcase
            {CYCLE_5, `GROUP_STACK}:
                case (operator)
                    `OP_PUSH: cs = `CS_IN_SP | `CS_OUT_INC_DEC | `CS_WRITE | `CS_OUT_RG1;
                    `OP_POP: cs = `CS_IN_SP | `CS_OUT_INC_DEC | `CS_READ | `CS_IN_RG1;
                    default: cs = 32'hx;
                endcase
            {CYCLE_4, `GROUP_EXTENDED}:
                cs = `CS_OUT_PC | `CS_INC | `CS_IN_ADDR;
            {CYCLE_5, `GROUP_EXTENDED}:
                cs = `CS_READ | `CS_IN_WD_H;
            {CYCLE_6, `GROUP_EXTENDED}:
                cs = `CS_OUT_INC_DEC | `CS_IN_PC | `CS_IN_ADDR;
            {CYCLE_7, `GROUP_EXTENDED}:
                cs = `CS_READ | `CS_IN_WD_L;
            {CYCLE_8, `GROUP_EXTENDED}:
                case (operator)
                    `OP_JMP: cs = `CS_IN_PC | `CS_OUT_WD;
                    default: cs = 32'hx;
                endcase
            default: cs = 32'hx;
        endcase

endmodule
