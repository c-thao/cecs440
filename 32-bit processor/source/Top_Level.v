
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     CSULB Student
// Engineer:    Chou Thao
// Date:        April 17, 2016 
// Module Name: Top_Level.v  
// Version:     1.00 
// Description: This module instantiates a CPU, a data
//				memory, and an IO memory. It achieves
//				communication between the three modules
//				through share wires.
//					  
//               
//////////////////////////////////////////////////////////////////////////////////
module Top_Level(sys_clk, sys_rst);

	input sys_clk, sys_rst;
	
	// Outputs
	wire int_ack, ie, mem_out;
	wire dm_cs, dm_wr, dm_rd;
	wire io_cs, io_wr, io_rd;
	wire [31:0] Addr, D_In, DY_dat, DY_io;
	
	always @(negedge sys_clk) begin
		if (mem_out == 1'b1) begin
			$display("t=%t M[3F0]=%h", $time,
			{Data_Mem.mem[12'h3F0],
			 Data_Mem.mem[12'h3F1],
			 Data_Mem.mem[12'h3F2],
			 Data_Mem.mem[12'h3F3]});
		end
	end
	
	// Instantiation of CPU
	CPU        Main (sys_clk, sys_rst, ie, int_ack, intr, dm_cs, dm_wr,
						  dm_rd, io_cs, io_wr, io_rd, Addr, D_In, DY_dat,
						  DY_io, mem_out);
	
	// Instantiation of Data Memory
	Memory Data_Mem (sys_clk, dm_cs, dm_wr, dm_rd, Addr, D_In, DY_dat);
	
	// Instantiation of IO Memory
	IO_Mem  IO_Mem (sys_clk, ie, int_ack, intr, io_cs, io_wr, io_rd, Addr,
					    D_In, DY_io);

endmodule
