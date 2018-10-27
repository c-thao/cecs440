`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         March 7, 2016
// Module Name:  Bar_Shft.v  
// Version:      1.01 
// Description:  This is an 32 bit barrel shifter module which performs
//					  one of three shifts, shift left logical, shift right
//					  logical, and shift right logical by an amount base on
//					  an 5 bit input func. Each shift shifts an 32 bit input
//					  a number of times defined by the input shft_amnt and
//					  outputs it to a register dout.
//                              
//////////////////////////////////////////////////////////////////////////////////
module Bar_Shft(din, dout, func, shft_amnt, c, v, n, z);
	input       [4:0] func, shft_amnt;
	input      [31:0] din;
	output reg [31:0] dout;
	output reg 		   c, v, n, z;
	
	// performs one of three shifts
	// dependent on the 5 bit bin-
	// ary value of func and the
	// number of shifts is reliant
	// upon the 5 bit value of an
	// input shft_amnt
	always @(*) begin
		case (func)
			5'h0c   : dout <= din << shft_amnt; // SLL
			5'h0d   : dout <= din >> shft_amnt; // SLR
			5'h0e   : begin
							case(shft_amnt) // SRA every msb is filled with original
								5'h01   : dout <= {din[31],din[31:1]}; 
								5'h02   : dout <= {din[31], {1{din[31]}}, din[31:2]};
								5'h03   : dout <= {din[31], {2{din[31]}}, din[31:3]};
								5'h04   : dout <= {din[31], {3{din[31]}}, din[31:4]};
								5'h05   : dout <= {din[31], {4{din[31]}}, din[31:5]};
								5'h06   : dout <= {din[31], {5{din[31]}}, din[31:6]};
								5'h07   : dout <= {din[31], {6{din[31]}}, din[31:7]};
								5'h08   : dout <= {din[31], {7{din[31]}}, din[31:8]};
								5'h09   : dout <= {din[31], {8{din[31]}}, din[31:9]};
								5'h0a   : dout <= {din[31], {9{din[31]}}, din[31:10]};
								5'h0b   : dout <= {din[31], {10{din[31]}}, din[31:11]};
								5'h0c   : dout <= {din[31], {11{din[31]}}, din[31:12]};
								5'h0d   : dout <= {din[31], {12{din[31]}}, din[31:13]};
								5'h0e   : dout <= {din[31], {13{din[31]}}, din[31:14]};
								5'h0f   : dout <= {din[31], {14{din[31]}}, din[31:15]};
								5'h10   : dout <= {din[31], {15{din[31]}}, din[31:16]};
								5'h11   : dout <= {din[31], {16{din[31]}}, din[31:17]};
								5'h12   : dout <= {din[31], {17{din[31]}}, din[31:18]};
								5'h13   : dout <= {din[31], {18{din[31]}}, din[31:19]};
								5'h14   : dout <= {din[31], {19{din[31]}}, din[31:20]};
								5'h15   : dout <= {din[31], {20{din[31]}}, din[31:21]};
								5'h16   : dout <= {din[31], {21{din[31]}}, din[31:22]};
								5'h17   : dout <= {din[31], {22{din[31]}}, din[31:23]};
								5'h18   : dout <= {din[31], {23{din[31]}}, din[31:24]};
								5'h19   : dout <= {din[31], {24{din[31]}}, din[31:25]};
								5'h1a   : dout <= {din[31], {25{din[31]}}, din[31:26]};
								5'h1b   : dout <= {din[31], {26{din[31]}}, din[31:27]};
								5'h1c   : dout <= {din[31], {27{din[31]}}, din[31:28]};
								5'h1d   : dout <= {din[31], {28{din[31]}}, din[31:29]};
								5'h1e   : dout <= {din[31], {29{din[31]}}, din[31:30]};
								5'h1f   : dout <= {din[31], {30{din[31]}}, din[31]};
								default : dout <= din;
							endcase
						end
			default : dout <= din;
		endcase
		
		// determines if output is 
		// all zeroes if so set z
		// flag high
		if (dout == 32'b0)
			z = 1'b1;
		else
			z = 1'b0;
			
		// determines if output is
		// negative if so set n flag
		// high
		if (dout[31] == 1'b1)
			n = 1'b1;
		else
			n = 1'b0;
		
		// determines if carry flag
		// is set if and only if func
		// was 2'b02
		if (func == 5'h0e)
			{c,v} = {2{dout[31],1'bx}};
		else
			{c,v}= 2'b0x;
	end
	
endmodule
