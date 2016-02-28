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
        zero = &rg[reg_num];
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
        zero = &erg[ereg_num];
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

task single_compute;
    input byte value;
    bit old_sign;
begin
    $display("%s %s", operator_group.name(), single_operator.name());
    old_sign = rg[reg_num][7];
    case (single_operator)
        OP_NEG: rg[reg_num] = 8'b0 - value;
        OP_COM: rg[reg_num] = 8'hFF - value;
        OP_LSL: {carry, rg[reg_num]} = {value, 1'b0};
        OP_LSR: {rg[reg_num], carry} = {1'b0, value};
        OP_ROL: rg[reg_num] = {value[6:0], value[7]};
        OP_ROR: rg[reg_num] = {value[0], value[7:1]};
        OP_RLC: {carry, rg[reg_num]} = {value, carry};
        OP_RRC: {rg[reg_num], carry} = {carry, value};
    endcase
    if (single_operator != OP_POP
            && single_operator != OP_PUSH) begin
        overflow = old_sign ^ rg[reg_num][7];
        zero = &rg[reg_num];
        negative = rg[reg_num][7];
        cycle = 0;
    end else begin
        cycle = 4;
    end
end endtask;

task single_compute16;
    input shortint value;
    bit old_sign;
begin
    $display("%s %s", operator_group.name(), single_operator.name());
    old_sign = rg[reg_num+1][15];
    case (single_operator)
        OP_NEG: {rg[reg_num+1], rg[reg_num]} = 16'b0 - value;
        OP_COM: {rg[reg_num+1], rg[reg_num]} = 16'hFFFF - value;
        OP_LSL: {carry, rg[reg_num+1], rg[reg_num]} = {value, 1'b0};
        OP_LSR: {rg[reg_num+1], rg[reg_num], carry} = {1'b0, value};
        OP_ROL: {rg[reg_num+1], rg[reg_num]} = {value[14:0], value[15]};
        OP_ROR: {rg[reg_num+1], rg[reg_num]} = {value[0], value[15:1]};
        OP_RLC: {carry, rg[reg_num+1], rg[reg_num]} = {value, carry};
        OP_RRC: {rg[reg_num+1], rg[reg_num], carry} = {carry, value};
    endcase
    overflow = old_sign ^ rg[reg_num][7];
    zero = &rg[reg_num];
    negative = rg[reg_num][7];
    cycle = 0;
end
endtask;

task others_compute;
begin
    case(other_operator)
        OP_HLT: begin halt = 1; $finish; end
        OP_CLC: carry = 1'b0;
        OP_CLZ: zero = 1'b0;
        OP_CLO: overflow = 1'b0;
        OP_CLN: negative = 1'b0;
        OP_STC: carry = 1'b1;
        OP_STZ: zero = 1'b1;
        OP_STO: overflow = 1'b1;
        OP_STN: negative = 1'b1;
    endcase
    cycle = other_operator != OP_RET? 0 : 4;
end endtask