`define RAM_BUS_SIZE 15
`define RAM_SIZE ((2 << `RAM_BUS_SIZE - 1) - 1)

module Ram(data_bus, address_bus, r, w);
    inout [7:0] data_bus;
    input [`RAM_BUS_SIZE - 1:0] address_bus;
    input r, w;
    reg[7:0] store[0:`RAM_SIZE] /* verilator public_flat */;
	 
	 reg [7:0] data_bus_out;
	 assign data_bus = r ? data_bus_out: 8'bz;

    always @(posedge r or posedge w)
        if (w) begin
            store[address_bus] = data_bus;
        end else if (r)
            data_bus_out = store[address_bus];
endmodule
