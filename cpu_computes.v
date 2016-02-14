`include "cpu_data.v"

task compute;
    input byte value;
    bit old_sign;
    byte temp;
begin
    $display("%s %s R%h VAL %h (%d)", 
        operator_group.name(), math_operator.name(), 
        reg_num, value, value);
    old_sign = rg[reg_num][7];
    case(math_operator)
        OP_ADD: 
            {carry, rg[reg_num]} = {1'b0, rg[reg_num]} + {1'b0, value};
        OP_SUB: 
            {carry, rg[reg_num]} = {1'b0, rg[reg_num]} - {1'b0, value};
        OP_ADC:
            {carry, rg[reg_num]} = {1'b0, rg[reg_num]} + {1'b0, value} + {8'b0, carry};
        OP_SBC:
            {carry, rg[reg_num]} = {1'b0, rg[reg_num]} - {1'b0, value} - {8'b0, carry};
        OP_AND: rg[reg_num] = rg[reg_num] & value;
        OP_OR: rg[reg_num] = rg[reg_num] | value;
        OP_XOR: rg[reg_num] = rg[reg_num] ^ value;
        OP_CMP: begin
            {carry, temp} = rg[reg_num] - value;
            overflow = old_sign ^ temp;
            zero = temp == 8'b0;
            negative = temp[7];
        end
        OP_MOV: rg[reg_num] <= value;
        default: rg[reg_num] <= 0;
    endcase
    if (math_operator != OP_CMP && math_operator != OP_MOV) begin
        overflow = old_sign ^ rg[reg_num][7];
        zero = rg[reg_num] == 8'b0;
        negative = rg[reg_num][7];
    end
end endtask

task compute16;
    input shortint value;
    bit [1:0] ereg_num;
    bit old_sign;
    shortint temp;
    assign ereg_num = reg_num[2:1];
begin
    $display("%s %s ER%h VAL %h (%d)", 
        operator_group.name(), math_operator.name(), 
        ereg_num, value, value);
    old_sign = erg[ereg_num][15];
    case(math_operator)
        OP_ADD:
            {carry, rg[reg_num+1], rg[reg_num]} = {1'b0, erg[ereg_num]} + {1'b0, value};
        OP_SUB:
            {carry, rg[reg_num+1], rg[reg_num]} = {1'b0, erg[ereg_num]} - {1'b0, value};
        OP_ADC:
            {carry, rg[reg_num+1], rg[reg_num]} = {1'b0, erg[ereg_num]} + {1'b0, value} + {16'b0, carry};
        OP_SBC:
            {carry, rg[reg_num+1], rg[reg_num]} = {1'b0, erg[ereg_num]} - {1'b0, value} - {16'b0, carry};
        OP_AND: {rg[reg_num+1], rg[reg_num]} = erg[ereg_num] & value;
        OP_OR: {rg[reg_num+1], rg[reg_num]} = erg[ereg_num] | value;
        OP_XOR: {rg[reg_num+1], rg[reg_num]} = erg[ereg_num] ^ value;
        OP_CMP: begin
            {carry, temp} = erg[ereg_num] - value;
            overflow = old_sign ^ temp;
            zero = temp == 16'b0;
            negative = temp[15];
        end
        OP_MOV: {rg[reg_num+1], rg[reg_num]} = value;
        default: {rg[reg_num+1], rg[reg_num]} = 1'b0;
    endcase
    if (math_operator != OP_CMP && math_operator != OP_MOV) begin
        overflow = old_sign ^ erg[ereg_num][15];
        zero = erg[ereg_num] == 16'b0;
        negative = erg[ereg_num][15];
    end
end endtask

function bit check_branch;
begin
    $display("%s %s", operator_group.name(), branch_operator.name());
    case (branch_operator)
        OP_BREQ: check_branch = zero;
        OP_BRNE: check_branch = ~zero;
        OP_BRLT: check_branch = negative ^ overflow;
        OP_BRGE: check_branch = ~(negative ^ overflow);
        OP_BRC: check_branch = carry;
        OP_BRNC: check_branch = ~carry;
        OP_BRO: check_branch = overflow;
        OP_BRNO: check_branch = ~overflow;
        OP_BRN: check_branch = negative;
        OP_BRNN: check_branch = ~negative;
        OP_BRLO: check_branch = carry;
        OP_BRSH: check_branch = ~carry;
        OP_RJMP: check_branch = 1'b1;
    endcase
end endfunction