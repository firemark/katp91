module Register16(clk, cs_in, cs_out, bus_in, bus_out);
    input clk, cs_in, cs_out;
    input [15:0] bus_in;
    output [15:0] bus_out;
    reg [15:0] data;
    
    assign bus_out = cs_out? data : 16'bz;
    
    parameter DEFAULT = 16'h0000;
    
    initial data = DEFAULT;
    
    always @ (posedge clk)
        if (cs_in)
            data <= bus_in;

endmodule
