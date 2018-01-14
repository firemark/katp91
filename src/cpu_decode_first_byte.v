`include "cpu_data.v"

module CpuDecodeFirstByte(latch, first_byte, operator, operator_group, reg_num, pc_branch_jump);
    input latch;
    input [7:0] first_byte;
    
    output reg[4:0] operator;
    output reg[4:0] operator_group;
    output reg[3:0] reg_num;
    output reg[8:0] pc_branch_jump;
    
    always @(latch) begin
        if (first_byte[0] == 1'b0 || first_byte[1:0] == 2'b01) begin //MATH CONSTANT GROUP
            operator_group = `GROUP_MATH_CONSTANT;
            reg_num = first_byte[7:4];
            operator[3:0] = first_byte[3:0];
        end else if (first_byte[2:0] == 3'b011) begin //BRANCH JUMPS GROUP
            operator_group = `GROUP_BRANCH_JUMPS;
            operator = first_byte[6:3];
            pc_branch_jump[8] = first_byte[7];
        end else if (first_byte[3:0] == 4'b0111) begin //MATH REG GROUP
            operator[3:0] = first_byte[7:4];
            operator_group = `GROUP_MATH_REG;
        end else if (first_byte[4:0] == 5'b01111) begin //MATH EREG GROUP
            operator[2:0] = first_byte[7:5];
            operator_group = `GROUP_MATH_EREG;
        end else if (first_byte[5:0] == 6'b011111) begin //SINGLE REG GROUP
            operator[1:0] = first_byte[7:6];
            operator_group = `GROUP_SINGLE_REG;
        end else if (first_byte[6:0] == 7'b0111111) begin //REG MEMORY GROUP
            operator_group = `GROUP_REG_MEMORY;
            operator[0] = first_byte[7];
        end else if (first_byte[7:0] == 8'b01111111) begin //EXTENDED GROUP
            operator_group = `GROUP_EXTENDED;
        end else if (first_byte[7:0] == 8'b11111111) begin //OTHERS GROUP
            operator_group = `GROUP_OTHERS;
        end else begin
            operator_group = `GROUP_WRONG;
        end
    end
endmodule