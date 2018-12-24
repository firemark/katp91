module LedCounter(clk, data_bus, enable, write, segments, enable_segments);
    inout [15:0] data_bus;
    output [7:0] segments;
    output reg [3:0] enable_segments;
    reg [3:0] digits [3:0];
    reg [6:0] counter;
    input clk, enable, write;

    initial begin
        digits[0] = 4'h0;
        digits[1] = 4'h0;
        digits[2] = 4'h0;
        digits[3] = 4'h0;
        counter = 0;
    end
    
    Digit dd(digits[counter[6:5]], segments);

    always @(posedge write)
        if (enable) begin
            digits[0] <= data_bus[3:0];
            digits[1] <= data_bus[7:4];
            digits[2] <= data_bus[11:8];
            digits[3] <= data_bus[15:12];
        end
            
    always @(posedge clk)
        counter <= counter + 1;
        
    always @(counter)
        case (counter[6:4])
            3'b000: enable_segments = 4'b1110;
            3'b010: enable_segments = 4'b1101;
            3'b100: enable_segments = 4'b1011;
            3'b110: enable_segments = 4'b0111;
            default: enable_segments = 4'b1111;
        endcase
        
endmodule

module Digit(digit, real_segments);
    input [3:0] digit;
    output [7:0] real_segments;
    reg [7:0] segments;
    
    assign real_segments = ~segments;
    
    always @(digit)
        case (digit)
            4'h0: segments = 8'b11111100;
            4'h1: segments = 8'b01100000;
            4'h2: segments = 8'b11011010;
            4'h3: segments = 8'b11110010;
            4'h4: segments = 8'b01100110;
            4'h5: segments = 8'b10110110;
            4'h6: segments = 8'b10111110;
            4'h7: segments = 8'b11100000;
            4'h8: segments = 8'b11111110;
            4'h9: segments = 8'b11110110;
            4'hA: segments = 8'b11101110;
            4'hB: segments = 8'b00111110;
            4'hC: segments = 8'b10011100;
            4'hD: segments = 8'b01111010;
            4'hE: segments = 8'b10011110;
            4'hF: segments = 8'b10001110;
        endcase
    
endmodule
