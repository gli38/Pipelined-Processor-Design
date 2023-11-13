`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage. 	
    wire reg_dst;
    wire branch;
    
    wire control_sel;
    
    wire control_mem_to_reg;
    wire control_mem_read;
    wire control_mem_write;
    wire control_alu_src;
    wire control_reg_write;
    wire [1:0] control_alu_op;
    
    
    register_file reg_file (
        .clk(clk),
        .reset(reset),
        .reg_write_en(mem_wb_reg_write),
        .reg_write_dest(mem_wb_write_reg_addr),
        .reg_write_data(mem_wb_write_back_data),
        .reg_read_addr_1(instr[25:21]), 
        .reg_read_addr_2(instr[20:16]), 
        .reg_read_data_1(reg1),
        .reg_read_data_2(reg2));

    mux2 #(.mux_width(5)) ID_mux1 
    (   .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .y(destination_reg));

    sign_extend sign_ex_inst (
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(imm_value));
        
    control control_unit (
        .reset(reset),
        .opcode(instr[31:26]),
        .reg_dst(reg_dst),
        .mem_to_reg(control_mem_to_reg),
        .alu_op(control_alu_op),
        .mem_read(control_mem_read),
        .mem_write(control_mem_write),
        .alu_src(control_alu_src),
        .reg_write(control_reg_write),
        .jump(jump),
        .branch(branch));
    
    assign control_sel = (~Data_Hazard) & Control_Hazard;
        
    assign jump_address = instr[25:0] << 2;

    assign branch_address = ((imm_value << 2) + pc_plus4);
    
    assign branch_taken = branch & ((reg1 ^ reg2)==32'd0 ? 1'b1: 1'b0);
    
    mux2 #(.mux_width(1)) mem_to_reg_out
    (   .a(control_mem_to_reg),
        .b(1'b0),
        .sel(control_sel),
        .y(mem_to_reg));
        
     mux2 #(.mux_width(2)) alu_op_out
    (   .a(control_alu_op),
        .b(2'b00),
        .sel(control_sel),
        .y(alu_op));
        
     mux2 #(.mux_width(1)) mem_read_out
    (   .a(control_mem_read),
        .b(1'b0),
        .sel(control_sel),
        .y(mem_read));
        
     mux2 #(.mux_width(1)) mem_write_out
    (   .a(control_mem_write),
        .b(1'b0),
        .sel(control_sel),
        .y(mem_write));
     
     mux2 #(.mux_width(1)) alu_src_out
    (   .a(control_alu_src),
        .b(1'b0),
        .sel(control_sel),
        .y(alu_src));   
        
     mux2 #(.mux_width(1)) reg_write_out
    (   .a(control_reg_write),
        .b(1'b0),
        .sel(control_sel),
        .y(reg_write));   
        
              
endmodule
