`include "cpu_data.v"

module Cpu(clk, reset, data_bus, address_bus, r, w, halt);
	input clk /*verilator clocker*/;
	input reset;
	inout [7:0] data_bus;
	output reg[15:0] address_bus;
	output reg r, w;
	output reg halt;
	
	reg [7:0] data_bus_out;
	assign data_bus = w? data_bus_out : 8'bz;
	
	reg[7:0] rg[0:15]; //8reg registers
    wire[15:0] erg[0:3]; //16reg extended registers
	reg[15:0] pc; //programer counter
	reg[15:0] sp; //stack pointer
	reg[3:0] cycle  /*verilator public*/;
	reg carry;
	reg zero;
	reg overflow;
	reg negative;
	
    assign erg[3] = {rg[15], rg[14]};
    assign erg[2] = {rg[13], rg[12]};
    assign erg[1] = {rg[11], rg[10]};
    assign erg[0] = {rg[9], rg[8]};

    wire[3:0] pre_reg_num;
	reg[3:0] reg_num;
	reg[1:0] mem_ereg_num;
	reg[3:0] i;

    wire[8:0] pre_pc_branch_jump;
    reg[8:0] pc_branch_jump;

    wire[4:0] pre_operator;
	reg[4:0] operator;
	wire[3:0] math_operator;
	wire[4:0] other_operator;
	wire[4:0] branch_operator;
	wire[3:0] reg_memory_operator;
	wire[4:0] single_operator;
	wire[4:0] extended_operator;
	wire[4:0] operator_group;
	
	assign math_operator = operator[3:0];
	assign other_operator = operator;
	assign branch_operator = operator;
	assign reg_memory_operator = operator[3:0];
	assign single_operator = operator;
	assign extended_operator = operator;
    
    reg [15:0] alu_value1;
    reg [15:0] alu_value2;
    wire [15:0] alu_result;
    reg alu_old_sign, compute_signal, compute_single_signal;
    wire alu_carry, alu_overflow, alu_zero, alu_negative;
    
    Alu alu(
        operator, alu_value1, alu_value2,
        alu_result, alu_old_sign,
        alu_carry, alu_overflow, alu_zero, alu_negative,
        compute_signal, compute_single_signal);
        
    reg first_byte_latch;
    CpuDecodeFirstByte cpu_first_byte(
        first_byte_latch, data_out, pre_operator,
        operator_group, pre_reg_num, pre_pc_branch_jump);
        
    wire check_branch;
    CheckBranch checkBranch(
        branch_operator, check_branch,
        carry, overflow, zero, negative);
	
	initial begin
		halt = 0;
		cycle <= 0;
        first_byte_latch <= 0;
		pc <= 16'h2000;
		sp <= 16'h1c00;
	end
	
	always @(posedge clk, posedge reset, posedge halt) begin
		if (halt) begin
			cycle <= 0;
		end else if (reset) begin
			halt = 0;
			cycle <= 0;
			pc <= 16'h2000;
			sp <= 16'h1c00;
		end else case(cycle)
			0: begin
				//$display("PC %h ADDR %h DATA %h SP %h", 
				//	pc, address_bus, data_bus, sp);
				//$display("ZERO %b CARRY %b OVERFLOW %b NEGATIVE %b HALT %b",
				//	zero, carry, overflow, negative, halt);
				//for(i=0; i < 8; i=i+1) begin
				//	$display("R%h = %h (%d) R%h = %h (%d)", 
				//		i<<1, rg[i<<1], rg[i<<1],
				//		(i<<1)+1'b1, rg[(i<<1)+1'b1], rg[(i<<1)+1'b1]);
				//end
                //for(i=0; i < 4; i=i+1) begin
                //    $display("ER%h = %h (%d)", i, erg[i], erg[i]);
                //end

				address_bus <= pc;
				pc <= pc + 16'b1;
				r <= 1'b1;
				w <= 1'b0;
				cycle <= 1;
			end
			1: begin
				r <= 1'b0;
                first_byte_latch <= 1;
				cycle <= 2;
			end
			2: begin
                first_byte_latch <= 0;
				address_bus <= pc;
				pc <= pc + 16'b1;
				r <= 1'b1;
				w <= 1'b0;
				cycle <= 3;
			end
			3: begin
				r <= 1'b0;
				w <= 1'b0;
				check_second_byte(data_bus);
			end
			4: begin
				first_extend_action();
				cycle <= 5;
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
			default: cycle <= 0;
		endcase
	end
	
	`include "cpu_computes.v"
	`include "cpu_decoder.v"
endmodule
