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

    wire [35:0] cs;
    
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
    reg [3:0] cycle  /*verilator public*/;
    
    reg [7:0] data_bus_out;
    
    wire [15:0] bus_out1, bus_out2, bus_in;
    wire [3:0] in_rg, out_rg1, out_rg2;

    Registers registers(
        .clk(inv_clk),
        .cs_in(`CS_ON(`CS_IN_RG1) && !out_rg1[3]),
        .cs_out1(`CS_ON(`CS_OUT_RG1) && !out_rg1[3]),
        .cs_out2(`CS_ON(`CS_OUT_RG2) && !out_rg2[3]),
        .num1(out_rg1[2:0]),
        .num2(out_rg2[2:0]),
        .bus_in(bus_in[7:0]),
        .bus_out1(bus_out1[7:0]),
        .bus_out2(bus_out2[7:0]));

    /*genvar i;
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
    endgenerate*/
    
    DoubleRegisters double_registers(
        .clk(inv_clk),
        .num1(out_rg1[2:1]),
        .num2(out_rg2[2:1]),
        .cs_h_in(`CS_ON(`CS_IN_RG1) && out_rg1[3] && out_rg1[0]),
        .cs_l_in(`CS_ON(`CS_IN_RG1) && out_rg1[3] && !out_rg1[0]),
        .cs_16_in(`CS_ON(`CS_IN_ERG1)),
        .cs_h_out1(`CS_ON(`CS_OUT_RG1) && out_rg1[3] && out_rg1[0]),
        .cs_l_out1(`CS_ON(`CS_OUT_RG1) && out_rg1[3] && !out_rg1[0]),
        .cs_16_out1(`CS_ON(`CS_OUT_ERG1)),
        .cs_h_out2(`CS_ON(`CS_OUT_RG2) && out_rg2[3] && out_rg2[0]),
        .cs_l_out2(`CS_ON(`CS_OUT_RG2) && out_rg2[3] && !out_rg2[0]),
        .cs_16_out2(`CS_ON(`CS_OUT_ERG2)),
        .bus_in(bus_in),
        .bus_out1(bus_out1),
        .bus_out2(bus_out2));
    
    Register16 address_register(inv_clk, `CS_ON(`CS_IN_ADDR), 1'b1, bus_out2, address_bus);
    
    DataRegister data_register(
        .cs_write(`CS_ON(`CS_WRITE)),
        .cs_read(`CS_ON(`CS_READ)),
        .bus_in(bus_out1[7:0]),
        .bus_out(bus_in[7:0]),
        .bus_data(data_bus));
    
    DoubleRegister8 pc_register(
        .clk(inv_clk),
        .cs_16_in(`CS_ON(`CS_IN_PC)),
        .cs_16_out(`CS_ON(`CS_OUT_PC)),
        .cs_h_in(`CS_ON(`CS_IN_PC_H)),
        .cs_h_out(`CS_ON(`CS_OUT_PC_H)),
        .cs_l_in(`CS_ON(`CS_IN_PC_L)),
        .cs_l_out(`CS_ON(`CS_OUT_PC_L)),
        .bus_in(bus_in),
        .bus_out(bus_out2));
        
    DoubleRegister8 wd_register(
        .clk(inv_clk),
        .cs_16_in(`CS_ON(`CS_IN_WD)),
        .cs_16_out(`CS_ON(`CS_OUT_WD)),
        .cs_h_in(`CS_ON(`CS_IN_WD_H)),
        .cs_h_out(`CS_ON(`CS_OUT_WD_H)),
        .cs_l_in(`CS_ON(`CS_IN_WD_L)),
        .cs_l_out(`CS_ON(`CS_OUT_WD_L)),
        .bus_in(bus_in),
        .bus_out(bus_out2));
        
    Register16 #(16'h0FFF) sp_register(
        .clk(inv_clk),
        .cs_in(`CS_ON(`CS_IN_SP)),
        .cs_out(`CS_ON(`CS_OUT_SP)),
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
    end
    
    CsDecoder cs_decoder(
        .reset(reset),
        .cs(cs),
        .cycle(cycle),
        .operator(operator),
        .operator_group(operator_group),
        .check_branch(check_branch)
    );


    always @ (posedge clk or posedge reset)
        if (reset)
            cycle <= CYCLE_0;
        else case(cycle)
            CYCLE_0: cycle <= CYCLE_1;
            CYCLE_1: cycle <= CYCLE_2;
            CYCLE_2: cycle <= CYCLE_3;
            CYCLE_3: cycle <= CYCLE_4;
            CYCLE_4: cycle <= CYCLE_5;
            CYCLE_5: cycle <= extended_cycle? CYCLE_6: CYCLE_0;
            CYCLE_6: cycle <= CYCLE_7;
            CYCLE_7: cycle <= CYCLE_8;
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
        
    
    
endmodule
