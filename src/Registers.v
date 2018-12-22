module Registers(clk, bus_in, write, bus_out1, bus_out2, num1, num2);
    input [15:0] bus_in;
    output [15:0] bus_out1, bus_out2;
    input [3:0] num1, num2;
    input [1:0] write;
    input clk;
    
    (* ram_style="block" *)
    reg [15:0] store[15:0] /* verilator public_flat */;

    assign bus_out1 = !write ? store[num1] : 16'bz;
    assign bus_out2 = !write ? store[num2] : 16'bz;
    
    always @(posedge clk)
        if (write[0])
            store[num1] <= bus_in;
        else if (write[1])
            store[num2] <= bus_in;
        
endmodule
