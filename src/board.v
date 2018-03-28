module Board(clkin, /*reset,*/ red, green, blue, led, segments, enable_segments, hsync, vsync, halt);
    input clkin /*verilator clocker*/;
    reg reset;
    initial reset = 1;

    output [2:0] red, green, blue;
    output hsync, vsync;
    output halt;
    
    wire [7:0] data_bus;
    wire [15:0] address_bus;
    wire clk;
    wire write, read;
    
    //diodes
    output [7:0] led;
    wire cs_diodes; assign cs_diodes = address_bus[15:12] == 4'b1001;
    Diodes diodes(data_bus, led, cs_diodes, write);
    
    //led counter
    output [2:0] enable_segments;
    output [7:0] segments;
    wire cs_led_counter; assign cs_led_counter = address_bus[15:12] == 4'b1010;
    LedCounter led_counter(
        .clk(clk),
        .data_bus(data_bus),
        .enable(cs_led_counter),
        .write(write),
        .segments(segments),
        .enable_segments(enable_segments));

    //clock
    //Dcm dcm(
	//	 .CLKIN_IN(clkin),
    //     .RST_IN(reset),
	//	 .CLKFX_OUT(clk),
    //     .CLKIN_IBUFG_OUT());
    
    assign clk = clkin;
         
    reg [3:0] counter;
    //reg [7:0] led_counter;
    
    initial counter = 0;
    //initial led_counter = 0;
    always @ (posedge clk) begin
        counter <= counter + 1;
        if (&counter) begin
            reset <= 0;
            //led_counter <= led_counter + 1;
        end
            
    end
    
    //assign led = led_counter;

    //gpu
    wire [7:0] color;
    wire cs_gpu; assign cs_gpu = address_bus[15:12] == 4'b1111;
    Gpu gpu(
        clk, reset,
        data_bus, address_bus[7:0],
        cs_gpu & write,
        cs_gpu & read,
        hsync, vsync, color);
    assign red = color[2:0];
    assign green = color[5:3];
    assign blue = color[7:6];
    
    //ram
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
