`include "cpu_data.v"

module CheckBranch(
        operator, check_branch, flags);
    input [3:0] operator, flags;
    output reg check_branch;
    
    wire carry, overflow, zero, negative;
    assign carry = flags[0];
    assign overflow = flags[1];
    assign zero = flags[2];
    assign negative = flags[3];
    
    always @(operator)
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
