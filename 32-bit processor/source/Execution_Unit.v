
`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         April 17, 2016 
// Module Name:  Execution_Unit.v  
// Version:      1.00 
// Description:  This is an execution unit which
//				 executes various instructions de-
//				 pendent upon its various inputs.
//				 Instructios are read from an in-
//				 struction unit and operations are
//				 performed through an integer data-
//				 path.
//               
/////////////////////////////////////////////////////////////////////////////////
module Execution_Unit(sys_clk, sys_rst, pc_ld, pc_inc, im_cs, im_rd,
	ir_ld, pc_sel, D_En, T_addr, T_sel, FS, c, v, n, z, DY_dat,
	DY_io, DY_sel, Y_sel, HILO_ld, D_out, DA_sel, IR_out, ALU_out);
	
	input         sys_clk, sys_rst, pc_ld, pc_inc, im_cs, im_rd,
					  ir_ld, D_En, T_sel, DY_sel, HILO_ld;
	input   [2:0] Y_sel;
	input   [1:0] pc_sel, DA_sel;
	input   [4:0] FS, T_addr;
	input  [31:0] DY_dat, DY_io;
	output [31:0] D_out, IR_out, ALU_out;
	output        c, v, n, z;
	
	wire [31:0] SE_16, PC_out;
	
	
	// an instantiation of an instruction unit
	Instruction_Unit IU (sys_clk, sys_rst, pc_ld, pc_inc, im_cs, im_rd,
								ir_ld, ALU_out, PC_out, IR_out, SE_16, pc_sel);
	
	// an instantiation of an Integer Datapath unit
	Integer_Datapath IDP (sys_clk, sys_rst, D_En, IR_out[15:11], IR_out[25:21],
								 T_addr, SE_16, T_sel, FS, IR_out[10:6], c, v, n,
								 z, DY_dat, DY_io, DY_sel, PC_out, Y_sel, HILO_ld,
								 ALU_out, D_out, DA_sel);
								 
endmodule
