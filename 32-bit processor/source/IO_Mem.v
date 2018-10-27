`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         March 7, 2016 
// Module Name:  IO_Mem.v  
// Version:      1.00 
// Description:  This is a memory module which takes an
//				 32 bit address to specify a location of
//				 its mem array to read, D_Out or write  
//				 into, D_In. The memory splits a 32 bit
//				 value, D_In, if dm_cs and dm_wr are both
//				 active high into 4 bytes to write into
//				 memory. If dm_cs and dm_rd are active 
//				 high then a 32 bit value is created 
//				 starting from a specified address is
//				 read and incremented from mem array
//				 into an output D_Out.
//               
//////////////////////////////////////////////////////////////////////////////////
module IO_Mem(clk, ie, int_ack, intr, dm_cs, dm_wr, dm_rd, Addr, D_In, D_Out);
	input         clk, dm_cs, dm_wr, dm_rd, int_ack, ie;
	input  [31:0] Addr;
	input  [31:0] D_In;
	output [31:0] D_Out;
	output reg    intr;

	// 1024x32 bit memory array store
	// in big endian format 4 bytes
	// at a times
	reg [7:0] mem[0:4095];
	
	
	// if int_ack is high
	// set interrupt flag
	// ie high, else if
	// intf is high set
	// interrupt flag low
	always @(*) begin
		if (ie == 1'b1) begin
			intr = 1'b1;
		end
		else if(int_ack == 1'b1) begin
			intr = 1'b0;
		end
		else begin
			intr = intr;
		end
	end
	
	
	// writing to data memory
	// 4 bytes of memory each
	// individually with the
	// upper bytes going to
	// lower memory location
	// and lower bytes going
	// to upper memory location
	// if dm_cs and dm_wr are
	// high
	always@(posedge clk) begin
		if({dm_cs,dm_wr} == 2'b11) begin
			mem[Addr+0] = D_In[31:24];
			mem[Addr+1] = D_In[23:16];
			mem[Addr+2] = D_In[15:8];
			mem[Addr+3] = D_In[7:0];
		end
		else begin
			{mem[Addr+0],mem[Addr+1],
			 mem[Addr+2],mem[Addr+3]}
			 = {mem[Addr+0],mem[Addr+1],
			    mem[Addr+2],mem[Addr+3]};
		end
	end
	
	// reading from data memory
	// 4 bytes of memory for a
	// 32 bit output D_Out if
	// dm_cs and dm_rd are high
	assign D_Out = ({dm_cs,dm_rd} == 2'b11) ?
						 {mem[Addr+0],mem[Addr+1],
						  mem[Addr+2],mem[Addr+3]}:
						  D_Out;

endmodule
