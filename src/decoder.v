`include "cpu_data.v"

module Decoder(
        cs, word, operator_group, operator, extended_cycle, pc,
        cs_new_pc, new_out_pc, rg1, rg2, val);
    input cs, cs_new_pc;
    input [15:0] word;
    input [15:0] pc;
    
    wire [7:0] first_byte; assign first_byte = word[7:0];
    wire [7:0] second_byte; assign second_byte = word[15:8];
    
    output reg [3:0] operator;
    output reg [3:0] operator_group;
    reg [15:0] new_pc;
    output [15:0] new_out_pc; assign new_out_pc = cs_new_pc ? new_pc : 16'bz;
    output reg extended_cycle;
    
    output reg [3:0] rg1, rg2;
    output reg [7:0] val;
    
    initial begin
        extended_cycle = 0;
        operator_group = `GROUP_WRONG;
        new_pc = 0;
        rg1 = 0;
        rg2 = 0;
        val = 0;
    end
    
    always @ (cs or word or pc) begin
        if (cs) casez(first_byte)
            8'b???????0, 8'b??????01: begin //MATH CONSTANT GROUP
                rg1 = first_byte[7:4];
                val = second_byte;
                operator = word[3:0];
                operator_group = `GROUP_MATH_CONSTANT;
                new_pc = 0;
                extended_cycle = 0;
            end
            8'b?????011: begin //BRANCH JUMPS GROUP
                new_pc = pc - 2 + {{8{word[15]}}, word[14:7]};
                operator = first_byte[6:3];
                operator_group = `GROUP_BRANCH_JUMPS;
                extended_cycle = 0;
            end
            8'b????0111: begin //MATH REG GROUP
                rg1 = second_byte[3:0];
                rg2 = second_byte[7:4];
                operator = word[7:4];
                operator_group = `GROUP_MATH_REG;
                new_pc = 0;
                extended_cycle = 0;
            end
            8'b???01111: begin //MATH EREG GROUP
                rg1 = {2'b0, second_byte[2:1]};
                rg2 = {2'b0, second_byte[4:3]};
                operator = word[8:5];
                new_pc = 0;
                operator_group = `GROUP_MATH_EREG;
                extended_cycle = 0;
            end
            8'b??011111: begin //SINGLE REG / STACK GROUP
                rg1 = second_byte[5:2];
                operator = word[9:6];
                new_pc = 0;
                if (operator == `OP_POP || operator == `OP_PUSH) begin
                    operator_group = `GROUP_STACK;
                    extended_cycle = 1;
                end else begin
                    operator_group = `GROUP_SINGLE_REG;
                    extended_cycle = 0;
                end
                
            end
            8'b?0111111: begin //REG MEMORY GROUP
                operator = {1'b0, word[9:7]};
                rg1 = word[13:10];
                rg2 = {2'b0, word[15:14]};
                new_pc = 0;
                operator_group = `GROUP_REG_MEMORY;
                extended_cycle = 1;
            end
            8'b01111111: begin //EXTENDED GROUP
                operator = word[11:8];
                rg1 = 0;
                rg2 = 0;
                new_pc = 0;
                operator_group = `GROUP_EXTENDED;
                extended_cycle = 1;
            end
            8'b11111111: begin //OTHERS / RETURN GROUP
                operator = word[11:8];
                new_pc = 0;
                rg1 = 0;
                rg2 = 0;
                if (operator == `OP_RET) begin
                    operator_group = `GROUP_OTHERS;
                    extended_cycle = 0;
                end else begin
                    operator_group = `GROUP_RETURN;
                    extended_cycle = 1;
                end
            end
        endcase
    end
endmodule
