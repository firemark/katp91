module Board(clkin, /*reset,*/ rgb, led, segments, enable_segments, hsync, vsync);
    input clkin /*verilator clocker*/;
    reg reset;
    initial reset = 1;

    output [5:0] rgb;
    output hsync, vsync;
    wire halt;
    
    wire [15:0] data_bus;
    wire [15:0] address_bus;
    wire clk;
    wire write, read;
    
    //diodes
    output [15:0] led;
    wire cs_diodes; assign cs_diodes = address_bus[15:12] == 4'b1001;
    Diodes diodes(data_bus, led, cs_diodes, write);
    
    //led counter
    output [3:0] enable_segments;
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
    
    //assign clk = clkin;

         
    reg [3:0] counter;
    assign clk = &counter;
    
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
    wire cs_gpu; assign cs_gpu = address_bus[15:12] == 4'b1111;
    Gpu gpu(
        .clk(clk),
        .reset(reset),
        .data_bus(data_bus),
        .address_bus(address_bus[7:0]),
        .w(cs_gpu & write),
        .r(cs_gpu & read),
        .hs(hsync),
        .vs(vsync),
        .color(rgb));
    
    //ram
    wire cs_ram; assign cs_ram = !address_bus[15];
    Ram ram(
        .clk(clk),
        .data_bus(data_bus),
        .address_bus(address_bus[10:0]),
        .enable(cs_ram),
        .write(write),
        .read(read));
        
    //cpu
    Cpu cpu(
        .clk(clk),
        .reset(reset),
        .data_bus(data_bus),
        .address_bus(address_bus),
        .r(read),
        .w(write),
        .interrupts(8'b0),
        .halt(halt));
        
endmodule
