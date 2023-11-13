`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
// write your code here
    wire [9:0] mux1_output;
    wire [9:0] mux2_output;

mux2 #(.mux_width(10)) IF_mux1 
    (   .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        .y(mux1_output));

mux2 #(.mux_width(10)) IF_mux2 
    (   .a(mux1_output),
        .b(jump_address),
        .sel(jump),
        .y(mux2_output));

reg [9:0] pc;

always @(posedge clk or posedge reset)
    begin
        if(reset)
           pc <= 10'b0000000000;
        else if (en)
           pc <= pc_plus4;
    end
    
assign pc_plus4 = pc + 10'b0000000100;

instruction_mem inst_mem (
    .read_addr(pc),
    .data(instr));

          
endmodule
