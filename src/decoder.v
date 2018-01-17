`include "cpu_data.v"

module Decoder(
        latch, word, operator_group, operator, reset_cycle,
        pc_branch_jump, rg1, rg2, val, erg1, erg2);
    input latch;
    input [15:0] word;
    
    wire [7:0] first_byte; assign first_byte = word[7:0];
    wire [7:0] second_byte; assign second1_byte = word[15:8];
    
    output reg[3:0] operator;
    output reg[3:0] operator_group;
    output reg[8:0] pc_branch_jump;
    output reg reset_cycle;
    
    output reg [1:0] erg1, erg2;
    
    output reg [3:0] rg1, rg2;
    output reg [7:0] val;
    
    initial begin
        reset_cycle = 0;
        operator_group = `GROUP_WRONG;
    end
    
    always @ (posedge latch)
        casez(first_byte)
            8'b???????0, 8'b??????01: begin //MATH CONSTANT GROUP
                rg1 = first_byte[7:4];
                val = second_byte;
                operator = word[3:0];
                pc_branch_jump = 0;
                operator_group = `GROUP_MATH_CONSTANT;
                reset_cycle = 1;
            end
            8'b?????011: begin //BRANCH JUMPS GROUP
                pc_branch_jump = word[15:7];
                operator = first_byte[6:3];
                operator_group = `GROUP_BRANCH_JUMPS;
                reset_cycle = 1;
            end
            8'b????0111: begin //MATH REG GROUP
                rg1 = second_byte[3:0];
                rg2 = second_byte[7:4];
                operator = word[7:4];
                operator_group = `GROUP_MATH_REG;
                pc_branch_jump = 0;
                reset_cycle = 1;
            end
            8'b???01111: begin //MATH EREG GROUP
                erg1 = second_byte[2:1];
                erg2 = second_byte[7:4];
                operator = word[8:5];
                pc_branch_jump = 0;
                operator_group = `GROUP_MATH_EREG;
                reset_cycle = 1;
            end
            8'b??011111: begin //SINGLE REG / STACK GROUP
                rg1 = second_byte[5:2];
                operator = word[9:6];
                pc_branch_jump = 0;
                if (operator == `OP_POP || operator == `OP_PUSH) begin
                    operator_group = `GROUP_STACK;
                    reset_cycle = 0;
                end else begin
                    operator_group = `GROUP_SINGLE_REG;
                    reset_cycle = 1;
                end
                
            end
            8'b?0111111: begin //REG MEMORY GROUP
                operator = {1'b0, word[9:7]};
                pc_branch_jump = 0;
                operator_group = `GROUP_REG_MEMORY;
                reset_cycle = 0;
            end
            8'b01111111: begin //EXTENDED GROUP
                operator = word[11:8];
                pc_branch_jump = 0;
                operator_group = `GROUP_EXTENDED;
                reset_cycle = 0;
            end
            8'b11111111: begin //OTHERS / RETURN GROUP
                operator = word[11:8];
                pc_branch_jump = 0;
                if (operator == `OP_RET) begin
                    operator_group = `GROUP_OTHERS;
                    reset_cycle = 1;
                end else begin
                    operator_group = `GROUP_RETURN;
                    reset_cycle = 0;
                end
            end
            default: begin
                operator_group = `GROUP_WRONG;
                reset_cycle = 1;
            end
        endcase

endmodule
