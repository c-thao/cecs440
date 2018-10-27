`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         March 7, 2016 
// Module Name:  Memory.v  
// Version:      1.00 
// Description:  This is a readonly memory module which takes
//				 an 32 bit address to specify a location of
//				 its mem array to read, D_Out. If m_cs and
//				 m_rd are active high then a 32 bit value
//				 is created starting from a specified address
//				 is read and incremented from mem array into
//				 an output D_Out.
//               
//////////////////////////////////////////////////////////////////////////////////
module ReadOnlyMemory(clk, m_cs, m_rd, Addr, D_Out);
	input         clk, m_cs, m_rd;
	input  [31:0] Addr;
	output [31:0] D_Out;
	
	// 1024x32 bit memory array store
	// in big endian format 4 bytes
	// at a times
	reg [7:0] mem[0:4095];
	
	// reading from memory
	// 4 bytes of memory for a
	// 32 bit output D_Out if
	// m_cs and m_rd are high
	assign D_Out = ({m_cs,m_rd} == 2'b11) ?
						 {mem[Addr+0],mem[Addr+1],
						  mem[Addr+2],mem[Addr+3]}:
						  D_Out;

endmodule
