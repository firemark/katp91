`include "cpu_data.v"

module Alu(clk, single, value1, value2, operator, bus_out, alu_flags, check_branch);
    input clk;
    input single;
    output reg check_branch;
    input [15:0] value1, value2;
    input [3:0] operator;

    reg old_sign, carry, overflow, zero, negative;
    output alu_flags;
    output reg [15:0] bus_out;
    
    assign alu_flags = {old_sign, carry, overflow, zero, negative};
    
    always @(posedge clk) begin
        old_sign = value1[7];
        if (!single)
            case(operator)
                `OP_ADD: {carry, bus_out} = {1'b0, value1} + {1'b0, value2};
                `OP_SUB, `OP_CMP: {carry, bus_out} = {1'b0, value1} - {1'b0, value2};
                `OP_ADC: {carry, bus_out} = {1'b0, value1} + {1'b0, value2} + {15'b0, carry};
                `OP_SBC: {carry, bus_out} = {1'b0, value1} - {1'b0, value2} - {15'b0, carry};
                `OP_AND: bus_out = value1 & value2;
                `OP_OR: bus_out = value1 | value2;
                `OP_XOR: bus_out = value1 ^ value2;
                `OP_MOV: bus_out = value2;
                default: bus_out = 16'hAA;
            endcase
        else
            case (operator)
                `OP_NEG: bus_out = 16'h00 - value1;
                `OP_COM: bus_out = 16'hFF - value1;
                `OP_LSL: {carry, bus_out} = {value1, 1'b0};
                `OP_LSR: {bus_out, carry} = {1'b0, value1};
                `OP_ROL: bus_out = {value1[14:0], value1[15]};
                `OP_ROR: bus_out = {value1[0], value1[15:1]};
                `OP_RLC: {carry, bus_out} = {value1, carry};
                `OP_RRC: {bus_out, carry} = {carry, value1};
                default: bus_out = 16'h00;
            endcase
        overflow = old_sign ^ bus_out[15];
        zero = &bus_out;
        negative = bus_out[15];
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