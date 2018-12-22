`include "cpu_data.v"

`define CS_ON(x) (|(cs & x))

module Cpu(clk, reset, data_bus, address_bus, r, w, interrupts, halt);
    input clk /*verilator clocker*/;
    wire inv_clk; assign inv_clk = !clk;
    input reset;
    input [7:0] interrupts;
    inout [15:0] data_bus;
    output reg [15:0] address_bus;
    output reg r, w;
    output reg halt;
    
    parameter [3:0]
        CYCLE_0 = 0,
        CYCLE_1 = 1,
        CYCLE_2 = 2,
        CYCLE_3 = 3,
        CYCLE_4 = 4,
        CYCLE_5 = 5;
    reg [3:0] cycle  /*verilator public*/;
    
    reg [7:0] flags;
    reg [15:0] pc_register, sp_register, data_register, tmp_register;
    assign data_bus = w? data_register : 16'bz;
        
    reg [15:0] word;
    wire [7:0] val;
    wire [3:0] operator;
    wire [3:0] operator_group;
    wire [2:0] num_rgv, num_rg1, num_rg2;
    wire [9:0] relative_addr;
    Decoder decoder(
        .word(word),
        .operator_group(operator_group),
        .operator(operator),
        .rgv(num_rgv),
        .val(val),
        .rg1(num_rg1),
        .rg2(num_rg2),
        .relative_addr(relative_addr));
    
    reg [1:0] cs_write_registers;
    reg [15:0] register_in;
    wire [15:0] register_out [0:1];
    Registers registers(
        .clk(clk),
        .num1(num_rg1[2:1]),
        .num2(num_rg2[2:1]),
        .write(cs_write_registers),
        .bus_in(register_in),
        .bus_out1(register_out[0]),
        .bus_out2(register_out[1])
    );
    
    wire check_branch;
    wire [15:0] alu_out;
    wire [5:0] alu_flags;
    
    reg [15:0] alu_in [0:1];
    Alu alu(
        .clk(clk),
        .single(operator_group == `GROUP_CRSMATH || operator_group == `GROUP_WRSMATH),
        .value1(alu_in[0]),
        .value2(alu_in[1]),
        .operator(operator),
        .bus_out(alu_out),
        .alu_flags(alu_flags),
        .check_branch(check_branch));
    
    initial begin
        halt = 0;
        cycle = CYCLE_0;
        pc_register = 16'h0000;
        sp_register = 16'h07FF;
    end

    always @ (posedge clk or posedge reset)
        if (reset)
            cycle <= CYCLE_0;
        else case(cycle)
            CYCLE_0: cycle <= CYCLE_1;
            CYCLE_1: cycle <= CYCLE_2;
            CYCLE_2: cycle <= CYCLE_3;
            CYCLE_3: cycle <= CYCLE_0;
            CYCLE_4: cycle <= CYCLE_0;
        endcase 
        
    always @ (cycle or operator_group or operator)
        casez({cycle, operator_group})
            {CYCLE_1, 4'b????}: r = 1'b1;
            {CYCLE_3, `GROUP_WRRMATH_MEM}: r = operator[2];
            {CYCLE_3, `GROUP_WRSMATH_STACK}: r = operator == `OP_POP;
            {CYCLE_3, `GROUP_SPECIAL}: r = operator == `OP_RET;
            default: r = 1'b0;
        endcase
        
    always @ (cycle or operator_group or operator)
        casez({cycle, operator_group})
            {CYCLE_3, `GROUP_WRRMATH_MEM}: w = operator[2];
            {CYCLE_3, `GROUP_WRSMATH_STACK}: w = operator == `OP_PUSH;
            {CYCLE_5, `GROUP_SPECIAL_LONG}: w = operator == `OP_CALL;
            default: w = 1'b0;
        endcase
    
    always @ (negedge clk)
        if (reset) begin
            address_bus <= 16'h0000;
            pc_register <= 16'h0000;
            sp_register <= 16'h07FF;
            cs_write_registers <= 2'b00;
        end else casez ({cycle, operator_group})
            {CYCLE_0, `GROUP_WRRMATH_MEM}: begin
                if (operator[1]) begin
                    cs_write_registers <= 2'b10;
                    register_in <= register_out[1] + 1;
                end else if (operator[1]) begin
                    cs_write_registers <= 2'b10;
                    register_in <= register_out[1] - 1;
                end else
                    cs_write_registers <= 2'b00;
                address_bus <= pc_register;
            end
            {CYCLE_0, 4'b????}: begin
                cs_write_registers <= 2'b00;
                address_bus <= pc_register;
            end
            {CYCLE_1, 4'b????}: begin
                cs_write_registers <= 2'b00;
                pc_register <= pc_register + 1;
                word <= data_bus;
            end
            {CYCLE_2, `GROUP_WRRMATH}: begin
                alu_in[0] <= register_out[0];
                alu_in[1] <= register_out[1];
            end
            {CYCLE_2, `GROUP_WRSMATH}: begin
                alu_in[0] <= register_out[0];
            end
            {CYCLE_3, `GROUP_WRRMATH}, {CYCLE_3, `GROUP_WRSMATH}: begin
                register_in[0] <= alu_out;
                cs_write_registers <= 2'b01;
                flags[5:0] <= alu_flags;
            end
            {CYCLE_2, `GROUP_WRRMATH_MEM}: begin
                if (operator[2])
                    data_register <= register_out[0];
                address_bus <= register_out[1];
            end
            {CYCLE_3, `GROUP_WRRMATH_MEM}: begin
                if (!operator[2]) begin
                    register_in <= data_bus;
                    cs_write_registers <= 2'b01;
                end
            end
            {CYCLE_2, `GROUP_WRSMATH_STACK}: begin
                case (operator)
                    `OP_PUSH: begin
                        data_register <= register_out[0];
                        sp_register <= sp_register - 1;
                        address_bus <= sp_register;
                    end
                    `OP_POP: begin
                        sp_register <= sp_register + 1;
                        address_bus <= sp_register + 1;
                    end
                endcase
            end
            {CYCLE_3, `GROUP_WRSMATH_STACK}: begin
                case (operator)
                    `OP_POP: begin
                        register_in <= data_bus;
                    end
                endcase
            end
            {CYCLE_2, `GROUP_SPECIAL_LONG}: begin
                address_bus <= pc_register;
            end
            {CYCLE_3, `GROUP_SPECIAL_LONG}: begin
                case (operator)
                    `OP_JMP: begin
                        pc_register <= data_bus;
                    end
                    `OP_CALL: begin
                        tmp_register <= data_bus;
                    end
                endcase
            end
            {CYCLE_4, `GROUP_SPECIAL_LONG}: begin
                case (operator)
                    `OP_CALL: begin
                        data_register <= pc_register;
                        sp_register <= sp_register - 1;
                        address_bus <= sp_register;
                    end
                endcase
            end
            {CYCLE_5, `GROUP_SPECIAL_LONG}: begin
                case (operator)
                    `OP_CALL: begin
                        pc_register <= tmp_register;
                    end
                endcase
            end
            {CYCLE_2, `GROUP_SPECIAL}: begin
                case (operator)
                    `OP_RET: begin
                        sp_register <= sp_register + 1;
                        address_bus <= sp_register + 1;
                    end
                endcase
            end
            {CYCLE_3, `GROUP_SPECIAL}: begin
                case (operator)
                    `OP_RET: begin
                        pc_register <= data_bus;
                    end
                endcase
            end
        endcase
    
endmodule
