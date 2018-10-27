`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         March 7, 2016 
// Module Name:  regfile.v  
// Version:      1.01 
// Description:  This is an 32 bit register which sets an output 
//				 32 bit D_out to zero else if the D_En is high 
//				 then D_out takes the value of an 32 bit input
//				 D_in.
//               
//////////////////////////////////////////////////////////////////////////////////
module regfile(clk, reset, D_En, D_in, D_out);
	input             clk, reset, D_En;
	input      [31:0] D_in;
	output reg [31:0] D_out;
	
	// is reset is high D_out is zero
	// else if D_En is high D_out takes 
	// the value of D_in else D_out de-
	// faults to D_out
	always@(posedge clk or posedge reset) begin
		if (reset)
			D_out = 32'h0;
		else if (D_En)
			D_out = D_in;
		else
			D_out = D_out;
	end
endmodule
