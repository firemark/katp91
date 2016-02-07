module cpu (clk, reset, date_bus, adress_bus, r, w, halt);
	input reg clk /*verilator clocker*/;
	input reg reset;
	inout reg [7:0] date_bus;
	output reg [15:0] adress_bus;
	output reg r, w;
	output reg halt;
	
	byte rg[0:15]; //8bit registers
    shortint erg[0:3]; //16bit extended registers
	shortint pc; //programer counter
	bit [3:0] counter; //cycle
	bit carry;
	bit zero;
	bit overflow;
	bit negative;
	
    assign erg[3] = {rg[15], rg[14]};
    assign erg[2] = {rg[13], rg[12]};
    assign erg[1] = {rg[11], rg[10]};
    assign erg[0] = {rg[9], rg[8]};

	bit [3:0] reg_num;
	bit [3:0] i;
    bit [8:0] pc_branch_jump;
	enum bit [3:0] {
		OP_ADD = 'b0000,
		OP_SUB = 'b0010,
		OP_AND = 'b0100,
		OP_OR = 'b0110,
		OP_XOR = 'b1000,
		OP_MOV = 'b1010,
		OP_CMP = 'b1100,
		OP_ADC = 'b0001,
		OP_SBC = 'b0011
		//OP_SWP = 'b1000
	} math_operator;

	enum bit [2:0] {
		OP_CLC = 'b000,
		OP_CLZ = 'b001,
		OP_CLO = 'b010,
		OP_CLN = 'b011,
		OP_WTF = 'b100,
		OP_NOP = 'b110,
		OP_HLT = 'b111
	} other_operator;
	
    enum bit [3:0] {
        OP_BREQ = 'b0000, //equality
        OP_BRNE = 'b0001, //not equality
        OP_BRLT = 'b0010, //less than
        OP_BRGE = 'b0011, //great and eq
        OP_BRC = 'b00100, //carry
        OP_BRO = 'b0101, //overflow
        OP_BRN = 'b0110, //negative
        OP_BRNC = 'b0111, //not carry
        OP_BRNO = 'b1000, //not  overflow
        OP_BRNN = 'b1001, //not negative
        OP_BRLO = 'b1010, //lower 
        OP_BRSH = 'b1011, //same and higher
        OP_RJMP = 'b1100 //restricted jump
    } branch_operator;

	enum bit [2:0] {
		GROUP_MATH_CONSTANT,
		GROUP_MATH_REG,
		GROUP_MATH_EREG,
		GROUP_BRANCH_JUMPS,
		GROUP_OTHERS,
		GROUP_WRONG
	} operator_group;
	
	initial begin
		halt = 0;
		counter = 0;
		pc = 16'h2000;
	end
	
	always @(reset) begin
		if (~reset) begin
			halt = 0;
			counter = 0;
			pc = 16'h2000;
		end
	end
	
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
			OP_ADD: {carry, rg[reg_num]} = {1'b0, rg[reg_num]} + {1'b0, value};
			OP_SUB: {carry, rg[reg_num]} = {1'b0, rg[reg_num]} - {1'b0, value};
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
		if (math_operator != OP_CMP) begin
			overflow = old_sign ^ rg[reg_num][7];
			zero = rg[reg_num] == 8'b0;
			negative = rg[reg_num][7];
			$display("flags: Ov:%b Z:%b N:%b C:%b", overflow, zero, negative, carry);
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
			default: {rg[reg_num+1], rg[reg_num]} = 0;
		endcase
		if (math_operator != OP_CMP) begin
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
			OP_BRSH: check_branch = zero | carry;
			OP_BRLO: check_branch = zero | carry;
			OP_RJMP: check_branch = 1;
		endcase
	end endfunction

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
				counter = 0;
			end
			GROUP_MATH_REG: begin
				reg_num = second_byte[3:0];
				compute(rg[second_byte[7:4]]);
				counter = 0;
			end
			GROUP_MATH_EREG: begin
                math_operator[3] = second_byte[0];
				reg_num = {1'b1, second_byte[2:1], 1'b0};
				compute16(erg[second_byte[4:3]]);
				counter = 0;
			end
            GROUP_BRANCH_JUMPS: begin
                pc_branch_jump[7:0] = second_byte;
                if (check_branch())
                    pc = pc + {{7{pc_branch_jump[8]}}, pc_branch_jump} - 2;
                counter = 0;
            end
			GROUP_OTHERS: begin
				case(other_operator)
					OP_HLT: begin halt = 1; $finish; end
				endcase
				counter = 0;
			end
			default: begin
				$display("%s", operator_group.name());
				pc = pc + 16'b1;
				counter = 0;
			end
		endcase
	end endtask
	
	always @(posedge clk or negedge clk, negedge reset) begin
		if (~halt) case(counter)
			0: begin
				$display("PC %h ADDR %h DATA %h HALT %b", 
					pc, adress_bus, date_bus, halt);
				$display("ZERO %b CARRY %b OVERFLOW %b NEGATIVE %b",
					zero, carry, overflow, negative);
				for(i=0; i < 8; i=i+1) begin
					$display("R%h = %h (%d) R%h = %h (%d)", 
						i<<1, rg[i<<1], rg[i<<1],
						(i<<1)+1'b1, rg[(i<<1)+1'b1], rg[(i<<1)+1'b1]);
				end
                for(i=0; i < 4; i=i+1) begin
                    $display("ER%h = %h (%d)", i, erg[i], erg[i]);
                end

				adress_bus = pc;
				pc = pc + 16'b1;
				date_bus = 8'bz;
				r = 1'b1;
				counter = 1;
			end
			1: begin
				r = 1'b0;
				check_first_byte(date_bus);
				counter = 2;
			end
			2: begin
				adress_bus = pc;
				pc = pc + 16'b1;
				date_bus = 8'bz;
				r = 1'b1;
				counter = 3;
			end
			3: begin
				r = 1'b0;
				check_second_byte(date_bus);
			end
			default: counter = 0;
		endcase
	end
	
endmodule
