`include "cpu_data.v"

task debug_cpu;
    reg [3:0] i;
begin
    $display("PC %h ADDR %h DATA %h SP %h", 
        pc, address_bus, data_bus, sp);
    $display("ZERO %b CARRY %b OVERFLOW %b NEGATIVE %b HALT %b",
        zero, carry, overflow, negative, halt);
    for(i=0; i < 8; i=i+1) begin
        $display("R%h = %h (%d) R%h = %h (%d)", 
            i<<1, rg[i<<1], rg[i<<1],
            (i<<1)+1'b1, rg[(i<<1)+1'b1], rg[(i<<1)+1'b1]);
    end
    //for(i=0; i < 4; i=i+1) begin
    //    $display("ER%h = %h (%d)", i, erg[i], erg[i]);
    //end
end endtask

/* verilator lint_off CASEINCOMPLETE */

task first_extend_action_phase2; begin
    case(operator_group)
        `GROUP_REG_MEMORY: begin
            //$display(
            //    "%s %s R%h (%h) ER%d (%h)", 
            //    operator_group.name(), reg_memory_operator.name(), 
            //    reg_num, rg[reg_num], mem_ereg_num, erg[mem_ereg_num]);
            if (!operator[2]) begin
                memory_val <= data_bus;
            end
            case (operator[1:0])
                2'b01: memory_erg_val <= erg[erg1] + 16'b1;
                2'b10: memory_erg_val <= erg[erg1] - 16'b1;
                default: memory_erg_val <= erg[erg1];
            endcase
            reset_cycle_on_5 <= 1;
        end
        `GROUP_STACK: begin
            case (operator) /* verilator lint_off CASEINCOMPLETE */
                `OP_POP: begin
                     stack_val <= data_bus;
                     sp <= sp - 16'h0001;
                end
                `OP_PUSH: begin
                     sp <= sp + 16'h0001;
                end
            endcase
            reset_cycle_on_5 <= 1;
        end
        `GROUP_RETURN: begin
            //pc[15:8] = data_bus;
            reset_cycle_on_5 <= 0;
        end
        `GROUP_EXTENDED: begin
           //case (operator) /* verilator lint_off CASEINCOMPLETE */
           //    `OP_JMP: begin
           //         pc[7:0] = data_bus;
           //     end
           //endcase
           reset_cycle_on_5 <= 0;
        end
    endcase
end endtask

/*task third_extend_action;
begin
    case(operator_group)
        `GROUP_RETURN: begin
            address_bus = address_bus - 16'h0001;
            {r, w} = 2'b10;
        end
        `GROUP_EXTENDED: begin
            address_bus = address_bus + 16'h0001;
            case (operator)
                `OP_JMP: {r, w} = 2'b10;
                `OP_CALL: data_bus_out = pc[15:8];
            endcase
        end
    endcase
end endtask

task fourth_extend_action;
begin
    case(operator_group)
        `GROUP_RETURN: begin
            //pc <= {pc[15:8], data_bus} + 16'h2; //move to next order
            {r, w} = 2'b00;
            sp <= sp - 16'h0002;
            reset_cycle_to_4 <= 0;
        end
        `GROUP_EXTENDED: begin
            case (operator)
                `OP_JMP: begin
                    {r, w} = 2'b00;
                    pc[15:8] = data_bus;
                    reset_cycle_to_4 <= 0;
                end
                `OP_CALL: begin
                    {r, w} = 2'b00;
                    sp <= sp + 16'h0002;
                    reset_cycle_to_4 <= 1;
                    //operator = `OP_JMP; //im too lazy to write more cycles lol
                end
            endcase
        end
    endcase
end endtask*/