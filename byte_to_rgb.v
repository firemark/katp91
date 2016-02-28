module byte_to_rgb(color, r, g, b);
    input byte color;
    output reg[0:3] r, g, b;
    always @(color) begin
        case(color)
8'b00000000: {r, g, b} = 9'b010010001;
8'b00000001: {r, g, b} = 9'b010010001;
8'b00000010: {r, g, b} = 9'b010010001;
8'b00000011: {r, g, b} = 9'b010010001;
8'b00000100: {r, g, b} = 9'b001010010;
8'b00000101: {r, g, b} = 9'b001010010;
8'b00000110: {r, g, b} = 9'b001010010;
8'b00000111: {r, g, b} = 9'b001010010;
8'b00001000: {r, g, b} = 9'b001010010;
8'b00001001: {r, g, b} = 9'b010001010;
8'b00001010: {r, g, b} = 9'b010001010;
8'b00001011: {r, g, b} = 9'b010001010;
8'b00001100: {r, g, b} = 9'b010001010;
8'b00001101: {r, g, b} = 9'b010001001;
8'b00001110: {r, g, b} = 9'b010001001;
8'b00001111: {r, g, b} = 9'b010010001;
8'b00010000: {r, g, b} = 9'b010010001;
8'b00010001: {r, g, b} = 9'b001010001;
8'b00010010: {r, g, b} = 9'b001010001;
8'b00010011: {r, g, b} = 9'b001010010;
8'b00010100: {r, g, b} = 9'b001010010;
8'b00010101: {r, g, b} = 9'b001010010;
8'b00010110: {r, g, b} = 9'b001001010;
8'b00010111: {r, g, b} = 9'b001001010;
8'b00011000: {r, g, b} = 9'b010001010;
8'b00011001: {r, g, b} = 9'b010001010;
8'b00011010: {r, g, b} = 9'b010001001;
8'b00011011: {r, g, b} = 9'b010001001;
8'b00011100: {r, g, b} = 9'b010001001;
8'b00011101: {r, g, b} = 9'b010010001;
8'b00011110: {r, g, b} = 9'b010010001;
8'b00011111: {r, g, b} = 9'b001010001;
8'b00100000: {r, g, b} = 9'b001010001;
8'b00100001: {r, g, b} = 9'b001010001;
8'b00100010: {r, g, b} = 9'b001010010;
8'b00100011: {r, g, b} = 9'b001001010;
8'b00100100: {r, g, b} = 9'b001001010;
8'b00100101: {r, g, b} = 9'b001001010;
8'b00100110: {r, g, b} = 9'b010001010;
8'b00100111: {r, g, b} = 9'b010001010;
8'b00101000: {r, g, b} = 9'b010001001;
8'b00101001: {r, g, b} = 9'b010001001;
8'b00101010: {r, g, b} = 9'b010001000;
8'b00101011: {r, g, b} = 9'b010010000;
8'b00101100: {r, g, b} = 9'b001010000;
8'b00101101: {r, g, b} = 9'b001010000;
8'b00101110: {r, g, b} = 9'b000010001;
8'b00101111: {r, g, b} = 9'b000010001;
8'b00110000: {r, g, b} = 9'b000010010;
8'b00110001: {r, g, b} = 9'b000001010;
8'b00110010: {r, g, b} = 9'b000000010;
8'b00110011: {r, g, b} = 9'b001000010;
8'b00110100: {r, g, b} = 9'b001000010;
8'b00110101: {r, g, b} = 9'b010000010;
8'b00110110: {r, g, b} = 9'b010000001;
8'b00110111: {r, g, b} = 9'b010000000;
8'b00111000: {r, g, b} = 9'b010001000;
8'b00111001: {r, g, b} = 9'b010010000;
8'b00111010: {r, g, b} = 9'b001010000;
8'b00111011: {r, g, b} = 9'b000010000;
8'b00111100: {r, g, b} = 9'b000010000;
8'b00111101: {r, g, b} = 9'b000010001;
8'b00111110: {r, g, b} = 9'b000010010;
8'b00111111: {r, g, b} = 9'b000001010;
8'b01000000: {r, g, b} = 9'b000000010;
8'b01000001: {r, g, b} = 9'b000000010;
8'b01000010: {r, g, b} = 9'b001000010;
8'b01000011: {r, g, b} = 9'b010000010;
8'b01000100: {r, g, b} = 9'b010000001;
8'b01000101: {r, g, b} = 9'b010000000;
8'b01000110: {r, g, b} = 9'b010001000;
8'b01000111: {r, g, b} = 9'b010010000;
8'b01001000: {r, g, b} = 9'b001010000;
8'b01001001: {r, g, b} = 9'b000010000;
8'b01001010: {r, g, b} = 9'b000010000;
8'b01001011: {r, g, b} = 9'b000010001;
8'b01001100: {r, g, b} = 9'b000010010;
8'b01001101: {r, g, b} = 9'b000001010;
8'b01001110: {r, g, b} = 9'b000000010;
8'b01001111: {r, g, b} = 9'b000000010;
8'b01010000: {r, g, b} = 9'b001000010;
8'b01010001: {r, g, b} = 9'b010000010;
8'b01010010: {r, g, b} = 9'b010000001;
8'b01010011: {r, g, b} = 9'b010000000;
8'b01010100: {r, g, b} = 9'b100100011;
8'b01010101: {r, g, b} = 9'b100100011;
8'b01010110: {r, g, b} = 9'b100100011;
8'b01010111: {r, g, b} = 9'b100100011;
8'b01011000: {r, g, b} = 9'b011100100;
8'b01011001: {r, g, b} = 9'b011100100;
8'b01011010: {r, g, b} = 9'b011100100;
8'b01011011: {r, g, b} = 9'b011100100;
8'b01011100: {r, g, b} = 9'b011100100;
8'b01011101: {r, g, b} = 9'b100011100;
8'b01011110: {r, g, b} = 9'b100011100;
8'b01011111: {r, g, b} = 9'b100011100;
8'b01100000: {r, g, b} = 9'b100011100;
8'b01100001: {r, g, b} = 9'b100011011;
8'b01100010: {r, g, b} = 9'b100011011;
8'b01100011: {r, g, b} = 9'b100100011;
8'b01100100: {r, g, b} = 9'b100100011;
8'b01100101: {r, g, b} = 9'b011100011;
8'b01100110: {r, g, b} = 9'b011100011;
8'b01100111: {r, g, b} = 9'b011100100;
8'b01101000: {r, g, b} = 9'b011100100;
8'b01101001: {r, g, b} = 9'b011100100;
8'b01101010: {r, g, b} = 9'b011011100;
8'b01101011: {r, g, b} = 9'b011011100;
8'b01101100: {r, g, b} = 9'b100011100;
8'b01101101: {r, g, b} = 9'b100011100;
8'b01101110: {r, g, b} = 9'b100011011;
8'b01101111: {r, g, b} = 9'b100011011;
8'b01110000: {r, g, b} = 9'b100011010;
8'b01110001: {r, g, b} = 9'b100100010;
8'b01110010: {r, g, b} = 9'b100100010;
8'b01110011: {r, g, b} = 9'b011100010;
8'b01110100: {r, g, b} = 9'b010100010;
8'b01110101: {r, g, b} = 9'b010100011;
8'b01110110: {r, g, b} = 9'b010100100;
8'b01110111: {r, g, b} = 9'b010011100;
8'b01111000: {r, g, b} = 9'b010010100;
8'b01111001: {r, g, b} = 9'b010010100;
8'b01111010: {r, g, b} = 9'b100010100;
8'b01111011: {r, g, b} = 9'b100010100;
8'b01111100: {r, g, b} = 9'b100010011;
8'b01111101: {r, g, b} = 9'b100010010;
8'b01111110: {r, g, b} = 9'b100010001;
8'b01111111: {r, g, b} = 9'b100100001;
8'b10000000: {r, g, b} = 9'b011100001;
8'b10000001: {r, g, b} = 9'b010100001;
8'b10000010: {r, g, b} = 9'b001100010;
8'b10000011: {r, g, b} = 9'b001100011;
8'b10000100: {r, g, b} = 9'b001100100;
8'b10000101: {r, g, b} = 9'b001011100;
8'b10000110: {r, g, b} = 9'b001001100;
8'b10000111: {r, g, b} = 9'b010001100;
8'b10001000: {r, g, b} = 9'b011001100;
8'b10001001: {r, g, b} = 9'b100001100;
8'b10001010: {r, g, b} = 9'b100001010;
8'b10001011: {r, g, b} = 9'b100001001;
8'b10001100: {r, g, b} = 9'b100010000;
8'b10001101: {r, g, b} = 9'b100100000;
8'b10001110: {r, g, b} = 9'b011100000;
8'b10001111: {r, g, b} = 9'b001100000;
8'b10010000: {r, g, b} = 9'b000100001;
8'b10010001: {r, g, b} = 9'b000100010;
8'b10010010: {r, g, b} = 9'b000100100;
8'b10010011: {r, g, b} = 9'b000011100;
8'b10010100: {r, g, b} = 9'b000001100;
8'b10010101: {r, g, b} = 9'b001000100;
8'b10010110: {r, g, b} = 9'b011000100;
8'b10010111: {r, g, b} = 9'b100000100;
8'b10011000: {r, g, b} = 9'b100000010;
8'b10011001: {r, g, b} = 9'b100000000;
8'b10011010: {r, g, b} = 9'b100010000;
8'b10011011: {r, g, b} = 9'b100100000;
8'b10011100: {r, g, b} = 9'b011100000;
8'b10011101: {r, g, b} = 9'b001100000;
8'b10011110: {r, g, b} = 9'b000100000;
8'b10011111: {r, g, b} = 9'b000100010;
8'b10100000: {r, g, b} = 9'b000100100;
8'b10100001: {r, g, b} = 9'b000010100;
8'b10100010: {r, g, b} = 9'b000000100;
8'b10100011: {r, g, b} = 9'b001000100;
8'b10100100: {r, g, b} = 9'b011000100;
8'b10100101: {r, g, b} = 9'b100000100;
8'b10100110: {r, g, b} = 9'b100000010;
8'b10100111: {r, g, b} = 9'b100000000;
8'b10101000: {r, g, b} = 9'b111110101;
8'b10101001: {r, g, b} = 9'b111110101;
8'b10101010: {r, g, b} = 9'b110111101;
8'b10101011: {r, g, b} = 9'b110111101;
8'b10101100: {r, g, b} = 9'b101111110;
8'b10101101: {r, g, b} = 9'b101111110;
8'b10101110: {r, g, b} = 9'b101111111;
8'b10101111: {r, g, b} = 9'b101110111;
8'b10110000: {r, g, b} = 9'b101110111;
8'b10110001: {r, g, b} = 9'b110101111;
8'b10110010: {r, g, b} = 9'b110101111;
8'b10110011: {r, g, b} = 9'b111101110;
8'b10110100: {r, g, b} = 9'b111101110;
8'b10110101: {r, g, b} = 9'b111101101;
8'b10110110: {r, g, b} = 9'b111101100;
8'b10110111: {r, g, b} = 9'b111110100;
8'b10111000: {r, g, b} = 9'b110111100;
8'b10111001: {r, g, b} = 9'b101111100;
8'b10111010: {r, g, b} = 9'b100111101;
8'b10111011: {r, g, b} = 9'b100111110;
8'b10111100: {r, g, b} = 9'b100111111;
8'b10111101: {r, g, b} = 9'b100110111;
8'b10111110: {r, g, b} = 9'b100100111;
8'b10111111: {r, g, b} = 9'b101100111;
8'b11000000: {r, g, b} = 9'b110100111;
8'b11000001: {r, g, b} = 9'b111100110;
8'b11000010: {r, g, b} = 9'b111100101;
8'b11000011: {r, g, b} = 9'b111100100;
8'b11000100: {r, g, b} = 9'b111101011;
8'b11000101: {r, g, b} = 9'b111110011;
8'b11000110: {r, g, b} = 9'b110111011;
8'b11000111: {r, g, b} = 9'b100111011;
8'b11001000: {r, g, b} = 9'b011111100;
8'b11001001: {r, g, b} = 9'b011111101;
8'b11001010: {r, g, b} = 9'b011111111;
8'b11001011: {r, g, b} = 9'b011101111;
8'b11001100: {r, g, b} = 9'b011011111;
8'b11001101: {r, g, b} = 9'b100011111;
8'b11001110: {r, g, b} = 9'b110011111;
8'b11001111: {r, g, b} = 9'b111011110;
8'b11010000: {r, g, b} = 9'b111011101;
8'b11010001: {r, g, b} = 9'b111011011;
8'b11010010: {r, g, b} = 9'b111100010;
8'b11010011: {r, g, b} = 9'b111110010;
8'b11010100: {r, g, b} = 9'b101111010;
8'b11010101: {r, g, b} = 9'b011111010;
8'b11010110: {r, g, b} = 9'b010111011;
8'b11010111: {r, g, b} = 9'b010111100;
8'b11011000: {r, g, b} = 9'b010111111;
8'b11011001: {r, g, b} = 9'b010101111;
8'b11011010: {r, g, b} = 9'b010010111;
8'b11011011: {r, g, b} = 9'b011010111;
8'b11011100: {r, g, b} = 9'b101010111;
8'b11011101: {r, g, b} = 9'b111010110;
8'b11011110: {r, g, b} = 9'b111010100;
8'b11011111: {r, g, b} = 9'b111010010;
8'b11100000: {r, g, b} = 9'b111011001;
8'b11100001: {r, g, b} = 9'b111110001;
8'b11100010: {r, g, b} = 9'b101111001;
8'b11100011: {r, g, b} = 9'b010111001;
8'b11100100: {r, g, b} = 9'b001111001;
8'b11100101: {r, g, b} = 9'b001111100;
8'b11100110: {r, g, b} = 9'b001111111;
8'b11100111: {r, g, b} = 9'b001100111;
8'b11101000: {r, g, b} = 9'b001001111;
8'b11101001: {r, g, b} = 9'b010001111;
8'b11101010: {r, g, b} = 9'b101001111;
8'b11101011: {r, g, b} = 9'b111001110;
8'b11101100: {r, g, b} = 9'b111001011;
8'b11101101: {r, g, b} = 9'b111001001;
8'b11101110: {r, g, b} = 9'b111011000;
8'b11101111: {r, g, b} = 9'b111110000;
8'b11110000: {r, g, b} = 9'b101111000;
8'b11110001: {r, g, b} = 9'b010111000;
8'b11110010: {r, g, b} = 9'b000111000;
8'b11110011: {r, g, b} = 9'b000111011;
8'b11110100: {r, g, b} = 9'b000111111;
8'b11110101: {r, g, b} = 9'b000100111;
8'b11110110: {r, g, b} = 9'b000000111;
8'b11110111: {r, g, b} = 9'b001000111;
8'b11111000: {r, g, b} = 9'b101000111;
8'b11111001: {r, g, b} = 9'b111000110;
8'b11111010: {r, g, b} = 9'b111000011;
8'b11111011: {r, g, b} = 9'b111000000;
8'b11111100: {r, g, b} = 9'b000000000;
8'b11111101: {r, g, b} = 9'b010010010;
8'b11111110: {r, g, b} = 9'b100100100;
8'b11111111: {r, g, b} = 9'b111111111;

        endcase
    end
endmodule