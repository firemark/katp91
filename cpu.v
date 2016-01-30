module cpu (clk, reset, date_bus, adress_bus, r, w, halt);
	input reg clk /*verilator clocker*/;
	input reg reset;
	inout reg [7:0] date_bus;
	output reg [15:0] adress_bus;
	output reg r, w;
	output reg halt;
	
	byte registers[0:15];
	bit [15:0] pc;
	bit [3:0] counter;
	bit carry;
	bit zero;
	bit overflow;
	bit negative;
	
	bit [3:0] reg_num;
	bit [3:0] i;
	enum bit [3:0] {
		OP_ADD = 'b0000,
		OP_SUB = 'b0010,
		OP_AND = 'b0100,
		OP_OR = 'b0110,
		OP_XOR = 'b1000,
		OP_MOV = 'b1010,
		OP_CMP = 'b1100,
		OP_ADC = 'b0001,
		OP_SBC = 'b0101
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
	
	enum bit [2:0] {
		GROUP_MATH_CONSTANT = 'b000,
		GROUP_MATH_REG = 'b001,
		GROUP_BRANCH_JUMPS = 'b010,
		GROUP_OTHERS = 'b110,
		GROUP_WRONG = 'b111
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
	begin
		$display("%s %s R%h VAL %h (%d)", 
			operator_group.name(), math_operator.name(), 
			reg_num, value, value);
		case(math_operator)
			OP_ADD:  {carry, registers[reg_num]} <= registers[reg_num] + value;
			OP_SUB: {carry, registers[reg_num]} <= registers[reg_num] - value;
			OP_AND: registers[reg_num] <= registers[reg_num] & value;
			OP_OR: registers[reg_num] <= registers[reg_num] | value;
			OP_XOR: registers[reg_num] <= registers[reg_num] ^ value;
			OP_CMP: registers[reg_num] <= 0;
			OP_MOV: registers[reg_num] <= value;
			default: registers[reg_num] <= 0;
		endcase
	end endtask

	task check_first_byte;
		input byte first_byte;
	begin
		if (first_byte[0] == 1'b0 || first_byte[1:0] == 2'b10) begin //MATH CONSTANT GROUP
			reg_num = first_byte[7:4];
			math_operator = first_byte[3:0];
			operator_group = GROUP_MATH_CONSTANT;
		end else if (first_byte[1:0] == 2'b01) begin //BRANCH JUMPS GROUP
			operator_group = GROUP_BRANCH_JUMPS;
		end else if (first_byte[3:0] == 4'b0111) begin //MATH REG GROUP
			math_operator = first_byte[7:4];
			operator_group = GROUP_MATH_REG;
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
				compute(registers[second_byte[7:4]]);
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
						i<<1, registers[i<<1], registers[i<<1],
						(i<<1)+1'b1, registers[(i<<1)+1'b1], registers[(i<<1)+1'b1]);
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
