`include "cpu_data.v"
module Alu8(latch, single, value1, value2, operator, result, flags);
    input latch, single;
    input [7:0] value1, value2;
    input [3:0] operator;

    reg old_sign, carry, overflow, zero, negative;
    output [3:0] flags; assign flags = {carry, overflow, zero, negative};
    output reg [7:0] result;
    
    always @(posedge latch) begin
       old_sign = value1[7];
       if (!single)
           case(operator)
                `OP_ADD: {carry, result} = {1'b0, value1} + {1'b0, value2};
                `OP_SUB: {carry, result} = {1'b0, value1} - {1'b0, value2};
                `OP_ADC: {carry, result} = {1'b0, value1} + {1'b0, value2} + {7'b0, carry};
                `OP_SBC: {carry, result} = {1'b0, value1} - {1'b0, value2} - {7'b0, carry};
                `OP_AND: result = value1 & value2;
                `OP_OR: result = value1 | value2;
                `OP_XOR: result = value1 ^ value2;
                `OP_CMP: {carry, result} = {1'b0, value1} - {1'b0, value2};
                `OP_MOV: result = value2;
                default: result = 8'b0;
            endcase
        else
            case (operator)
                `OP_NEG: result = 8'h00 - value1;
                `OP_COM: result = 8'hFF - value1;
                `OP_LSL: {carry, result} = {value1, 1'b0};
                `OP_LSR: {result, carry} = {1'b0, value1};
                `OP_ROL: result = {value1[6:0], value1[7]};
                `OP_ROR: result = {value1[0], value1[7:1]};
                `OP_RLC: {carry, result} = {value1, carry};
                `OP_RRC: {result, carry} = {carry, value1};
                default: result = 8'h00;
            endcase
        overflow = old_sign ^ result[7];
        zero = &result;
        negative = result[7];
    end
endmodule
