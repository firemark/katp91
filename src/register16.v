module Register16(cs_in, cs_out, bus_in, bus_out);
    input cs_in, cs_out;
    input [15:0] bus_in;
    output [15:0] bus_out;
    reg [15:0] data;
    
    assign bus_out = cs_out? data : 16'bz;
    
    initial data = 16'h0000;
    
    always @ (cs_in or bus_in)
        if (cs_in)
            data = bus_in;

endmodule
