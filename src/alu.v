`include "cpu_data.v"

module Alu(
        operator, value1, value2, result, old_sign,
        carry, overflow, zero, negative, compute_signal, compute_single_signal);
    input [4:0] operator;
    input [15:0] value1;
    input [15:0] value2;
    input old_sign, compute_single_signal, compute_signal;
    output reg [15:0] result;
    output reg carry;
    output overflow, zero, negative;
    
    wire [3:0] math_operator;
    
    assign overflow = old_sign ^ result[15];
    assign zero = &result;
    assign negative = result[15];
    assign match_operator = operator[3:0];
    
    initial begin
        result <= 16'b0;
    end
    
    always @ (posedge compute_signal, posedge compute_single_signal)
        if (compute_signal)
            case(math_operator)
                `OP_ADD: {carry, result} <= {1'b0, value1} + {1'b0, value2};
                `OP_SUB: {carry, result} <= {1'b0, value1} - {1'b0, value2};
                `OP_ADC: {carry, result} <= {1'b0, value1} + {1'b0, value2} + {16'b0, carry};
                `OP_SBC: {carry, result} <= {1'b0, value1} - {1'b0, value2} - {16'b0, carry};
                `OP_AND: result <= value1 & value2;
                `OP_OR: result <= value1 | value2;
                `OP_XOR: result <= value1 ^ value2;
                `OP_CMP: {carry, result} <= {1'b0, value1} - {1'b0, value2};
                `OP_MOV: result <= value2;
                default: result <= 1'b0;
			  endcase
       else if (compute_single_signal)
            case (operator)
                `OP_NEG: result <= 16'b0 - value1;
                `OP_COM: result <= 16'hFFFF - value1;
                `OP_LSL: {carry, result} <= {value1, 1'b0};
                `OP_LSR: {result, carry} <= {1'b0, value1};
                `OP_ROL: result <= {value1[14:0], value1[15]};
                `OP_ROR: result <= {value1[0], value1[15:1]};
                `OP_RLC: {carry, result} <= {value1, carry};
                `OP_RRC: {result, carry} <= {carry, value1};
            default: result <= 16'b0;
          endcase

endmodule
