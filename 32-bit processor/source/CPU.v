
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         April 17, 2016 
// Module Name:  CPU.v  
// Version:      1.01 
// Description:  This is a CPU which contains a control
//				 unit and an execution unit. The control
//			     unit generates control words to the exe-
//			     cution unit.
//               
//////////////////////////////////////////////////////////////////////////////////
module CPU(sys_clk, sys_rst, ie, int_ack, intr, dm_cs, dm_wr, dm_rd,
	io_cs, io_wr, io_rd, Addr, D_Out, DY_dat, DY_io, mem_out);
		
	input  		  sys_clk, sys_rst, intr;
	input  [31:0] DY_dat, DY_io;
	
	output 		  int_ack, ie;   //interrupt acknowledge
	output		  dm_cs, dm_rd, dm_wr, // needed by the IU, DP and Data Memory
					  io_cs, io_rd, io_wr,
					  mem_out;	 
	output [31:0] Addr, D_Out;
	
	wire [31:0] IR_out, Addr_out;
	
	wire [4:0] FS, T_addr;
	wire [2:0] Y_sel;
	wire [1:0] pc_sel, DA_sel;
	wire       pc_ld, pc_inc, ir_ld, //to contain all of the bits
				  im_cs, im_rd,         // for all the control word fields
				  D_En, T_sel, HILO_ld,
				  DY_sel, c, v, n, z;
	
	// memory only 12 bits addressable space
	assign Addr = {20'h0,Addr_out[11:0]};
	
	// CU control unit
	MCU              CU (sys_clk, sys_rst, intr, c, n, z, v, ie, IR_out,
								int_ack, FS, T_addr, Y_sel, pc_sel, DA_sel, pc_ld,
								pc_inc, ir_ld, im_cs, im_rd, dm_cs, dm_rd, dm_wr,
								io_cs, io_rd, io_wr, D_En, T_sel, HILO_ld, DY_sel,
								mem_out);
	
	// EU execution unit
	Execution_Unit   EU (sys_clk, sys_rst, pc_ld, pc_inc, im_cs, im_rd,
								ir_ld, pc_sel, D_En, T_addr, T_sel, FS, c, v,
								n, z, DY_dat, DY_io, DY_sel, Y_sel, HILO_ld,
								D_Out, DA_sel, IR_out, Addr_out);		

endmodule
