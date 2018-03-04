module tester();
    reg clk;
    reg reset;

    wire [15:0] address_bus;
    wire [7:0] data_bus;

    wire [7:0] led;

    wire read, write, halt;
    
    reg [1:0] counter;
    always #1 clk=!clk;

    initial begin
        clk = 0;
        reset = 1;
        counter = 0;
        $dumpfile("dff.vcd");
        $dumpvars;
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
        clk, data_bus, address_bus[11:0],
        cs_ram, write, read);
        
    //cpu
    Cpu cpu(
        clk, reset,
        data_bus,
        address_bus,
        read, write,
        halt);
endmodule
