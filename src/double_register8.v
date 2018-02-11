module DoubleRegister8(
        cs_l_in, cs_l_1, cs_l_2, cs_h_in, cs_h_1, cs_h_2,
        cs_16_in, cs_16_1, cs_16_2,
        bus_8_in, bus_8_out1, bus_8_out2,
        bus_16_in, bus_16_out1, bus_16_out2);
    input cs_l_in, cs_l_1, cs_l_2;
    input cs_h_in, cs_h_1, cs_h_2;
    input cs_16_in, cs_16_1, cs_16_2;
    input [7:0] bus_8_in;
    input [15:0] bus_16_in;
    output reg [7:0] bus_8_out1, bus_8_out2;
    output [15:0] bus_16_out1, bus_16_out2;
    reg [7:0] data_l, data_h;
    
    assign bus_16_out1 = cs_16_1? {data_h, data_l} : 16'bz;
    assign bus_16_out2 = cs_16_2? {data_h, data_l} : 16'bz;
    
    initial begin
        data_l = 8'h00;
        data_h = 8'h00;
    end
    
    always @ (cs_l_1 or cs_h_1 or data_l or data_h)
        if (cs_l_1)
            bus_8_out1 = data_l;
        else if (cs_h_1)
            bus_8_out1 = data_h;
        else
            bus_8_out1 = 8'bz;
            
    always @ (cs_l_2 or cs_h_2 or data_l or data_h)
        if (cs_l_2)
            bus_8_out2 = data_l;
        else if (cs_h_2)
            bus_8_out2 = data_h;
        else
            bus_8_out2 = 8'bz;
    
    always @ (cs_l_in or cs_16_in or bus_8_in or bus_16_in)
        if (cs_l_in)
            data_l = bus_8_in;
        else if (cs_16_in)
            data_l = bus_16_in[7:0];

    always @ (cs_h_in or cs_16_in or bus_8_in or bus_16_in)
        if (cs_h_in)
            data_h = bus_8_in;
        else if (cs_16_in)
            data_h = bus_16_in[15:8];

endmodule
