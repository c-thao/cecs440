`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         March 7, 2016 
// Module Name:  MPY_32.v  
// Version:      1.00 
// Description:  This is an 32 bit multiplication module which
//               takes two 32 bit inputs and obtains a 64 bit
//               product resultant.
//               
//////////////////////////////////////////////////////////////////////////////////
module MPY_32(a, b, p, N, Z);
   input      [31:0] a, b;
	output reg        N, Z;
	output reg [63:0] p;
	
	// integer inputs for signed multiplication
	integer int_a, int_b;
	
	// performs multiplication and updates
	// both the negative and zero flag
	always@ (*) begin
	   int_a = a;
		int_b = b;
		p = int_a * int_b; // product
		
		// negative flag checks the highest bit of the
		// product to see if the number is negative, if
		// so set the negative flag high else set the 
		// flag low
		N = p[63];
		
		// check output the state of the product to see
		// if it is zero then set the zero flag high else
		// the flag goes low
		if(p == 64'h0)
		   Z = 1'b1;
		else
		   Z = 1'b0;
   end
	
endmodule
