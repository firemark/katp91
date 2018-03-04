`include "cpu_data.v"

module Alu8(clk, cs_in, cs_out, single, value1, value2, operator, bus_in, check_branch);
    input clk;
    input cs_in, cs_out, single;
    output reg check_branch;
    input [7:0] value1, value2;
    input [3:0] operator;

    reg old_sign, carry, overflow, zero, negative;
    reg [7:0] result;
        
    output [7:0] bus_in;
    assign bus_in = cs_out? result : 8'bz;
    
    always @(posedge clk)
        if (cs_in) begin
            old_sign = value1[7];
            if (!single)
                case(operator)
                    `OP_ADD: {carry, result} = {1'b0, value1} + {1'b0, value2};
                    `OP_SUB, `OP_CMP: {carry, result} = {1'b0, value1} - {1'b0, value2};
                    `OP_ADC: {carry, result} = {1'b0, value1} + {1'b0, value2} + {7'b0, carry};
                    `OP_SBC: {carry, result} = {1'b0, value1} - {1'b0, value2} - {7'b0, carry};
                    `OP_AND: result = value1 & value2;
                    `OP_OR: result = value1 | value2;
                    `OP_XOR: result = value1 ^ value2;
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
        
    always @(operator or zero or negative or overflow or carry)
        case (operator)
            `OP_BREQ: check_branch = zero;
            `OP_BRNE: check_branch = ~zero;
            `OP_BRLT: check_branch = negative ^ overflow;
            `OP_BRGE: check_branch = ~(negative ^ overflow);
            `OP_BRC: check_branch = carry;
            `OP_BRNC: check_branch = ~carry;
            `OP_BRO: check_branch = overflow;
            `OP_BRNO: check_branch = ~overflow;
            `OP_BRN: check_branch = negative;
            `OP_BRNN: check_branch = ~negative;
            `OP_BRLO: check_branch = carry;
            `OP_BRSH: check_branch = ~carry;
            `OP_RJMP: check_branch = 1'b1;
            default: check_branch = 1'b0;
        endcase
endmodule
