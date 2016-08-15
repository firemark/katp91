`define BLACK_COLOR 8'b11111000
`define WHITE_COLOR 8'b11111111
`define WIDTH 800
`define HEIGHT 600

module Gpu(clk, reset, data_bus, address_bus, w, r, hs, vs, color);
    input reg clk /* verilator clocker*/;
    input reg reset;
    input bit w, r;
    inout reg[7:0] data_bus;
    output bit[11:0] address_bus;
    output reg hs, vs;
    output byte color;

    bit unsigned[9:0] row;
    bit unsigned[9:0] line;
    bit unsigned[9:0] x;
    bit unsigned[9:0] y;
    bit unsigned[3:0] move_x;
    bit unsigned[3:0] move_y;
    bit unsigned[7:0] helper;
    assign x = row + move_x - (24 + 72 + 128);
    assign y = line + move_y - (1 + 2 + 22);

    bit[3:0] pixel_sprite[2:0][2:0][7:0] /*verilator public_flat*/;
    //first index - row
    //second index - line 
    //third index - sprite
    byte color_palette[3:0][3:0] /*verilator public_flat*/;
    //first index - color
    //second index - palette
    byte sprite[7:0][7:0] /*verilator public_flat*/;
    //first index - row
    //second index - line
    bit[3:0] palette[7:0][7:0] /*verilator public_flat*/;
    //first index - row
    //second index - line

    initial begin
        row <= 0;
        line <= 0;
    end

    always @(posedge reset) begin
        row <= 0;
        line <= 0;
    end

    always @(posedge clk, negedge reset) begin
        row <= row + 1;
        if (row == 1023) begin
            line <= line + 1;
            row <= 0;
        end
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

    task draw_line;
    begin
        if (row < 24) begin
            color <= `BLACK_COLOR;
            hs <= 1'b0;
        end else if (row < 24 + 72) begin
            color <= `BLACK_COLOR;
            hs <= 1'b1;
        end else if (row < 24 + 72 + 128) begin
            color <= `BLACK_COLOR;
            hs <= 1'b0;
        end else
            draw_pixel();
    end endtask

    task draw_pixel;
    begin
        color <= color_palette[
            pixel_sprite[x[1:0]][y[1:0]][
                sprite[x[9:2]][y[9:2]]
            ]
        ][palette[x[9:2]][y[9:2]]];
    end endtask

    always @(posedge w) begin
        case (address_bus[11:8])
            4'b1111: begin
                $display("lol %b %h", address_bus, data_bus);
                //set palette color
                // A[7:4] - palette index
                // A[3:0] - color index
                // D - value of color
                color_palette[address_bus[3:0]][address_bus[7:4]] = data_bus;
            end
            4'b1110: begin 
                //set helper line
                // D - value of line
                helper = data_bus[6:0];
            end
            4'b1101: begin 
                //set sprite index
                // A[6:0] - row
                // D - sprite index
                sprite[address_bus[6:0]][helper] = data_bus;
            end
            4'b1100: begin 
                //set palette index
                // A[6:0] - row
                // D - sprite index
                palette[address_bus[6:0]][helper] = data_bus;
            end
            4'b1011: begin 
                //set two pixels in sprite
                // A[4:2] - line
                // A[1:0] - row (without first bit)
                // D[7:4] - first pixel
                // D[3:0] - second pixel
                pixel_sprite[{address_bus[1:0], 1'b0}][address_bus[4:2]][helper] = data_bus[7:4];
                pixel_sprite[{address_bus[1:0], 1'b1}][address_bus[4:2]][helper] = data_bus[3:0];
                palette[address_bus[6:0]][helper] = data_bus;
            end
            4'b1010: begin 
                //set one pixel in sprite
                // A[5:3] - line
                // A[2:0] - row
                // D[3:0] - pixel
                pixel_sprite[address_bus[2:0]][address_bus[5:3]][helper] = data_bus[3:0];
            end
        endcase
    end


endmodule