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
    for(i=0; i < 4; i=i+1) begin
        $display("ER%h = %h (%d)", i, erg[i], erg[i]);
    end
end endtask

task first_extend_action;
begin
    case(operator_group)
        `GROUP_REG_MEMORY: begin
            address_bus = erg[erg1];
            if (operator[2] == 1'b0) begin
                {r, w} = 2'b10;
            end else begin
                data_bus_out = rg[rg1];
                {r, w} = 2'b00;
            end
        end
        `GROUP_STACK: begin
            case (operator)
                `OP_POP: begin
                    address_bus = sp - 16'h0001;
                    {r, w} = 2'b10;
                end
                `OP_PUSH: begin
                    address_bus = sp;
                    data_bus_out = rg[rg1];
                    {r, w} = 2'b00;
                end
            endcase
        end
        `GROUP_RETURN: begin
            address_bus = sp - 16'h0001;
            {r, w} = 2'b10;
        end
        `GROUP_EXTENDED: begin
            case (operator)
                `OP_JMP: begin
                    address_bus = pc;
                    {r, w} = 2'b10;
                end
                `OP_CALL: begin
                    address_bus = sp;
                    data_bus_out = pc[7:0];
                end
            endcase
        end
    endcase
end endtask

task second_extend_action; begin
    case(operator_group)
        `GROUP_REG_MEMORY: begin
            //$display(
            //    "%s %s R%h (%h) ER%d (%h)", 
            //    operator_group.name(), reg_memory_operator.name(), 
            //    reg_num, rg[reg_num], mem_ereg_num, erg[mem_ereg_num]);
            if (operator[2] == 1'b0) begin
                rg[rg1] = data_bus;
                {r, w} = 2'b00;
            end else begin
                {r, w} = 2'b10;
            end
            case (operator[1:0])
                2'b01: {rg[erg1_rg1], rg[erg1_rg2]} = erg[erg1] + 16'b1;
                2'b10: {rg[erg1_rg1], rg[erg1_rg2]} = erg[erg1] - 16'b1;
            endcase
            reset_cycle_on_5 = 1;
        end
        `GROUP_SINGLE_REG: begin
            case (operator)
                `OP_POP: begin
                     {r, w} = 2'b00;   
                     rg[rg1] = data_bus;
                     sp <= sp - 16'h0001;
                end
                `OP_PUSH: begin
                     {r, w} = 2'b01;
                     sp <= sp + 16'h0001;
                end
            endcase
            reset_cycle_on_5 = 1;
        end
        `GROUP_RETURN: begin
            pc[15:8] = data_bus;
            {r, w} = 1'b00;
            reset_cycle_on_5 = 0;
        end
        `GROUP_EXTENDED: begin
            case (operator)
               `OP_JMP: begin
                      {r, w} = 2'b00;
                      pc[7:0] = data_bus;
                end
                `OP_CALL: begin
                      {r, w} = 2'b01;
                end
           endcase
           reset_cycle_on_5 = 0;
        end
        default: reset_cycle_on_5 = 1;
    endcase
end endtask

task third_extend_action;
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
        end
        `GROUP_EXTENDED: begin
            case (operator)
                `OP_JMP: begin
                    {r, w} = 2'b00;
                    pc[15:8] = data_bus;
                end
                `OP_CALL: begin
                    {r, w} = 2'b00;
                    sp <= sp + 16'h0002;
                    reset_cycle_to_4 = 1;
                    //operator = `OP_JMP; //im too lazy to write more cycles lol
                end
            endcase
        end
    endcase
end endtask