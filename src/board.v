//`include "cpu.v"
//`include "gpu.v"
//`include "byte_to_rgb.v"
//`include "ram.v"

module Board(clkin, /*reset,*/ red, green, blue, led, hsync, vsync, halt);
    input clkin /*verilator clocker*/;
    reg reset = 0;

    output [2:0] red, green, blue;
    output [7:0] led;
    output hsync, vsync;
    output halt;
    
    wire [7:0] data_bus;
    wire [15:0] address_bus;
    wire clk;
    wire slow_clk;
    wire write, read;
    
    //diodes
    wire cs_diodes; assign cs_diodes = address_bus[15:12] == 4'b1001;
    Diodes diodes(data_bus, led, cs_diodes, write);

    //clock
    Dcm dcm(
		 .CLKIN_IN(clkin),
         .RST_IN(reset),
		 .CLKFX_OUT(clk),
         .CLKIN_IBUFG_OUT());
         
    //slower clock
    reg [3:0] counter;
    assign slow_clk = counter > 7;
    
    initial counter = 0;
    always @ (posedge clk) counter <= counter + 1;

    //gpu
    wire [7:0] color;
    wire cs_gpu; assign cs_gpu = address_bus[15:12] == 4'b1111;
    Gpu gpu(
        clk, reset,
        data_bus, address_bus[7:0],
        cs_gpu & write,
        cs_gpu & read,
        hsync, vsync, color);
    Byte_to_rgb byte_to_rgb(color, red, green, blue);
    
    //ram
    wire cs_ram; assign cs_ram = !address_bus[15];
    Ram ram(
        slow_clk, data_bus, address_bus[11:0],
        cs_ram, write, read);
        
    //cpu
    Cpu cpu(
        slow_clk, reset,
        data_bus,
        address_bus,
        read, write,
        halt);
        
        

endmodule