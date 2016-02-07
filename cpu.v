`include "cpu_data.v"

module cpu(clk, reset, date_bus, adress_bus, r, w, halt);
	input reg clk /*verilator clocker*/;
	input reg reset;
	inout reg [7:0] date_bus;
	output reg [15:0] adress_bus;
	output reg r, w;
	output reg halt;
	
	byte rg[0:15]; //8bit registers
    shortint erg[0:3]; //16bit extended registers
	shortint pc; //programer counter
	bit [3:0] cycle;
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

	Math_operator math_operator;
	Other_operator other_operator;
	Branch_operator branch_operator;
	Operator_group operator_group;

	`include "cpu_computes.v"
	`include "cpu_decoder.v"
	
	initial begin
		halt = 0;
		cycle = 0;
		pc = 16'h2000;
	end
	
	always @(reset) begin
		if (~reset) begin
			halt = 0;
			cycle = 0;
			pc = 16'h2000;
		end
	end
	
	always @(posedge clk or negedge clk, negedge reset) begin
		if (~halt) case(cycle)
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
				cycle = 1;
			end
			1: begin
				r = 1'b0;
				check_first_byte(date_bus);
				cycle = 2;
			end
			2: begin
				adress_bus = pc;
				pc = pc + 16'b1;
				date_bus = 8'bz;
				r = 1'b1;
				cycle = 3;
			end
			3: begin
				r = 1'b0;
				check_second_byte(date_bus);
			end
			default: cycle = 0;
		endcase
	end
	
endmodule
