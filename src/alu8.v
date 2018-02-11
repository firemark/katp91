`include "cpu_data.v"

module Alu8(cs_in, cs_out, cs_flags, single, value1, value2, operator, bus_in, bus_flags);
    input cs_in, cs_out, cs_flags, single;
    input [7:0] value1, value2;
    input [3:0] operator;

    reg old_sign, carry, overflow, zero, negative;
    reg [7:0] result;
        
    output [7:0] bus_in;
    output [3:0] bus_flags;
    assign bus_in = cs_out? result : 8'bz;
    assign bus_flags = cs_flags? {carry, overflow, zero, negative} : 4'bz;
    
    always @(cs_in or single or value1 or value2 or operator)
        if (cs_in) begin
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
                    default: result = 8'hAA;
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
