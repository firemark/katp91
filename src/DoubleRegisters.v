module DoubleRegisters(
        clk,
        bus_in, bus_out1, bus_out2,
        num1, num2,
        cs_h_in, cs_l_in, cs_16_in,
        cs_h_out1, cs_l_out1, cs_16_out1,
        cs_h_out2, cs_l_out2, cs_16_out2);
    input [15:0] bus_in;
    output reg [15:0] bus_out1, bus_out2;
    input [1:0] num1, num2;
    input cs_h_in, cs_l_in, cs_16_in;
    input cs_h_out1, cs_l_out1, cs_16_out1;
    input cs_h_out2, cs_l_out2, cs_16_out2;
    input clk;
    
    (* ram_style="block" *)
    reg [7:0] store_h[3:0] /* verilator public_flat */;
    (* ram_style="block" *)
    reg [7:0] store_l[3:0] /* verilator public_flat */;
        
    always @ (posedge clk)
        if (cs_h_out1)
            bus_out1 <= {8'h00, store_h[num1]};
        else if (cs_l_out1)
            bus_out1 <= {8'h00, store_l[num1]};
        else if (cs_16_out1)
            bus_out1 <= {store_h[num1], store_l[num1]};
        else
            bus_out1 <= 16'bz;
            
    always @ (posedge clk)
        if (cs_h_out2)
            bus_out2 <= {8'h00, store_h[num2]};
        else if (cs_l_out2)
            bus_out2 <= {8'h00, store_l[num2]};
        else if (cs_16_out2)
            bus_out2 <= {store_h[num2], store_l[num2]};
        else
            bus_out2 <= 16'bz;  
            
    always @(posedge clk)
        if (cs_h_in)
            store_h[num1] <= bus_in[7:0];
        else if (cs_16_in) begin
            store_h[num1] <= bus_in[15:8];
        end
        
    always @(posedge clk)
        if (cs_l_in)
            store_l[num1] <= bus_in[7:0];
        else if (cs_16_in) begin
            store_l[num1] <= bus_in[7:0];
        end
        
endmodule
