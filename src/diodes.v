module Diodes(data_bus, diodes, enable, write);
    inout [7:0] data_bus;
    output reg [7:0] diodes;
    input enable, write;

    initial begin 
        diodes = 8'hFF;
    end

    always @(posedge write)
        if (enable)
            diodes <= data_bus;
endmodule
