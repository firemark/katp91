`include "cpu_data.v"

module SetFlager(latch, operator, in_flags, flags);
    input latch;
    input [3:0] operator;
    input [3:0] in_flags;

    wire carry, overflow, zero, negative;
    output reg [3:0] flags;
    //assign flags = {carry, overflow, zero, negative};
    
    always @ (latch) begin
        flags = in_flags;
        case(operator)
            //`OP_HLT: begin halt = 1; $finish; end
            `OP_CLC: flags[0] = 1'b0;
            `OP_CLO: flags[1] = 1'b0;
            `OP_CLZ: flags[2] = 1'b0;
            `OP_CLN: flags[3] = 1'b0;
            `OP_STC: flags[0] = 1'b1;
            `OP_STO: flags[1] = 1'b1;
            `OP_STZ: flags[2] = 1'b1;
            `OP_STN: flags[3] = 1'b1;
            default: flags[2] = 1'b1;
        endcase
    end

endmodule
