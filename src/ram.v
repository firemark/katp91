`define RAM_BUS_SIZE 15
`define RAM_SIZE ((2 << `RAM_BUS_SIZE - 1) - 1)

module Ram(data_bus, address_bus, w, r);
    inout reg[7:0] data_bus;
    input bit[`RAM_BUS_SIZE - 1:0] address_bus;
    input bit r, w;
    byte store[0:`RAM_SIZE] /* verilator public */ /* verilator public_flat */;

    always @(posedge r) begin
        $display("%h -> %h", address_bus, data_bus);
        data_bus = store[address_bus];
    end
    always @(posedge w) begin
        store[address_bus] = data_bus;
    end
    always @(negedge r) begin
        data_bus = 8'bz;
    end
endmodule
