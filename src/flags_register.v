`include "cpu_data.v"

module FlagsRegister(clk, cs_in, operator, bus_in, check_branch);
    input clk, cs_in;
    input [3:0] operator, bus_in;
    output reg check_branch;
    reg [3:0] flags;

    wire carry, overflow, zero, negative;
    assign carry = flags[0];
    assign overflow = flags[1];
    assign zero = flags[2];
    assign negative = flags[3];
    
    initial flags = 4'h0;
    
    always @ (posedge clk)
        if (cs_in)
            flags = bus_in;
    


endmodule
