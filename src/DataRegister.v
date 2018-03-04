module DataRegister(cs_write, cs_read, bus_in, bus_out, bus_data);
    input cs_write, cs_read;
    input [7:0] bus_in;
    output [7:0] bus_out;
    inout [7:0] bus_data;
    
    assign bus_out = cs_read? bus_data : 8'bz;
    assign bus_data = cs_write? bus_in : 8'bz;

endmodule
