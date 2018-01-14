`define BLACK_COLOR 8'b00000000
`define WHITE_COLOR 8'b11111111
`define WIDTH 640
`define HEIGHT 480

module Gpu(clk, reset, data_bus, address_bus, w, r, hs, vs, color);
    input clk /* verilator clocker*/;
    input reset;
    input w, r;
    inout [7:0] data_bus;
    input [7:0] address_bus;
    output reg hs, vs;
    output reg[7:0] color;
 
    reg [9:0] row;
    reg [9:0] line;
	 
	reg [7:0] data_bus_out;
	assign data_bus = r ? data_bus_out : 8'bz;

    initial begin
        row <= 0;
        line <= 0;
    end

    task draw_line;
    begin
        if (row < 16) begin
            color <= `BLACK_COLOR;
            hs <= 1'b0;
        end else if(row < 16 + 96) begin
            color <= `BLACK_COLOR;
            hs <= 1'b1;
        end else if(row < 24 + 96 + 48) begin
            color <= `BLACK_COLOR;
            hs <= 1'b0;
        end else
            color <= row + line;
    end endtask

    always @(posedge clk, posedge reset) begin
		  if (reset) begin
		    row <= 0;
            line <= 0;
		  end else begin
			  row <= row + 1;
			  if (row == 800) begin
					line <= line + 1;
					row <= 0;
			  end
			  if (line < 10) begin
					color <= `BLACK_COLOR;
					vs <= 1'b0;
			  end else if (line < 10 + 2) begin
					color <= `BLACK_COLOR;
					vs <= 1'b1;
			  end else if (line < 10 + 2 + 33) begin
					color <= `BLACK_COLOR;
					vs <= 1'b0;
			  end else if (line < 10 + 2 + 33 + `HEIGHT) begin
					draw_line();
			  end else begin
					line <= 0;
			  end 
		  end
    end
endmodule