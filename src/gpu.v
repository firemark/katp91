`define BLACK_COLOR 8'b11111100
`define WHITE_COLOR 8'b11111111
`define WIDTH 800
`define HEIGHT 600

module Gpu(clk, reset, data_bus, address_bus, w, r, hs, vs, color);
    input reg clk;
    input reg reset;
    input bit w, r;
    inout reg[7:0] data_bus;
    output byte address_bus;
    output reg hs, vs;
    output byte color;

    bit[9:0] row;
    bit[9:0] line;
    bit[9:0] wtf;
    bit carry;
    assign wtf = row - 24 + 72 + 128;

    initial begin
        row <= 0;
        line <= 0;
    end

    always @(posedge reset) begin
        row <= 0;
        line <= 0;
    end

    task draw_line;
    begin
        if (row < 24) begin
            color <= `BLACK_COLOR;
            hs <= 1'b0;
        end else if(row < 24 + 72) begin
            color <= `BLACK_COLOR;
            hs <= 1'b1;
        end else if(row < 24 + 72 + 128) begin
            color <= `BLACK_COLOR;
            hs <= 1'b0;
        end else
            color <= wtf[7:0];
    end endtask

    always @(posedge clk) begin
        {carry, row} <= row + 1;
        if (carry)
            line <= line + 1;
        if (line < 1) begin
            color <= `BLACK_COLOR;
            vs <= 1'b0;
        end else if (line < 1 + 2) begin
            color <= `BLACK_COLOR;
            vs <= 1'b1;
        end else if (line < 1 + 2 + 22) begin
            color <= `BLACK_COLOR;
            vs <= 1'b0;
        end else if (line < 1 + 2 + 22 + `HEIGHT) begin
            draw_line();
        end else begin
            line <= 0;
        end
    end
endmodule