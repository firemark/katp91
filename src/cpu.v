`include "cpu_data.v"

module Cpu(clk, reset, data_bus, address_bus, r, w, halt);
    input clk /*verilator clocker*/;
    input reset;
    inout [7:0] data_bus;
    output reg[15:0] address_bus;
    output reg r, w;
    output reg halt;
    
    reg [7:0] data_bus_out;
    assign data_bus = w? data_bus_out : 8'bz;
    
    reg [7:0] rg[0:15]; //8reg registers
    reg [15:0] pc; //programer counter
    reg [15:0] sp; //stack pointer
    reg [2:0] cycle  /*verilator public*/;
    
    reg [3:0] flags;
    wire carry, overflow, zero, negative;
    assign carry = flags[0];
    assign overflow = flags[1];
    assign zero = flags[2];
    assign negative = flags[3];
    
    wire[15:0] erg[0:3]; //16reg extended registers
    assign erg[3] = {rg[15], rg[14]};
    assign erg[2] = {rg[13], rg[12]};
    assign erg[1] = {rg[11], rg[10]};
    assign erg[0] = {rg[9], rg[8]};
    
    wire reset_cycle_on_3;
    reg reset_cycle_on_5;
    reg reset_cycle_to_4;
    wire reset_cycle; assign reset_cycle = (
        reset_cycle_on_3 && (cycle == 3) ||
        reset_cycle_on_5 && (cycle == 5)
    );

    reg [15:0] word;
    reg decoder_latch;
    wire [8:0] pc_branch_jump;
    wire [3:0] operator;
    wire [3:0] operator_group;
    wire [3:0] rg1, rg2;
    wire [1:0] erg1, erg2;
    wire [7:0] val;
    Decoder decoder(
        decoder_latch, word, operator_group, operator, reset_cycle_on_3,
        pc_branch_jump, rg1, rg2, val, erg1, erg2);
    
    wire [3:0] alu8_flags;
    wire [7:0] alu8_result;
    Alu8 alu8(
        cycle == 3 && (
            operator_group == GROUP_MATH_CONSTANT ||
            operator_group == GROUP_MATH_REG ||
            operator_group == GROUP_SINGLE_REG),
        operator_group == GROUP_SINGLE_REG,
        rg[rg1],
        operator_group == GROUP_MATH ? rg[rg2] : val,
        operator, alu8_result, alu8_flags);
    
    wire [3:0] alu16_flags;
    wire [15:0] alu16_result;
    Alu16 alu16(
        cycle == 3 && operator_group == GROUP_MATH_EREG,
        erg[erg1], erg[erg2], operator, alu16_result, alu16_flags);
        
    wire [3:0] flager_flags;
    SetFlager set_flager(cycle == 3 && operator_group == GROUP_OTHERS, flags, flager_flags);
        
    wire [3:0] erg1_rg1; assign erg1_rg1 = {1'b1, erg1, 1'b1}; 
    wire [3:0] erg1_rg2; assign erg1_rg2 = {1'b1, erg1, 1'b0};
        
    wire check_branch;
    CheckBranch check_branch_doc(operator, check_branch, flags);
    
    initial begin
        halt = 0;
        cycle = 0;
        pc = 16'h2000;
        sp = 16'h1c00;
        decoder_latch = 0;
        reset_cycle_on_5 = 0;
        reset_cycle_to_4 = 0;
    end
    
    always @(posedge clk) begin
        if (halt || reset_cycle || reset)
            cycle <= 0;
        else if (reset_cycle_to_4)
            cycle <= 4;
        else
            cycle <= cycle + 1;
        
        if (reset) begin
            halt = 0;
            pc = 16'h2000;
            sp <= 16'h1c00;
            decoder_latch = 0;
            reset_cycle_on_5 = 0;
            reset_cycle_to_4 = 0;
        end else case(cycle)
            0: begin
                if (check_branch)
                    pc = pc + {{7{pc_branch_jump[8]}}, pc_branch_jump} - 16'h0002;

                address_bus = pc;
                pc = pc + 16'b1;
                {r, w} = 2'b10;
                
                decoder_latch = 0;
                reset_cycle_on_5 = 0;
                reset_cycle_to_4 = 0;
                
                case(operator_group)
                    `GROUP_MATH_CONSTANT, `GROUP_MATH_REG, `GROUP_SINGLE_REG: flags = alu8_flags;
                    `GROUP_MATH_EREG: flags = alu16_flags;
                    `GROUP_OTHERS: flags = flager_flags;
                endcase

                case(operator_group)
                    `GROUP_MATH_CONSTANT, `GROUP_MATH_REG, `GROUP_SINGLE_REG: rg[rg1] = alu8_result;
                    `GROUP_MATH_EREG: {rg[erg1_rg1], rg[erg1_rg2]} = alu16_result;
                endcase
                
                debug_cpu();
            end
            1: begin
                word[7:0] = data_bus;
                {r, w} = 2'b00;
            end
            2: begin
                {r, w} = 2'b10;
                address_bus = pc;
                pc = pc + 16'b1;
            end
            3: begin
                word[15:8] = data_bus;
                {r, w} = 2'b00;
                decoder_latch = 1;
            end
            4: begin
                first_extend_action();
            end
            5: begin
                second_extend_action();
            end
            6: begin
                third_extend_action();
            end
            7: begin
                fourth_extend_action();
            end
        endcase
    end
    
    `include "cpu_cycles.v"
endmodule
