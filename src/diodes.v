module Diodes(data_bus, diodes, write);
    inout [7:0] data_bus;
    output reg [7:0] diodes;
    input write;

    initial begin 
        diodes = 8'b0;
    end

    always @(posedge write) begin
        $display("DIODE WRITE %b", data_bus);
        diodes <= data_bus;
    end
endmodule
