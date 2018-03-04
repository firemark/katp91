module Register8(clk, cs_in, cs1, cs2, bus_in, bus_out1, bus_out2);
    input clk, cs_in, cs1, cs2;
    input [7:0] bus_in;
    output [7:0] bus_out1, bus_out2;
    reg [7:0] data;
    
    assign bus_out1 = cs1? data : 8'bz;
    assign bus_out2 = cs2? data : 8'bz;
    
    initial data = 8'h00;
    
    always @ (posedge clk)
        if (cs_in)
            data <= bus_in;

endmodule
