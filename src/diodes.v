module Diodes(data_bus, diodes, r);
    inout [7:0] data_bus;
    output reg [7:0] diodes;
    input r;

    always @(posedge r)
        diodes <= data_bus;
endmodule
