module IntAddrs(clk, ints, int_address, clr_int, cauch_int, reset);
    input clk;
    input [7:0] ints;
    input reset;
    input clr_int;
    
    reg [7:0] tmp_ints;
    output reg [15:0] int_address;
    output reg cauch_int;
    wire has_ints;
    
    assign has_ints = |ints;

    always @(posedge reset or posedge has_ints or posedge clr_int) begin
        if (reset)
            tmp_ints <= 8'h00;
        else if (clr_int) begin
            if (tmp_ints[7]) tmp_ints[7] <= 0;
            else if (tmp_ints[6]) tmp_ints[6] <= 0;
            else if (tmp_ints[5]) tmp_ints[5] <= 0;
            else if (tmp_ints[4]) tmp_ints[4] <= 0;
            else if (tmp_ints[3]) tmp_ints[3] <= 0;
            else if (tmp_ints[2]) tmp_ints[2] <= 0;
            else if (tmp_ints[1]) tmp_ints[1] <= 0;
            else if (tmp_ints[0]) tmp_ints[0] <= 0;
       end else begin 
            if (ints[7]) tmp_ints[7] <= 1;
            else if (ints[6]) tmp_ints[6] <= 1;
            else if (ints[5]) tmp_ints[5] <= 1;
            else if (ints[4]) tmp_ints[4] <= 1;
            else if (ints[3]) tmp_ints[3] <= 1;
            else if (ints[2]) tmp_ints[2] <= 1;
            else if (ints[1]) tmp_ints[1] <= 1;
            else if (ints[0]) tmp_ints[0] <= 1;
       end
    end
    
    always @(posedge reset or posedge clk)
        if (reset)
            cauch_int = 0;
        else
            cauch_int = |tmp_ints;
        

    always @(tmp_ints)
        casez(tmp_ints)
            8'b1???????: int_address <= 16'h0040;
            8'b01??????: int_address <= 16'h0080;
            8'b001?????: int_address <= 16'h00C0;
            8'b0001????: int_address <= 16'h0100;
            8'b00001???: int_address <= 16'h0140;
            8'b000001??: int_address <= 16'h0180;
            8'b0000001?: int_address <= 16'h01C0;
            8'b00000001: int_address <= 16'h0200;
            default: int_address <= 16'h0000;
        endcase

endmodule
