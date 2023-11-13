`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    // Write your code here
wire [31:0] mux2_output;
wire [31:0] mux1_output;
wire [31:0] mux3_output;
wire [3:0] alu_control;
wire zero;


mux4 #(.mux_width(32)) EX_mux1
    (   .a(reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .sel(Forward_A),
        .y(mux1_output)); 
        
mux4 #(.mux_width(32)) EX_mux2 
    (   .a(reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .sel(Forward_B),
        .y(mux2_output));        

mux2 #(.mux_width(32)) EX_mux3
    (   .a(mux2_output),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        .y(mux3_output)); 

ALU alu_EX 
    (
        .a(mux1_output),
        .b(mux3_output),
        .alu_control(alu_control),
        .zero(zero),
        .alu_result(alu_result));

ALUControl ALU_Control
    (
      .ALUOp(id_ex_alu_op),
      .Function(id_ex_instr[5:0]),
      .ALU_Control(alu_control));

assign alu_in2_out = mux2_output;    
       
endmodule
