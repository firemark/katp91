module Registers(clk, bus_in, bus_out1, bus_out2, num1, num2, cs_in, cs_out1, cs_out2);
    input [7:0] bus_in;
    output [7:0] bus_out1, bus_out2;
    input [2:0] num1, num2;
    input cs_in;
    input cs_out1, cs_out2;
    input clk;
    
    (* ram_style="block" *)
    reg [7:0] store[7:0] /* verilator public_flat */;

    assign bus_out1 = cs_out1 ? store[num1]: 8'bz;
    assign bus_out2 = cs_out2 ? store[num2]: 8'bz;
    
    always @(posedge clk)
        if (cs_in)
            store[num1] <= bus_in;
        
endmodule
