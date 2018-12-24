`include "cpu_data.v"

module Alu(single, value1, value2, operator, bus_out, alu_flags, alu_flags8, old_carry);
    input single;
    input [15:0] value1, value2;
    input [3:0] operator;
    input old_carry;

    reg carry; wire overflow, zero, negative;
    wire carry8, overflow8, zero8, negative8;
    output [3:0] alu_flags;
    output [3:0] alu_flags8;
    
    output reg [15:0] bus_out;
    
    assign overflow = value1[15] ^ bus_out[15];
    assign zero = ~|bus_out;
    assign negative = bus_out[15];
    assign alu_flags = {carry, overflow, zero, negative};
    
    assign carry8 = bus_out[8];
    assign overflow8 = value1[7] ^ bus_out[7];
    assign zero8 = ~|bus_out[7:0];
    assign negative8 = bus_out[7];
    assign alu_flags8 = {carry8, overflow8, zero8, negative8};
    
    initial carry = 1'b0;
    initial bus_out = 16'b0;
    
    always @* begin
        if (!single)
            (* parallel_case *) case(operator)
                `OP_ADD: {carry, bus_out} = {1'b0, value1} + {1'b0, value2};
                `OP_SUB, `OP_CMP: {carry, bus_out} = {1'b0, value1} - {1'b0, value2};
                `OP_ADC: {carry, bus_out} = {1'b0, value1} + {1'b0, value2} + {15'b0, old_carry};
                `OP_SBC: {carry, bus_out} = {1'b0, value1} - {1'b0, value2} - {15'b0, old_carry};
                `OP_AND: bus_out = value1 & value2;
                `OP_OR: bus_out = value1 | value2;
                `OP_XOR: bus_out = value1 ^ value2;
                `OP_MOV: bus_out = value2;
                default: bus_out = 16'hAAAA;
            endcase
        else
            (* parallel_case *) case (operator)
                `OP_NEG: bus_out = 16'h0000 - value1;
                `OP_COM: bus_out = 16'hFFFF - value1;
                `OP_LSL: {carry, bus_out} = {value1, 1'b0};
                `OP_LSR: {bus_out, carry} = {1'b0, value1};
                `OP_ROL: bus_out = {value1[14:0], value1[15]};
                `OP_ROR: bus_out = {value1[0], value1[15:1]};
                `OP_RLC: {carry, bus_out} = {value1, old_carry};
                `OP_RRC: {bus_out, carry} = {old_carry, value1};
                `OP_INC: {carry, bus_out} = {1'b0, value1} + {1'b0, 16'h01};
                `OP_DEC: {carry, bus_out} = {1'b0, value1} - {1'b0, 16'h01};
                default: bus_out = 16'h0000;
            endcase
    end
        
endmodule
