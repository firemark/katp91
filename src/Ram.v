module Ram(clk, data_bus, address_bus, enable, write, read);
    parameter RAM_BUS_SIZE = 11;
    parameter RAM_SIZE = 1 << RAM_BUS_SIZE;

    inout [15:0] data_bus;
    input [RAM_BUS_SIZE - 1:0] address_bus;
    input enable, write, read;
    input clk;
    
    (* ram_style="block" *)
    reg [15:0] store[RAM_SIZE - 1:0] /* verilator public_flat */;
    reg [15:0] data_bus_out;

    assign data_bus = read ? data_bus_out: 16'bz;
    
    initial $readmemh("../bootloader.dat", store);

    always @(posedge clk)
        if (enable)
            if (write)
                store[address_bus] <= data_bus;
            else
                data_bus_out <= store[address_bus];
        
endmodule
