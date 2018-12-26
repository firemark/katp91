module Buttons(data_bus, enable, interrupt, buttons);
    output [15:0] data_bus;
    input enable;
    output interrupt;
    
    input [4:0] buttons;
    
    reg [4:0] reg_buttons;
    
    assign data_bus = enable ? {11'b0, reg_buttons} : 16'bz;
    assign interrupt = |buttons;
    
    always @(posedge interrupt or negedge enable)
        if (interrupt)
            reg_buttons = reg_buttons | buttons;
        else
            reg_buttons = 5'b0;

endmodule
