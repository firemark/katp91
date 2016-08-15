`include "cpu.v"
`include "gpu.v"
`include "byte_to_rgb.v"
`include "ram.v"

module Board(clk, reset, r, g, b, hs, vs, halt);
    input reg clk /*verilator clocker*/;
    input reg reset;
    output reg[3:0] r, g, b;
    output reg hs, vs;
    output reg halt;

    byte data_bus;
    shortint address_bus;
    bit[11:0] small_address_bus;
    bit[15:0] ram_address_bus;
    byte color;
    bit cs_gpu;
    bit cs_ram;
    bit write, read;

    //assign chip select pins
    //gpu
    assign cs_gpu = address_bus[15:12] == 4'b1111;
    assign cs_ram = ~address_bus[15];
    assign small_address_bus = address_bus[11:0];
    assign ram_address_bus = address_bus[15:0];

    Cpu cpu(
        clk, reset,
        data_bus,
        address_bus,
        write, read,
        halt);
    Gpu gpu(
        clk, reset,
        data_bus, small_address_bus,
        cs_gpu & write,
        cs_gpu & read,
        hs, vs, color); 
    Byte_to_rgb byte_to_rgb(color, r, g, b);
    Ram ram(
        data_bus, ram_address_bus,
        cs_ram & write,
        cs_ram & read);

endmodule