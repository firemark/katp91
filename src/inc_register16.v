module IncRegister16(cs_inc, cs_dec, cs_out, bus_in, bus_out);
    input cs_inc, cs_dec, cs_out;
    input [15:0] bus_in;
    output [15:0] bus_out;
    reg [15:0] data;
    
    assign bus_out = cs_out? data : 16'bz;
    
    initial data = 16'h0000;
    
    always @ (cs_inc or cs_dec or bus_in)
        if (cs_inc)
            data = bus_in + 16'h0001;
        else if (cs_dec)
            data = bus_in + 16'h0001;

endmodule
