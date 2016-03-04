`define RAM_BUS_SIZE 14
`define RAM_SIZE (2 << RAM_BUS_SIZE)

module ram(date_bus, adress_bus, r, w);
    inout byte date_bus;
    inout bit[RAM_BUS_SIZE:0] adress_bus;
    input bit r, w;

    byte memory[RAM_SIZE:0];

    always @(r or w) begin
        if (r) begin
            date_bus = memory[adress_bus];
        end else if (w) begin
            memory[adress_bus] = date_bus;
            date_bus = 8'bz;
        end

    end

endmodule