`include "cpu_data.v"
`include "cpu_cs.v"

`define CS_ON(x) (|(cs & x))

module Cpu(clk, reset, data_bus, address_bus, r, w, halt);
    input clk /*verilator clocker*/;
    wire inv_clk; assign inv_clk = !clk;
    input reset;
    inout [7:0] data_bus;
    output [15:0] address_bus;
    output reg r, w;
    output reg halt;

    reg [31:0] cs;
    
    parameter [16:0]
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
        for(i=0; i < 8; i = i + 1) begin
            Register8 register8(
                .clk(inv_clk),
                .cs_in(
                    `CS_ON(`CS_IN_RG1) && out_rg1 == i ||
                    `CS_ON(`CS_IN_RG2) && out_rg2 == i),
                .cs1(`CS_ON(`CS_OUT_RG1) && out_rg1 == i),
                .cs2(`CS_ON(`CS_OUT_RG2) && out_rg2 == i),
                .bus_in(bus_in[7:0]),
                .bus_out1(bus_out1[7:0]),
                .bus_out2(bus_out2[7:0]));
        end
    endgenerate

    generate
        for(i=0; i < 4; i = i + 1) begin
            DoubleRegister8 double_register8(
                .clk(inv_clk),
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
        end
    endgenerate
    
    Register16 address_register(inv_clk, `CS_ON(`CS_IN_ADDR), 1'b1, bus_out2, address_bus);
    
    DataRegister data_register(
        .cs_write(`CS_ON(`CS_WRITE)),
        .cs_read(`CS_ON(`CS_READ)),
        .bus_in(bus_out1[7:0]),
        .bus_out(bus_in[7:0]),
        .bus_data(data_bus));
    
    Register16 pc_register(
        .clk(inv_clk),
        .cs_in(`CS_ON(`CS_IN_PC)),
        .cs_out(`CS_ON(`CS_OUT_PC)),
        .bus_in(bus_in),
        .bus_out(bus_out2));
    
    IncRegister16 inc_register(
        .clk(inv_clk),
        .cs_inc(`CS_ON(`CS_INC)),
        .cs_dec(`CS_ON(`CS_DEC)),
        .cs_out(`CS_ON(`CS_OUT_INC_DEC)),
        .bus_in(bus_out2),
        .bus_out(bus_in));
        
    reg [15:0] word;
    wire [7:0] val;
    wire [3:0] operator;
    wire [3:0] operator_group;
    wire extended_cycle;
    Decoder decoder(
        .clk(clk),
        .cs(`CS_ON(`CS_DECODER)),
        .cs_new_pc(`CS_ON(`CS_NEW_PC)),
        .word(word),
        .operator_group(operator_group),
        .operator(operator),
        .extended_cycle(extended_cycle),
        .val(val),
        .pc(bus_in),
        .new_out_pc(bus_out2),
        .rg1(out_rg1),
        .rg2(out_rg2));
    
    wire check_branch;
    Alu8 alu8(
        .clk(inv_clk),
        .cs_in(`CS_ON(`CS_IN_ALU8)),
        .cs_out(`CS_ON(`CS_OUT_ALU8)),
        .single(operator_group == `GROUP_SINGLE_REG),
        .value1(bus_out1[7:0]),
        .value2(operator_group == `GROUP_MATH_CONSTANT ? val : bus_out2[7:0]),
        .operator(operator),
        .bus_in(bus_in[7:0]),
        .check_branch(check_branch));
    
    initial begin
        halt = 0;
        cycle = CYCLE_0;
        cs = 0;
    end


    always @ (posedge clk or posedge reset)
        if (reset)
            cycle <= CYCLE_0;
        else case(cycle)
            CYCLE_0: cycle <= CYCLE_1;
            CYCLE_1: cycle <= CYCLE_2;
            CYCLE_2: cycle <= CYCLE_3;
            CYCLE_3: cycle <= CYCLE_4;
            CYCLE_4: cycle <= CYCLE_5;
            CYCLE_5: cycle <= CYCLE_0;
            default: cycle <= CYCLE_0;
        endcase 
        
    always @ (cycle or operator_group or operator)
        case(cycle)
            CYCLE_1, CYCLE_3: r = 1'b1;
            CYCLE_5: case (operator_group)
                `GROUP_REG_MEMORY: r = !operator[2];
                `GROUP_STACK: r = operator == `OP_POP;
                `GROUP_RETURN: r = 1'b1;
                `GROUP_EXTENDED: r = operator == `OP_JMP || operator == `OP_CALL;
                default: r = 1'b0;
            endcase
            default: r = 1'b0;
        endcase
        
    always @ (cycle or operator_group or operator)
        case(cycle)
            CYCLE_5: case (operator_group)
                `GROUP_REG_MEMORY: w = operator[2];
                `GROUP_STACK: w = operator == `OP_PUSH;
                default: w = 1'b0;
            endcase
            default: w = 1'b0;
        endcase
    
    always @ (posedge inv_clk) begin
        case (cycle)
            CYCLE_1: word[7:0] <= data_bus;
            CYCLE_3: word[15:8] <= data_bus;
        endcase
    end
        
    always @ (cycle or operator_group or operator or check_branch)
        case (cycle)
            CYCLE_0: begin
                if (operator_group == `GROUP_BRANCH_JUMPS && check_branch)
                    cs = `CS_NEW_PC | `CS_INC | `CS_IN_ADDR;
                else
                    cs = `CS_OUT_PC | `CS_INC | `CS_IN_ADDR;
            end
            CYCLE_1: begin
                cs = `CS_OUT_INC_DEC | `CS_IN_PC;
            end
            CYCLE_2: begin
                cs = `CS_OUT_PC | `CS_INC | `CS_IN_ADDR;
            end
            CYCLE_3: begin
                cs = `CS_OUT_INC_DEC | `CS_IN_PC | `CS_DECODER;
            end
            CYCLE_4: begin
                case (operator_group)
                    `GROUP_SINGLE_REG, `GROUP_MATH_CONSTANT, `GROUP_MATH_REG: begin
                        cs = `CS_OUT_RG1 | `CS_OUT_RG2 | `CS_IN_ALU8;
                    end
                    `GROUP_REG_MEMORY: begin
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
                    end
                    default: cs = 0;
                endcase
            end
            CYCLE_5: begin
                case (operator_group)
                    `GROUP_SINGLE_REG, `GROUP_MATH_CONSTANT, `GROUP_MATH_REG: begin
                        if (operator != `OP_CMP)
                            cs = `CS_OUT_FLAGS_ALU8 | `CS_IN_FLAGS | `CS_OUT_ALU8 | `CS_IN_RG1;
                        else
                            cs = `CS_OUT_FLAGS_ALU8 | `CS_IN_FLAGS;
                    end
                    `GROUP_REG_MEMORY: begin
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
                    end
                    default: cs = 0;
                endcase
            end
        endcase
    
endmodule
