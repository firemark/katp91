`include "cpu_data.v"

task check_second_byte;
    input reg[7:0] second_byte;
begin
    operator = pre_operator;
    pc_branch_jump = pre_pc_branch_jump;
    reg_num = pre_reg_num;
    case(operator_group)
        `GROUP_MATH_CONSTANT: begin 
            alu_value1 = {8'b1, rg[reg_num]};
            alu_value2 = {8'b0, second_byte};
            alu_old_sign = rg[reg_num][7];
            compute_signal = 1'b1;
            
            if (math_operator != `OP_CMP) begin
                rg[second_byte[3:0]] <= alu_result[7:0];
            end

            carry <= alu_carry;
            overflow <= alu_overflow;
            negative <= alu_negative;
            zero <= alu_zero;
            cycle <= 0;
            cycle <= 0;
        end
        `GROUP_MATH_REG: begin
            alu_value1 = {8'b1, rg[second_byte[3:0]]};
            alu_value2 = {8'b0, rg[second_byte[7:4]]};
            alu_old_sign = rg[reg_num][7];
            compute_signal = 1'b1;
            
            if (math_operator != `OP_CMP) begin
                rg[second_byte[3:0]] <= alu_result[7:0];
            end

            carry <= alu_carry;
            overflow <= alu_overflow;
            negative <= alu_negative;
            zero <= alu_zero;
            cycle <= 0;
        end
        `GROUP_MATH_EREG: begin
            operator[3] = second_byte[0];
            alu_value1 = erg[second_byte[2:1]];
            alu_value2 = erg[second_byte[4:3]];
            alu_old_sign = erg[second_byte[2:1]][15];
            compute_signal = 1'b1;
            
            if (math_operator != `OP_CMP) begin
                {rg[reg_num+1], rg[reg_num]} <= alu_result;
            end
            carry <= alu_carry;
            overflow <= alu_overflow;
            negative <= alu_negative;
            zero <= alu_zero;
            cycle <= 0;
        end
        `GROUP_BRANCH_JUMPS: begin
            pc_branch_jump[7:0] = second_byte;
            if (check_branch)
                pc <= pc + {{7{pc_branch_jump[8]}}, pc_branch_jump} - 2;
            cycle <= 0;
        end
        `GROUP_REG_MEMORY: begin
            operator[2:1] = second_byte[1:0];
            reg_num = second_byte[5:2];
            mem_ereg_num = second_byte[7:6];
            cycle <= 4;
        end
        `GROUP_SINGLE_REG: begin
            operator[3:2] = second_byte[1:0];
            alu_value1 = {8'b1, rg[second_byte[5:2]]};
            alu_old_sign = rg[reg_num][7];
            compute_single_signal = 1'b1;

            if (single_operator != `OP_POP
                    && single_operator != `OP_PUSH) begin
                carry <= alu_carry;
                overflow <= alu_overflow;
                negative <= alu_negative;
                zero <= alu_zero;
                cycle <= 0;
            end else begin
                cycle <= 4;
            end
        end
        `GROUP_EXTENDED: begin
            operator = second_byte[4:0];
            //$display("%s %s", operator_group.name(), extended_operator.name());
            cycle <= 4;
        end
        `GROUP_OTHERS: begin
            operator = second_byte[4:0];
            //$display("%s %s", operator_group.name(), other_operator.name());
            case(other_operator)
                `OP_HLT: begin halt = 1; $finish; end
                `OP_CLC: carry <= 1'b0;
                `OP_CLZ: zero <= 1'b0;
                `OP_CLO: overflow <= 1'b0;
                `OP_CLN: negative <= 1'b0;
                `OP_STC: carry <= 1'b1;
                `OP_STZ: zero <= 1'b1;
                `OP_STO: overflow <= 1'b1;
                `OP_STN: negative <= 1'b1;
                default: zero <= 1'b1;
            endcase
            cycle <= (other_operator != `OP_RET) ? 0 : 4;
        end
        default: begin
            //$display("%s", operator_group.name());
            cycle <= 0;
        end
    endcase
end endtask

task first_extend_action;
begin
    case(operator_group)
        `GROUP_REG_MEMORY: begin
            address_bus <= erg[mem_ereg_num];
            if (reg_memory_operator[2] == 1'b0) begin
                r <= 1'b1;
					 w <= 1'b0;
            end else
                data_bus_out <= rg[reg_num];
        end
        `GROUP_SINGLE_REG: begin  
            if (single_operator == `OP_POP) begin
                address_bus <= sp - 1;
                r <= 1'b1;
					 w <= 1'b0;
            end
            if (single_operator == `OP_PUSH) begin
                address_bus <= sp;
                data_bus_out <= rg[reg_num];
            end
        end
        `GROUP_OTHERS: begin
            if (other_operator == `OP_RET) begin
                address_bus <= sp - 1;
                r <= 1'b1;
					 w <= 1'b0;
            end
        end
        `GROUP_EXTENDED: begin
            if (extended_operator == `OP_JMP) begin
                address_bus <= pc;
                r <= 1'b1;
                w <= 1'b0;
            end
            else if (extended_operator == `OP_CALL) begin
                address_bus <= sp;
                data_bus_out <= pc[7:0];
            end else
					cycle <= 0;
        end
		  default: begin
		      cycle <= 0;
		  end
    endcase
end endtask

task second_extend_action;
    reg [3:0] ereg_reg_num;
begin
	 ereg_reg_num = {1'b1, mem_ereg_num, 1'b0};
    case(operator_group)
        `GROUP_REG_MEMORY: begin
            //$display(
            //    "%s %s R%h (%h) ER%d (%h)", 
            //    operator_group.name(), reg_memory_operator.name(), 
            //    reg_num, rg[reg_num], mem_ereg_num, erg[mem_ereg_num]);
            if (reg_memory_operator[2] == 1'b0) begin
                rg[reg_num] <= data_bus;
                w <= 1'b0;
                r <= 1'b0;
            end else begin
                w <= 1'b1;
                r <= 1'b0;
            end
            case (reg_memory_operator[1:0])
                2'b01: {rg[ereg_reg_num+1], rg[ereg_reg_num]} <= erg[mem_ereg_num] + 16'b1;
                2'b10: {rg[ereg_reg_num+1], rg[ereg_reg_num]} <= erg[mem_ereg_num] - 16'b1;
					 default: {rg[ereg_reg_num+1], rg[ereg_reg_num]} <= erg[mem_ereg_num];
            endcase
            cycle <= 0;
        end
        `GROUP_SINGLE_REG: begin
            w <= 1'b0;
				case (single_operator)
					`OP_POP: begin
						 rg[reg_num] <= data_bus;
						 w <= 1'b0;
						 r <= 1'b0;
						 sp <= sp - 1;
						 cycle <= 0;
					end
					`OP_PUSH: begin
						 w <= 1'b1;
						 r <= 1'b0;
						 sp <= sp + 1;
						 cycle <= 0;
					end
					default: cycle <= 0;
				endcase
        end
        `GROUP_OTHERS: begin
            if (other_operator == `OP_RET) begin
                pc[15:8] <= data_bus;
                r <= 1'b0;
                cycle <= 6;
            end else
					 cycle <= 0;
        end
        `GROUP_EXTENDED: begin
            cycle <= 6;
				case (extended_operator)
			       `OP_JMP: begin
						  r <= 1'b0;
						  pc[7:0] <= data_bus;
					 end
					 `OP_CALL: begin
                    w <= 1'b1;
				    end
                default: cycle <= 0;
			   endcase
        end
		  default: cycle <= 0;
    endcase
end endtask

task third_extend_action;
begin
    case(operator_group)
        `GROUP_OTHERS: begin
            if (other_operator == `OP_RET) begin
                address_bus <= address_bus - 1;
                r <= 1'b1;
					 w <= 1'b0;
                cycle <= 7;
            end else cycle <= 0;
        end
        `GROUP_EXTENDED: begin
            address_bus <= address_bus + 1;
            cycle <= 7;
            if (extended_operator == `OP_JMP) begin
                r <= 1'b1;
					 w <= 1'b0;
            end
            else if (extended_operator == `OP_CALL) begin
                data_bus_out <= pc[15:8];
            end else cycle <= 0;
        end
    endcase
end endtask

task fourth_extend_action;
begin
    case(operator_group)
        `GROUP_OTHERS: begin
            if (other_operator == `OP_RET) begin
                //pc <= {pc[15:8], data_bus} + 16'h2; //move to next order
                r <= 1'b0;
                sp <= sp - 2;
                cycle <= 0;
            end else cycle <= 0;
        end
        `GROUP_EXTENDED: begin
            if (extended_operator == `OP_JMP) begin
                r <= 1'b0;
                pc[15:8] <= data_bus;
                cycle <= 0;
            end
            else if (extended_operator == `OP_CALL) begin
                w <= 1'b1;
                sp <= sp + 2;
                cycle <= 4;
                operator = `OP_JMP; //im too lazy to write more cycles lol
            end else cycle <= 0;
        end
    endcase
end endtask