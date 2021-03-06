module tester();
    reg clk;
    reg reset;
    reg [7:0] interrupts;

    wire [15:0] address_bus;
    wire [15:0] data_bus;

    wire [15:0] led;

    wire read, write, halt;
    
    reg [1:0] counter;
    always #1 clk=!clk;

    initial begin
        clk = 0;
        reset = 1;
        counter = 0;
        interrupts = 0;
        $dumpfile("dff.vcd");
        $dumpvars;
        #10 interrupts[7] = 1;
        #1 interrupts[7] = 0;
        #300 $finish;
    end
    
    always @ (posedge clk) begin
        counter <= counter + 1;
        if (&counter)
            reset <= 0;
    end
    
    wire cs_diodes; assign cs_diodes = address_bus[15:12] == 4'b1001;
    Diodes diodes(data_bus, led, cs_diodes, write);

    wire cs_ram; assign cs_ram = !address_bus[15];
    Ram ram(
        .clk(clk),
        .data_bus(data_bus),
        .address_bus(address_bus[10:0]),
        .enable(cs_ram),
        .write(write),
        .read(read));
        
    Cpu cpu(
        .clk(clk),
        .reset(reset),
        .data_bus(data_bus),
        .address_bus(address_bus),
        .r(read),
        .w(write),
        .interrupts(interrupts),
        .halt(halt));
endmodule
