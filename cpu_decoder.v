`include "cpu_data.v"

task check_first_byte;
    input byte first_byte;
begin
    if (first_byte[0] == 1'b0 || first_byte[1:0] == 2'b01) begin //MATH CONSTANT GROUP
        reg_num = first_byte[7:4];
        math_operator = first_byte[3:0];
        operator_group = GROUP_MATH_CONSTANT;
    end else if (first_byte[2:0] == 3'b011) begin //BRANCH JUMPS GROUP
        operator_group = GROUP_BRANCH_JUMPS;
        branch_operator = first_byte[6:3];
        pc_branch_jump[8] = first_byte[7];
    end else if (first_byte[3:0] == 4'b0111) begin //MATH REG GROUP
        math_operator = first_byte[7:4];
        operator_group = GROUP_MATH_REG;
    end else if (first_byte[4:0] == 4'b01111) begin //MATH EREG GROUP
        math_operator[2:0] = first_byte[7:5];
        operator_group = GROUP_MATH_EREG;
    end else if (first_byte[4:0] == 5'b11111) begin //OTHERS
        operator_group = GROUP_OTHERS;
        other_operator = first_byte[7:5];
    end else begin
        operator_group = GROUP_WRONG;
    end
end endtask

task check_second_byte;
    input byte second_byte;
begin
    case(operator_group)
        GROUP_MATH_CONSTANT: begin 
            compute(second_byte);
            cycle = 0;
        end
        GROUP_MATH_REG: begin
            reg_num = second_byte[3:0];
            compute(rg[second_byte[7:4]]);
            cycle = 0;
        end
        GROUP_MATH_EREG: begin
            math_operator[3] = second_byte[0];
            reg_num = {1'b1, second_byte[2:1], 1'b0};
            compute16(erg[second_byte[4:3]]);
            cycle = 0;
        end
        GROUP_BRANCH_JUMPS: begin
            pc_branch_jump[7:0] = second_byte;
            if (check_branch())
                pc = pc + {{7{pc_branch_jump[8]}}, pc_branch_jump} - 2;
            cycle = 0;
        end
        GROUP_OTHERS: begin
            case(other_operator)
                OP_HLT: begin halt = 1; $finish; end
            endcase
            cycle = 0;
        end
        default: begin
            $display("%s", operator_group.name());
            pc = pc + 16'b1;
            cycle = 0;
        end
    endcase
end endtask