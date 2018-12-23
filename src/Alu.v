`include "cpu_data.v"

module Alu(clk, single, value1, value2, operator, bus_out, alu_flags, alu_flags8, old_carry);
    input clk;
    input single;
    input [15:0] value1, value2;
    input [3:0] operator;
    input old_carry;

    output [3:0] alu_flags;
    output [3:0] alu_flags8;
    
    wire old_carry_high;
    wire [3:0] alu_flags_high, alu_flags_low;
    
    output [15:0] bus_out;
    
    assign old_carry_high = alu_flags_low[3];
    assign alu_flags8 = alu_flags_low;
    assign alu_flags = {
        alu_flags_high[3], // carry
        alu_flags_high[2], // overflow
        alu_flags_high[1] & alu_flags_low[1], // zero
        alu_flags_high[0] // negative
    };
    
    Alu8 alu_high(
        .clk(clk),
        .single(single),
        .value1(value1[15:8]),
        .value2(value2[15:8]),
        .bus_out(bus_out[15:8]),
        .operator(operator),
        .alu_flags(alu_flags_high),
        .old_carry(old_carry_high));
        
    Alu8 alu_low(
        .clk(clk),
        .single(single),
        .value1(value1[7:0]),
        .value2(value2[7:0]),
        .bus_out(bus_out[7:0]),
        .operator(operator),
        .alu_flags(alu_flags_low),
        .old_carry(old_carry));
        
endmodule
