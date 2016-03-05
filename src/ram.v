`define RAM_BUS_SIZE 15
`define RAM_SIZE ((2 << `RAM_BUS_SIZE - 1) - 1)

module Ram(data_bus, address_bus, r, w);
    inout reg[7:0] data_bus;
    input bit[`RAM_BUS_SIZE - 1:0] address_bus;
    input bit r, w;
    byte store[0:`RAM_SIZE] /* verilator public_flat */;

    always @(posedge r or posedge w)
        if (w) begin
            store[address_bus] = data_bus;
        end else if (r)
            data_bus = store[address_bus];
endmodule
