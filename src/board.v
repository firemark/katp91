`include "cpu.v"
`include "gpu.v"
`include "byte_to_rgb.v"
`include "ram.v"

module Board(clk, reset, r, g, b, hs, vs, halt);
    input reg clk /* verilator clocker*/;
    input reg reset;
    output reg[3:0] r, g, b;
    output reg hs, vs;
    output reg halt;

    byte data_bus;
    shortint address_bus;
    byte color;
    bit cs_gpu, cs_gpu_w, cs_gpu_r;
    bit cs_ram, cs_ram_w, cs_ram_r;
    bit write, read;

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
        data_bus, address_bus[14:0],
        cs_ram_w,
        cs_ram_r);
    Cpu cpu(
        clk, reset,
        data_bus,
        address_bus,
        read, write,
        halt);

endmodule