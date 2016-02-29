`include "cpu_data.v"

module cpu(clk, reset, data_bus, address_bus, r, w, halt);
	input reg clk /*verilator clocker*/;
	input reg reset;
	inout reg [7:0] data_bus;
	output reg [15:0] address_bus;
	output reg r, w;
	output reg halt;
	
	byte rg[0:15]; //8bit registers
    shortint erg[0:3]; //16bit extended registers
	shortint pc; //programer counter
	shortint sp; //stack pointer
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
	bit [1:0] mem_ereg_num;
	bit [3:0] i;
    bit [8:0] pc_branch_jump;

	Math_operator math_operator;
	Other_operator other_operator;
	Branch_operator branch_operator;
	Reg_memory_operator reg_memory_operator;
	Single_operator single_operator;
	Extended_operator extended_operator;
	Operator_group operator_group;

	`include "cpu_computes.v"
	`include "cpu_decoder.v"
	
	initial begin
		halt = 0;
		cycle = 0;
		pc = 16'h2000;
		sp = 16'h1c00;
	end
	
	always @(reset) begin
		if (~reset) begin
			halt = 0;
			cycle = 0;
			pc = 16'h2000;
			sp = 16'h1f00;
		end
	end
	
	always @(posedge clk or negedge clk, negedge reset) begin
		if (~halt) case(cycle)
			0: begin
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

				address_bus = pc;
				pc = pc + 16'b1;
				data_bus = 8'bz;
				r = 1'b1;
				w = 1'b0;
				cycle = 1;
			end
			1: begin
				r = 1'b0;
				check_first_byte(data_bus);
				cycle = 2;
			end
			2: begin
				address_bus = pc;
				pc = pc + 16'b1;
				data_bus = 8'bz;
				r = 1'b1;
				cycle = 3;
			end
			3: begin
				r = 1'b0;
				check_second_byte(data_bus);
			end
			4: begin
				first_extend_action();
				cycle = 5;
			end
			5: begin
				second_extend_action();
			end
			6: begin
				third_extend_action();
			end
			7: begin
				fourth_extend_action();
			end
			default: cycle = 0;
		endcase
	end
	
endmodule
