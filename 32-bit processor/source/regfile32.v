`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         March 7, 2016
// Module Name:  regfile32.v  
// Version:      1.01
// Description:  This is a 32 bit register array which has three
//				 three address input, D_Addr, S_Addr, T_Addr. The
//			     three addresses are indexes into the register. The  
//				 S_Addr and T_Addr are for 32 bit output S and T re-
//				 spectively. D_Addr on the other hand is the address 
//			     in which to write into the register a 32 bit value,
//				 D, if D_En is asserted. The register first memory 
//				 location zero memory is set to all zeros if reset
//				 is high.
//					             
//////////////////////////////////////////////////////////////////////////////////
module regfile32(clk, reset, D_En, D_Addr, S_Addr, T_Addr, D, S, T);
	input         clk, reset, D_En;
	input   [4:0] D_Addr, S_Addr, T_Addr;
	input  [31:0] D;
	output [31:0] S, T;
	
	// 32 bit memory array
	reg [31:0] mem[31:0];
	
	// 32 bit outputs S and T dependent on
	// the 5 bit address indexed by S_addr
	// and T_Addr
	assign S = mem[S_Addr];
	assign T = mem[T_Addr];
	
	// if reset is high set memory location
	// zero to all zeroes, else check if D_En
	// is asserted the write to the memory lo-
	// cation indexed by D_Addr with the 32 bit
	// value of input D
	always @(posedge clk or posedge reset) begin
		if (reset)
			mem[0] = 32'h00000000;
		else if (D_En==1'b1 && D_Addr != 5'b0)
			mem[D_Addr] = D;
		else
			mem[D_Addr] = mem[D_Addr];
		end
	
endmodule
