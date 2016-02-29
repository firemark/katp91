`include "cpu.v"
`include "gpu.v"
`include "byte_to_rgb.v"
`include "ram.v"

module board(clk, reset, r, g, b, hs, vs, halt) begin
    input reg clk;
    input reg reset;
    output reg[3:0] r, g, b;
    output reg hs, vs;
    output reg halt;

    byte data_bus;
    shortint address_bus;
    byte color;
    bit select_gpu = address_bus[15:13] == 2'b01;
    bit write, read;

    gpu(
        clk, reset, color,
        data_bus, address_bus[8:0],
        select_gpu & write,
        select_gpu & read,
        hs, vs);
    byte_to_rgb(color, r, g, b);
    cpu(
        clk, reset,
        data_bus,
        address_bus,
        read, write,
        halt
    );

end