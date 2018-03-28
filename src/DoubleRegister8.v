module DoubleRegister8(
        clk,
        bus_in, bus_out,
        cs_h_in, cs_l_in, cs_16_in,
        cs_h_out, cs_l_out, cs_16_out);
    input [15:0] bus_in;
    output reg [15:0] bus_out;
    input cs_h_in, cs_l_in, cs_16_in;
    input cs_h_out, cs_l_out, cs_16_out;
    input clk;
    
    reg [7:0] data_l, data_h /* verilator public_flat */;
        
    always @ (posedge clk)
        if (cs_h_out)
            bus_out <= {8'h00, data_h};
        else if (cs_l_out)
            bus_out <= {8'h00, data_l};
        else if (cs_16_out)
            bus_out <= {data_h, data_l};
        else
            bus_out <= 16'bz;
            
    always @(posedge clk)
        if (cs_h_in)
            data_h <= bus_in[7:0];
        else if (cs_l_in)
            data_l <= bus_in[7:0];
        else if (cs_16_in) begin
            data_h <= bus_in[15:8];
            data_l <= bus_in[7:0];
        end
        
endmodule

