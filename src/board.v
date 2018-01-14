//`include "cpu.v"
//`include "gpu.v"
//`include "byte_to_rgb.v"
//`include "ram.v"

module board(clk, reset, r, g, b, hs, vs, halt);
    input clk /*verilator clocker*/;
    input reset;
    output [2:0] r, g, b;
    output hs, vs;
    output halt;

    wire[7:0] data_bus;
    wire[15:0] address_bus;
    wire[7:0] color;
    wire cs_gpu, cs_gpu_w, cs_gpu_r;
    wire cs_ram, cs_ram_w, cs_ram_r;
    wire write, read;

    //assign chip select pins

    //gpu
    assign cs_gpu = address_bus[15:11] == 4'b1111;
    assign cs_gpu_w = cs_gpu & write;
    assign cs_gpu_r = cs_gpu & read;
    //ram
    assign cs_ram = ~address_bus[15];
    assign cs_ram_w = cs_ram & write;
    assign cs_ram_r = cs_ram & read;

    Gpu gpu(
        clk, reset,
        data_bus, address_bus[8:0],
        cs_gpu_w,
        cs_gpu_r,
        hs, vs, color);
    Byte_to_rgb byte_to_rgb(color, r, g, b);
    Ram ram(
        clk, data_bus, address_bus[13:0],
        cs_ram_w,
        cs_ram_r);
    Cpu cpu(
        clk, reset,
        data_bus,
        address_bus,
        read, write,
        halt);

endmodule