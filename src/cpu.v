`include "cpu_data.v"
`include "cpu_cs.v"

`define CS_ON(x) (|(cs & x))

module Cpu(clk, reset, data_bus, address_bus, r, w, halt);
    input clk /*verilator clocker*/;
    input reset;
    inout [7:0] data_bus;
    output [15:0] address_bus;
    output reg r, w;
    output reg halt;

    reg [31:0] cs;
    
    parameter [15:0]
        CYCLE_0 = 1 << 0,
        CYCLE_1 = 1 << 1,
        CYCLE_2 = 1 << 2,
        CYCLE_3 = 1 << 3,
        CYCLE_4 = 1 << 4,
        CYCLE_5 = 1 << 5,
        CYCLE_6 = 1 << 6,
        CYCLE_7 = 1 << 7,
        CYCLE_8 = 1 << 8,
        CYCLE_9 = 1 << 9,
        CYCLE_10 = 1 << 10,
        CYCLE_11 = 1 << 11,
        CYCLE_12 = 1 << 12,
        CYCLE_13 = 1 << 13,
        CYCLE_14 = 1 << 14,
        CYCLE_15 = 1 << 15;
    reg [15:0] cycle  /*verilator public*/;
    
    reg [7:0] data_bus_out;
    
    wire [15:0] bus_out1, bus_out2, bus_in;
    wire [3:0] in_rg, out_rg1, out_rg2;

    genvar i;
    generate
        for(i=0; i < 8; i = i + 1)
            Register8 register8(
                .cs_in(
                    `CS_ON(`CS_IN_RG1) && out_rg1 == i ||
                    `CS_ON(`CS_IN_RG2) && out_rg2 == i),
                .cs1(`CS_ON(`CS_OUT_RG1) && out_rg1 == i),
                .cs2(`CS_ON(`CS_OUT_RG2) && out_rg2 == i),
                .bus_in(bus_in[7:0]),
                .bus_out1(bus_out1[7:0]),
                .bus_out2(bus_out2[7:0]));
        for(i=0; i < 4; i = i + 1)
            DoubleRegister8 double_register8(
                .cs_l_in(
                    `CS_ON(`CS_IN_RG1) && out_rg1 == i * 2 + 8 ||
                    `CS_ON(`CS_IN_RG2) && out_rg2 == i * 2 + 8),
                .cs_l_1(`CS_ON(`CS_OUT_RG1) && out_rg1 == i * 2 + 8),
                .cs_l_2(`CS_ON(`CS_OUT_RG2) && out_rg2 == i * 2 + 8),
                .cs_h_in(
                    `CS_ON(`CS_IN_RG1) && out_rg1 == i * 2 + 9 ||
                    `CS_ON(`CS_IN_RG2) && out_rg2 == i * 2 + 9),
                .cs_h_1(`CS_ON(`CS_OUT_RG1) && out_rg1 == i * 2 + 9),
                .cs_h_2(`CS_ON(`CS_OUT_RG2) && out_rg2 == i * 2 + 9),
                .cs_16_in(
                    `CS_ON(`CS_IN_ERG1) && out_rg1 == i ||
                    `CS_ON(`CS_IN_ERG2) && out_rg2 == i),
                .cs_16_1(`CS_ON(`CS_OUT_ERG1) && out_rg1 == i),
                .cs_16_2(`CS_ON(`CS_OUT_ERG2) && out_rg2 == i),
                .bus_8_in(bus_in[7:0]),
                .bus_8_out1(bus_out1[7:0]),
                .bus_8_out2(bus_out2[7:0]),
                .bus_16_in(bus_in),
                .bus_16_out1(bus_out1),
                .bus_16_out2(bus_out2));

    endgenerate
    
    Register16 address_register(`CS_ON(`CS_IN_ADDR), 1'b1, bus_out2, address_bus);
    
    Register8 data_register(
        .cs_in(`CS_ON(`CS_IN_DATA)),
        .cs1(`CS_ON(`CS_OUT_DATA)),
        .cs2(`CS_ON(`CS_WRITE)),
        .bus_in(bus_out1[7:0]),
        .bus_out1(bus_in[7:0]),
        .bus_out2(data_bus));
    
    Register16 pc_register(
        .cs_in(`CS_ON(`CS_IN_PC)),
        .cs_out(`CS_ON(`CS_OUT_PC)),
        .bus_in(bus_in),
        .bus_out(bus_out2));
    
    IncRegister16 inc_register(
        .cs_inc(`CS_ON(`CS_INC)),
        .cs_dec(`CS_ON(`CS_DEC)),
        .cs_out(`CS_ON(`CS_OUT_INC_DEC)),
        .bus_in(bus_out2),
        .bus_out(bus_in));
        
    reg [15:0] word;
    reg cs_decoder;
    wire [7:0] val;
    wire [3:0] operator;
    wire [3:0] operator_group;
    wire extended_cycle;
    Decoder decoder(
        .cs(cs_decoder),
        .cs_new_pc(`CS_ON(`CS_NEW_PC)),
        .word(word),
        .operator_group(operator_group),
        .operator(operator),
        .extended_cycle(extended_cycle),
        .val(val),
        .pc(bus_out2),
        .new_out_pc(bus_in),
        .rg1(out_rg1),
        .rg2(out_rg2));
    
    wire [3:0] bus_flags;
    wire check_branch;
    FlagsRegister flags_register(
        .cs_in(`CS_ON(`CS_IN_FLAGS)),
        .operator(operator),
        .bus_in(bus_flags),
        .check_branch(check_branch));

    Alu8 alu8(
        .cs_in(`CS_ON(`CS_IN_ALU8)),
        .cs_out(`CS_ON(`CS_OUT_ALU8)),
        .cs_flags(`CS_ON(`CS_OUT_FLAGS_ALU8)),
        .single(operator_group == `GROUP_SINGLE_REG),
        .value1(bus_out1[7:0]),
        .value2(operator_group == `GROUP_MATH_CONSTANT ? val : bus_out2[7:0]),
        .operator(operator),
        .bus_in(bus_in[7:0]),
        .bus_flags(bus_flags));
    
    initial begin
        halt = 0;
        cycle = CYCLE_0;
        cs = 0;
        cs_decoder = 0;
    end
    
    always @ (clk or reset)
        if (reset)
            cycle = CYCLE_0;
        else if (clk)
            case(cycle)
                CYCLE_0: cycle = CYCLE_1;
                CYCLE_2: cycle = CYCLE_3;
                CYCLE_4: cycle = CYCLE_5;
                CYCLE_6: cycle = CYCLE_7;
                CYCLE_8: cycle = CYCLE_9;
                CYCLE_10: cycle = CYCLE_11;
            endcase
        else
            case(cycle)
                CYCLE_1: cycle = CYCLE_2;
                CYCLE_3: cycle = CYCLE_4;
                CYCLE_5: cycle = CYCLE_6;
                CYCLE_7: cycle = extended_cycle? CYCLE_8 : CYCLE_0;
                CYCLE_9: cycle = CYCLE_10;
                CYCLE_11: cycle = CYCLE_0;
            endcase
           
        /*else case(cycle)
            CYCLE_0: cycle <= CYCLE_1;
            CYCLE_1: cycle <= CYCLE_2;
            CYCLE_2: cycle <= CYCLE_3;
            CYCLE_3: cycle <= CYCLE_4;
            CYCLE_4: cycle <= CYCLE_5;
            CYCLE_5: cycle <= CYCLE_6;
            CYCLE_6: cycle <= CYCLE_7;
            CYCLE_7: cycle <= extended_cycle? CYCLE_8 : CYCLE_0;
            CYCLE_8: cycle <= CYCLE_9;
            CYCLE_9: cycle <= CYCLE_10;
            CYCLE_10: cycle <= CYCLE_11;
            CYCLE_11: cycle <= CYCLE_0;
            default: cycle <= CYCLE_0;
        endcase */
        
    always @ (cycle)
        case(cycle)
            CYCLE_0: r = 1'b0;
            CYCLE_1: r = 1'b1;
            CYCLE_2: r = 1'b1;
            CYCLE_3: r = 1'b0;
            CYCLE_4: r = 1'b0;
            CYCLE_5: r = 1'b1;
            CYCLE_6: r = 1'b1;
            CYCLE_7: r = 1'b0;
            CYCLE_8: r = 1'b0;
            CYCLE_9, CYCLE_10: case (operator_group)
                `GROUP_REG_MEMORY: r = !operator[2];
                `GROUP_STACK: r = operator == `OP_POP;
                `GROUP_RETURN: r = 1'b1;
                `GROUP_EXTENDED: r = operator == `OP_JMP || operator == `OP_CALL;
            endcase
            CYCLE_11: r = 1'b0;
        endcase
        
    always @ (cycle)
        case(cycle)
            CYCLE_9, CYCLE_10: case (operator_group)
                `GROUP_REG_MEMORY: w = operator[2];
                `GROUP_STACK: w = operator == `OP_PUSH;
                default: w = 1'b0;
            endcase
            default: w = 1'b0;
        endcase
        
    always @ (cycle or operator_group or operator)
        case (cycle)
            CYCLE_0: begin
                cs = `CS_OUT_PC | `CS_INC | `CS_IN_ADDR;
            end
            CYCLE_1: begin
                cs = `CS_OUT_INC_DEC | `CS_IN_PC;
            end
            CYCLE_2: begin
                cs = 0;
                word[7:0] = data_bus;
            end
            CYCLE_4: begin
                cs = `CS_OUT_PC | `CS_INC | `CS_IN_ADDR;
            end
            CYCLE_5: begin
                cs = `CS_OUT_INC_DEC | `CS_IN_PC;
            end
            CYCLE_6: begin
                word[15:8] = data_bus;
                cs_decoder = 1;
                case (operator_group)
                    `GROUP_SINGLE_REG, `GROUP_MATH_CONSTANT, `GROUP_MATH_REG: begin
                        cs = `CS_OUT_PC | `CS_OUT_RG1 | `CS_OUT_RG2 | `CS_IN_ALU8;
                    end
                    default: begin
                        cs = `CS_OUT_PC ;
                    end
                endcase  
            end
            CYCLE_7: begin
                cs_decoder = 0;
                case (operator_group)
                    `GROUP_SINGLE_REG, `GROUP_MATH_CONSTANT, `GROUP_MATH_REG: begin
                        cs = (`CS_OUT_ALU8 | `CS_IN_RG1 |
                              `CS_OUT_FLAGS_ALU8 | `CS_IN_FLAGS);
                    end
                    `GROUP_BRANCH_JUMPS: begin
                        cs = check_branch ? `CS_NEW_PC | `CS_IN_PC : 0;
                    end
                endcase
            end
            CYCLE_8: begin
                case (operator_group)
                    `GROUP_REG_MEMORY: begin
                        case (operator[1:0])
                            2'b01: cs = `CS_OUT_RG1 | `CS_IN_DATA | `CS_WRITE | `CS_OUT_ERG2 | `CS_IN_ADDR | `CS_INC;
                            2'b10: cs = `CS_OUT_RG1 | `CS_IN_DATA | `CS_WRITE | `CS_OUT_ERG2 | `CS_IN_ADDR | `CS_DEC;
                            default: cs = `CS_OUT_RG1 | `CS_IN_DATA  | `CS_WRITE | `CS_OUT_ERG2 | `CS_IN_ADDR; 
                        endcase
                    end
                endcase
            end
            CYCLE_9: begin
                case (operator_group)
                    `GROUP_REG_MEMORY: begin
                        case (operator[1:0])
                            2'b01, 2'b10: cs = `CS_WRITE | `CS_IN_ERG2;
                            default: cs = `CS_WRITE;
                        endcase
                    end
                endcase
            end
            CYCLE_10: begin
                case (operator_group)
                    `GROUP_REG_MEMORY: begin
                        cs = `CS_WRITE;
                    end
                endcase
            end
            CYCLE_11: begin
                case (operator_group)
                    `GROUP_REG_MEMORY: begin
                        cs = 0;
                    end
                endcase
            end
        endcase
    
endmodule
