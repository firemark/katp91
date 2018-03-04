module Ram(clk, data_bus, address_bus, enable, write, read);
    parameter RAM_BUS_SIZE = 12;
    parameter RAM_SIZE = (2 << RAM_BUS_SIZE) - 1;

    inout [7:0] data_bus;
    input [RAM_BUS_SIZE - 1:0] address_bus;
    input enable, write, read;
    input clk;
    
    (* ram_style="block" *)
    reg [7:0] store[RAM_SIZE - 1:0] /* verilator public_flat */;
    reg [7:0] data_bus_out;

    assign data_bus = read ? data_bus_out: 8'bz;
    
    initial $readmemh("../bootloader.dat", store);

    always @(posedge clk)
        if (enable)
            if (write)
                store[address_bus] <= data_bus;
            else
                data_bus_out <= store[address_bus];
        
endmodule
