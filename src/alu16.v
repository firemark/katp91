`include "cpu_data.v"

module Alu16(value1, value2, operator, result, flags);
    input [15:0] value1, value2;
    input [3:0] operator;

    reg old_sign, carry, overflow, zero, negative;
    output [3:0] flags; assign flags = {carry, overflow, zero, negative};
    output reg [15:0] result;
    
    always @(value1 or value2 or operator) begin
       old_sign = value1[15];
       case(operator)
            `OP_ADD: {carry, result} = {1'b0, value1} + {1'b0, value2};
            `OP_SUB: {carry, result} = {1'b0, value1} - {1'b0, value2};
            `OP_ADC: {carry, result} = {1'b0, value1} + {1'b0, value2} + {16'b0, carry};
            `OP_SBC: {carry, result} = {1'b0, value1} - {1'b0, value2} - {16'b0, carry};
            `OP_AND: result = value1 & value2;
            `OP_OR: result = value1 | value2;
            `OP_XOR: result = value1 ^ value2;
            `OP_CMP: {carry, result} = {1'b0, value1} - {1'b0, value2};
            `OP_MOV: result = value2;
            default: result = 16'b0;
        endcase
        overflow = old_sign ^ result[15];
        zero = &result;
        negative = result[15];
    end
endmodule
