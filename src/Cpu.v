`include "cpu_data.v"
`define REGISTER_SIDE(r, n) {8'h00, n[0]? r[15:8] : r[7:0]}

module Cpu(clk, reset, data_bus, address_bus, r, w, interrupts, halt);
    input clk /*verilator clocker*/;
    wire inv_clk; assign inv_clk = !clk;
    input reset;
    input [7:0] interrupts;
    inout [15:0] data_bus;
    output reg [15:0] address_bus;
    output reg r; output w; reg _w;
    output reg halt;
    
    parameter [3:0]
        CYCLE_0 = 0,
        CYCLE_1 = 1,
        CYCLE_2 = 2,
        CYCLE_3 = 3,
        CYCLE_4 = 4,
        CYCLE_5 = 5;
    reg [3:0] cycle  /*verilator public*/;

    reg [15:0] pc_register, sp_register, data_register, tmp_register;
    assign data_bus = _w? data_register : 16'bz;
    assign w = _w & !clk;

    reg [15:0] word;
    wire [7:0] val, decoder_flags;
    wire [3:0] operator;
    wire [3:0] operator_group;
    wire [2:0] num_rg1, num_rg2;
    wire [9:0] relative_addr;

    Decoder decoder(
        .word(word),
        .operator_group(operator_group),
        .operator(operator),
        .val(val),
        .flags(decoder_flags),
        .rg1(num_rg1),
        .rg2(num_rg2),
        .relative_addr(relative_addr));

    reg [7:0] flags;
    wire is_checked;
    CheckBranch check_branch(
        .operator(operator),
        .flags(flags),
        .is_checked(is_checked)
    );

    reg [1:0] cs_write_registers;
    reg [15:0] register_in;
    wire [15:0] register_out [0:1];
    Registers registers(
        .clk(clk),
        .num1(num_rg1[2:1]),
        .num2(num_rg2[2:1]),
        .write(cs_write_registers),
        .bus_in(register_in),
        .bus_out1(register_out[0]),
        .bus_out2(register_out[1])
    );

    wire [15:0] alu_out;
    wire [3:0] alu_flags, alu_flags8;
    wire old_carry; assign old_carry = flags[3];
    reg [15:0] alu_in [0:1];
    Alu alu(
        .single(operator_group == `GROUP_CRSMATH || operator_group == `GROUP_WRSMATH),
        .value1(alu_in[0]),
        .value2(alu_in[1]),
        .operator(operator),
        .bus_out(alu_out),
        .alu_flags(alu_flags),
        .alu_flags8(alu_flags8),
        .old_carry(old_carry));

    initial begin
        halt = 0;
        cycle = CYCLE_0;
        pc_register = 16'h0000;
        sp_register = 16'h07FF;
    end

    always @ (posedge clk or posedge reset)
        if (reset)
            cycle <= CYCLE_0;
        else case(cycle)
            CYCLE_0: cycle <= CYCLE_1;
            CYCLE_1: cycle <= CYCLE_2;
            CYCLE_2: cycle <= CYCLE_3;
            CYCLE_3: cycle <= (operator_group == `GROUP_SPECIAL_LONG && operator == `OP_CALL) ? CYCLE_4 : CYCLE_0;
            CYCLE_4: cycle <= CYCLE_5;
            CYCLE_5: cycle <= CYCLE_0;
            default: cycle <= CYCLE_0;
        endcase 
        
    always @ (cycle or operator_group or operator)
        casez({cycle, operator_group})
            {CYCLE_1, 4'b????}: r = 1'b1;
            {CYCLE_3, `GROUP_WRRMATH_MEM}: r = !operator[2];
            {CYCLE_3, `GROUP_WRSMATH_STACK}: r = operator == `OP_POP;
            {CYCLE_3, `GROUP_SPECIAL}: r = operator == `OP_RET;
            default: r = 1'b0;
        endcase
        
    always @ (cycle or operator_group or operator)
        casez({cycle, operator_group})
            {CYCLE_3, `GROUP_WRRMATH_MEM}: _w = operator[2];
            {CYCLE_3, `GROUP_WRSMATH_STACK}: _w = operator == `OP_PUSH;
            {CYCLE_5, `GROUP_SPECIAL_LONG}: _w = operator == `OP_CALL;
            default: _w = 1'b0;
        endcase
    
    always @ (negedge clk)
        if (reset) begin
            address_bus <= 16'h0000;
            pc_register <= 16'h0000;
            sp_register <= 16'h07FF;
            cs_write_registers <= 2'b00;
            flags <= 8'h0;
        end else casez ({cycle, operator_group})
            {CYCLE_0, `GROUP_WRRMATH_MEM}: begin
                if (operator[1]) begin
                    cs_write_registers <= 2'b10;
                    register_in <= register_out[1] + 1;
                end else if (operator[1]) begin
                    cs_write_registers <= 2'b10;
                    register_in <= register_out[1] - 1;
                end else
                    cs_write_registers <= 2'b00;
                address_bus <= pc_register;
            end
            {CYCLE_0, 4'b????}: begin
                cs_write_registers <= 2'b00;
                address_bus <= pc_register;
            end
            {CYCLE_1, 4'b????}: begin
                cs_write_registers <= 2'b00;
                pc_register <= pc_register + 1;
                word <= data_bus;
            end
            {CYCLE_2, `GROUP_RJMP}: begin
                if (is_checked)
                    pc_register <= (
                        pc_register
                        + {{7{relative_addr[9]}}, relative_addr[8:0]}
                        - 1
                    );
            end
            {CYCLE_2, `GROUP_SFLAG}: begin
                flags <= flags | decoder_flags;
            end
            {CYCLE_2, `GROUP_UFLAG}: begin
                flags <= flags & ~decoder_flags;
            end
            {CYCLE_2, `GROUP_WRRMATH}: begin
                alu_in[0] <= register_out[0];
                alu_in[1] <= register_out[1];
            end
            {CYCLE_2, `GROUP_WRSMATH}: begin
                alu_in[0] <= register_out[0];
                alu_in[1] <= 16'h0000;
            end
            {CYCLE_3, `GROUP_WRRMATH}, {CYCLE_3, `GROUP_WRSMATH}: begin
                if (operator != `OP_CMP) begin
                    register_in <= alu_out;
                    cs_write_registers <= 2'b01;
                end

                flags[3:0] <= alu_flags;
            end
            {CYCLE_2, `GROUP_CRVMATH}, {CYCLE_2, `GROUP_CRSMATH}: begin
                alu_in[0] <= {8'h00, num_rg1[0] ? register_out[0][15:8] : register_out[0][7:0]};
                alu_in[1] <= {{8{val[7]}}, val}; // for single this code is not affected
            end
            {CYCLE_2, `GROUP_CRRMATH}: begin
                alu_in[0] <= {8'h00, num_rg1[0] ? register_out[0][15:8] : register_out[0][7:0]};
                alu_in[1] <= {8'h00, num_rg2[0] ? register_out[1][15:8] : register_out[1][7:0]};
            end
            {CYCLE_3, `GROUP_CRRMATH}, {CYCLE_3, `GROUP_CRSMATH}, {CYCLE_3, `GROUP_CRVMATH}: begin
                if (operator != `OP_CMP) begin
                    register_in <= (
                        num_rg1[0]
                        ? {alu_out[7:0], register_out[0][7:0]}
                        : {register_out[0][15:8], alu_out[7:0]}
                    );
                    cs_write_registers <= 2'b01;
                end
                flags[3:0] <= alu_flags8;
            end
            {CYCLE_2, `GROUP_WRRMATH_MEM}: begin
                if (operator[2])
                    data_register <= register_out[0];
                address_bus <= register_out[1];
            end
            {CYCLE_2, `GROUP_WRSMATH}: begin
                alu_in[0] <= register_out[0];
            end
            {CYCLE_3, `GROUP_WRRMATH_MEM}: begin
                if (!operator[2]) begin
                    register_in <= data_bus;
                    cs_write_registers <= 2'b01;
                end
            end
            {CYCLE_2, `GROUP_WRSMATH_STACK}: begin
                case (operator)
                    `OP_PUSH: begin
                        data_register <= register_out[0];
                        sp_register <= sp_register - 1;
                        address_bus <= sp_register;
                    end
                    `OP_POP: begin
                        sp_register <= sp_register + 1;
                        address_bus <= sp_register + 1;
                    end
                endcase
            end
            {CYCLE_3, `GROUP_WRSMATH_STACK}: begin
                case (operator)
                    `OP_POP: begin
                        register_in <= data_bus;
                    end
                endcase
            end
            {CYCLE_2, `GROUP_SPECIAL_LONG}: begin
                address_bus <= pc_register;
            end
            {CYCLE_3, `GROUP_SPECIAL_LONG}: begin
                case (operator)
                    `OP_JMP: begin
                        pc_register <= data_bus;
                    end
                    `OP_CALL: begin
                        tmp_register <= data_bus;
                    end
                endcase
            end
            {CYCLE_4, `GROUP_SPECIAL_LONG}: begin
                case (operator)
                    `OP_CALL: begin
                        data_register <= pc_register;
                        sp_register <= sp_register - 1;
                        address_bus <= sp_register;
                    end
                endcase
            end
            {CYCLE_5, `GROUP_SPECIAL_LONG}: begin
                case (operator)
                    `OP_CALL: begin
                        pc_register <= tmp_register;
                    end
                endcase
            end
            {CYCLE_2, `GROUP_SPECIAL}: begin
                case (operator)
                    `OP_RET: begin
                        sp_register <= sp_register + 1;
                        address_bus <= sp_register + 1;
                    end
                endcase
            end
            {CYCLE_3, `GROUP_SPECIAL}: begin
                case (operator)
                    `OP_RET: begin
                        pc_register <= data_bus;
                    end
                endcase
            end
        endcase
    
endmodule
