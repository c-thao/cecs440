`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         March 7, 2016
// Module Name:  DIV_32.v  
// Version:      1.00 
// Description:  This is an 32 bit division module which takes two
//               32 bit inputs and obtains the quotient and re-
//               mainder of their division.
//
//////////////////////////////////////////////////////////////////////////////////
module DIV_32(a, b, quot, rem, N, Z);
   input      [31:0] a, b;
	output reg        N, Z;
	output reg [31:0] quot;
	output reg [31:0] rem;
	
	// integers inputs for the signed division
	integer int_a, int_b;
	
	// performs division and updates
	// both the negative and zero flag
	always@ (*) begin
	   int_a = a;
		int_b = b;
		quot  = int_a / int_b; // quotient
		rem   = int_a % int_b; // remainder
		
	   // negative flag checks the highest bit of the 
      // quotient to see if the number is negative, if
	   // so set the negative flag high else set the flag
		// low
	   N = quot[31];
		
		// check output the state of quotient to see if it
		// is zero then set the zero flag high else the flag
		// goes low
		if(quot == 32'h0)
		   Z = 1'b1;
		else
		   Z = 1'b0;
   end
	
endmodule
