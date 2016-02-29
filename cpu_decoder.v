`include "cpu_data.v"

task check_first_byte;
    input byte first_byte;
begin
    if (first_byte[0] == 1'b0 || first_byte[1:0] == 2'b01) begin //MATH CONSTANT GROUP
        operator_group = GROUP_MATH_CONSTANT;
        reg_num = first_byte[7:4];
        math_operator = first_byte[3:0];
    end else if (first_byte[2:0] == 3'b011) begin //BRANCH JUMPS GROUP
        operator_group = GROUP_BRANCH_JUMPS;
        branch_operator = first_byte[6:3];
        pc_branch_jump[8] = first_byte[7];
    end else if (first_byte[3:0] == 4'b0111) begin //MATH REG GROUP
        operator_group = GROUP_MATH_REG;
        math_operator = first_byte[7:4];
    end else if (first_byte[4:0] == 5'b01111) begin //MATH EREG GROUP
        math_operator[2:0] = first_byte[7:5];
        operator_group = GROUP_MATH_EREG;
    end else if (first_byte[5:0] == 6'b011111) begin //SINGLE REG GROUP
        single_operator[1:0] = first_byte[7:6];
        operator_group = GROUP_SINGLE_REG;
    end else if (first_byte[6:0] == 7'b0111111) begin //REG MEMORY GROUP
        operator_group = GROUP_REG_MEMORY;
        reg_memory_operator[0] = first_byte[7];
    end else if (first_byte[7:0] == 8'b01111111) begin //EXTENDED GROUP
        operator_group = GROUP_EXTENDED;
    end else if (first_byte[7:0] == 8'b11111111) begin //OTHERS GROUP
        operator_group = GROUP_OTHERS;
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
        GROUP_REG_MEMORY: begin
            reg_memory_operator[2:1] = second_byte[1:0];
            reg_num = second_byte[5:2];
            mem_ereg_num = second_byte[7:6];
            cycle = 4;
        end
        GROUP_SINGLE_REG: begin
            single_operator[3:2] = second_byte[1:0];
            reg_num = second_byte[5:2];
            single_compute(rg[reg_num]);
        end
        GROUP_EXTENDED: begin
            extended_operator = second_byte[4:0];
            $display("%s %s", operator_group.name(), extended_operator.name());
            cycle = 4;
        end
        GROUP_OTHERS: begin
            other_operator = second_byte[4:0];
            $display("%s %s", operator_group.name(), other_operator.name());
            others_compute();
        end
        default: begin
            $display("%s", operator_group.name());
            cycle = 0;
        end
    endcase
end endtask

task first_extend_action;
begin
    case(operator_group)
        GROUP_REG_MEMORY: begin
            address_bus = erg[mem_ereg_num];
            if (reg_memory_operator[2] == 1'b0) begin
                data_bus = 8'bz;
                r = 1'b1;
            end else
                data_bus = rg[reg_num];
        end
        GROUP_SINGLE_REG: begin  
            if (single_operator == OP_POP) begin
                address_bus = sp - 1;
                data_bus = 8'bz;
                r = 1'b1;
            end
            if (single_operator == OP_PUSH) begin
                address_bus = sp;
                data_bus = rg[reg_num];
            end
        end
        GROUP_OTHERS: begin
            if (other_operator == OP_RET) begin
                address_bus = sp - 1;
                data_bus = 8'bz;
                r = 1'b1;
            end
        end
        GROUP_EXTENDED: begin
            if (extended_operator == OP_JMP) begin
                address_bus = pc;
                data_bus = 8'bz;
                r = 1'b1;
                w = 1'b0;
            end
            else if (extended_operator == OP_CALL) begin
                address_bus = sp;
                data_bus = pc[7:0];
            end
        end
    endcase
end endtask

task second_extend_action;
    bit [3:0] ereg_reg_num;
    assign ereg_reg_num = {1'b1, mem_ereg_num, 1'b0};
begin
    case(operator_group)
        GROUP_REG_MEMORY: begin
            $display(
                "%s %s R%h (%h) ER%d (%h)", 
                operator_group.name(), reg_memory_operator.name(), 
                reg_num, rg[reg_num], mem_ereg_num, erg[mem_ereg_num]);
            if (reg_memory_operator[2] == 1'b0) begin
                rg[reg_num] = data_bus;
                w = 1'b0;
                r = 1'b0;
            end else begin
                w = 1'b1;
                r = 1'b0;
            end
            case (reg_memory_operator[1:0])
                2'b01: {rg[ereg_reg_num+1], rg[ereg_reg_num]} = erg[mem_ereg_num] + 16'b1;
                2'b10: {rg[ereg_reg_num+1], rg[ereg_reg_num]} = erg[mem_ereg_num] - 16'b1;
            endcase
            cycle = 0;
        end
        GROUP_SINGLE_REG: begin
            w = 1'b0;
            if (single_operator == OP_POP) begin
                rg[reg_num] = data_bus;
                w = 1'b0;
                r = 1'b0;
                sp = sp - 1;
                cycle = 0;
            end
            if (single_operator == OP_PUSH) begin
                w = 1'b1;
                r = 1'b0;
                sp = sp + 1;
                cycle = 0;
            end
        end
        GROUP_OTHERS: begin
            if (other_operator == OP_RET) begin
                pc[15:8] = data_bus;
                r = 1'b0;
                cycle = 6;
            end
        end
        GROUP_EXTENDED: begin
            cycle = 6;
            if (extended_operator == OP_JMP) begin
                r = 1'b0;
                pc[7:0] = data_bus;
            end
            else if (extended_operator == OP_CALL) begin
                w = 1'b1;
            end else 
                cycle = 0;
        end
    endcase
end endtask

task third_extend_action;
begin
    case(operator_group)
        GROUP_OTHERS: begin
            if (other_operator == OP_RET) begin
                address_bus = address_bus - 1;
                data_bus = 8'bz;
                r = 1'b1;
                cycle = 7;
            end
        end
        GROUP_EXTENDED: begin
            address_bus = address_bus + 1;
            cycle = 7;
            if (extended_operator == OP_JMP) begin
                data_bus = 8'bz;
                r = 1'b1;
            end
            else if (extended_operator == OP_CALL) begin
                data_bus = pc[15:8];
            end
        end
    endcase
end endtask

task fourth_extend_action;
begin
    case(operator_group)
        GROUP_OTHERS: begin
            if (other_operator == OP_RET) begin
                pc = {pc[15:8], data_bus} + 16'h2; //move to next order 
                r = 1'b0;
                sp = sp - 2;
                cycle = 0;
            end
        end
        GROUP_EXTENDED: begin
            if (extended_operator == OP_JMP) begin
                r = 1'b0;
                pc[15:8] = data_bus;
                cycle = 0;
            end
            if (extended_operator == OP_CALL) begin
                w = 1'b1;
                sp = sp + 2;
                cycle = 4;
                extended_operator = OP_JMP; //im too lazy to write more cycles lol
            end
        end
    endcase
end endtask