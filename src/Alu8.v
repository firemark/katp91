`include "cpu_data.v"

module Alu8(clk, single, value1, value2, operator, bus_out, alu_flags, old_carry);
    input clk;
    input single;
    input [7:0] value1, value2;
    input [3:0] operator;
    input old_carry;

    reg carry, overflow, zero, negative;
    output [3:0] alu_flags;
    output reg [7:0] bus_out;
    
    assign alu_flags = {carry, overflow, zero, negative};
    
    always @(posedge clk) begin
        if (!single)
            case(operator)
                `OP_ADD: {carry, bus_out} = {1'b0, value1} + {1'b0, value2};
                `OP_SUB, `OP_CMP: {carry, bus_out} = {1'b0, value1} - {1'b0, value2};
                `OP_ADC: {carry, bus_out} = {1'b0, value1} + {1'b0, value2} + {7'b0, old_carry};
                `OP_SBC: {carry, bus_out} = {1'b0, value1} - {1'b0, value2} - {7'b0, old_carry};
                `OP_AND: bus_out = value1 & value2;
                `OP_OR: bus_out = value1 | value2;
                `OP_XOR: bus_out = value1 ^ value2;
                `OP_MOV: bus_out = value2;
                default: bus_out = 8'hA;
            endcase
        else
            case (operator)
                `OP_NEG: bus_out = 8'h00 - value1;
                `OP_COM: bus_out = 8'hFF - value1;
                `OP_LSL: {carry, bus_out} = {value1, 1'b0};
                `OP_LSR: {bus_out, carry} = {1'b0, value1};
                `OP_ROL: bus_out = {value1[6:0], value1[7]};
                `OP_ROR: bus_out = {value1[0], value1[7:1]};
                `OP_RLC: {carry, bus_out} = {value1, old_carry};
                `OP_RRC: {bus_out, carry} = {old_carry, value1};
                `OP_INC: {carry, bus_out} = {1'b0, value1} + {1'b0, 8'h01};
                `OP_DEC: {carry, bus_out} = {1'b0, value1} - {1'b0, 8'h01};
                default: bus_out = 8'h0;
            endcase
        overflow = value1[7] ^ bus_out[7];
        zero = &bus_out;
        negative = bus_out[7];
    end
        

endmodule