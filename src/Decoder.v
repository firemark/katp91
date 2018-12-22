`include "cpu_data.v"

module Decoder(
        word, 
        operator_group, operator,
        rgv, rg1, rg2, val, relative_addr);
    input [15:0] word;
    
    output [3:0] operator;
    output reg [3:0] operator_group;
    
    output [2:0] rgv, rg1, rg2;
    output [7:0] val;
    output [9:0] relative_addr;
    
    assign rgv = word[3:1];
    assign val = word[11:4];
    assign rg1 = word[7:5];
    assign rg2 = word[10:8];
    assign operator = word[15:12];
    assign relative_addr = word[7:0];
    
    always @ (word)
        casez (word[4:0])
            5'b0????: operator_group <= `GROUP_CRVMATH;
            5'b10???: operator_group <= `GROUP_RJMP;
            5'b11100: operator_group <= `GROUP_CRRMATH;
            5'b11110: operator_group <= `GROUP_CRSMATH;
            5'b11101: casez(operator)
                4'b1011: operator_group <= `GROUP_WRRMATH;
                4'b1111: operator_group <= `GROUP_WRRMATH;
                4'b1???: operator_group <= `GROUP_WRRMATH_MEM;
                default: operator_group <= `GROUP_WRRMATH;
            endcase
            5'b11111: casez(operator[2:0])
                3'b111: operator_group <= `GROUP_WRSMATH_STACK;
                default: operator_group <= `GROUP_WRSMATH;
            endcase
            5'b11000: operator_group <= `GROUP_SFLAG;
            5'b11001: operator_group <= `GROUP_UFLAG;
            5'b11011: operator_group <= `GROUP_SPECIAL;
        endcase

endmodule
