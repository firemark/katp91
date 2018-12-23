`include "cpu_data.v"

module CheckBranch(operator, flags, is_checked);
    input [7:0] flags;
    input [3:0] operator;
    output reg is_checked;
    
    wire carry, overflow, zero, negative;
    assign carry = flags[3];
    assign overflow = flags[2];
    assign zero = flags[1];
    assign negative = flags[0];
    
    always @*
        case (operator)
            `OP_BREQ: is_checked = zero;
            `OP_BRNE: is_checked = ~zero;
            `OP_BRLT: is_checked = negative ^ overflow;
            `OP_BRGE: is_checked = ~(negative ^ overflow);
            `OP_BRC: is_checked = carry;
            `OP_BRNC: is_checked = ~carry;
            `OP_BRO: is_checked = overflow;
            `OP_BRNO: is_checked = ~overflow;
            `OP_BRN: is_checked = negative;
            `OP_BRNN: is_checked = ~negative;
            `OP_RJMP: is_checked = 1'b1;
            default: is_checked = 1'b0;
        endcase
endmodule
