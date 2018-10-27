`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         March 7, 2016
// Module Name:  MIPS_32.v  
// Version:      1.01 
// Description:  This is an 32 bit MIPS module which performs var- 
//               ious arithmetic and logical operations. This mo-
//               dule takes two 32 bit inputs and dependent on the
//               input state of a function select chooses one of
//               various operations to perform obtaining a output
//               Y_lo and updates four flags, carry, overflow, neg-
//               ative, and zero.
//               
//////////////////////////////////////////////////////////////////////////////////
module MIPS_32(S, T, FS, Y_hi, Y_lo, C, V, N, Z);
   input      [31:0] S, T;
	input       [4:0] FS;
	output reg [31:0] Y_hi, Y_lo;
	output reg        C, V, N, Z;
	
	// integers to allow signed operations
	integer int_s, int_t, int_yl;
	
	always@(*) begin
	   int_s = S;
		int_t = T;
		Y_hi = 32'h0;
		
		// checks the input state of function select to determine
		// which of the following operations to perform
	   case(FS)
	      // Arithmetic Operations
	      5'h00  : {C,Y_lo} = {1'b0, int_s};                  // pass S
	      5'h01  : {C,Y_lo} = {1'b0, int_t};                  // pass T
	      5'h02  : {C,Y_lo} = int_s + int_t;                  // ADD
			5'h03  : {C,Y_lo} = S + T;                          // ADDU
			5'h04  : {C,Y_lo} = int_s - int_t;                  // SUB
			5'h05  : {C,Y_lo} = S - T;                          // SUBU
			5'h06  : {C,Y_lo} = (int_s < int_t) ? {1'b0, 1}: 0; // SLT
			5'h07  : {C,Y_lo} = (S < T) ? {1'b0, 1}: 0;         // SLTU
			
			// Logical Operations
			5'h08  : {C,Y_lo} = {1'b0, S & T};                  // AND
			5'h09  : {C,Y_lo} = {1'b0, S | T};                  // OR
			5'h0A  : {C,Y_lo} = {1'b0, S ^ T};                  // XOR
			5'h0B  : {C,Y_lo} = {1'b0, ~(S | T)};               // NOR
			5'h0C  : {C,Y_lo} = T << 1;                         // SLL
			5'h0D  : {C,Y_lo} = T >> 1;                         // SRL
			5'h0E  : {C,Y_lo} = int_t >>> 1;                    // SRA
			5'h16  : {C,Y_lo} = {1'b0, S & {16'h0, T[15:0]}};   // ANDI
			5'h17  : {C,Y_lo} = {1'b0, S | {16'h0, T[15:0]}};   // ORI
			5'h18  : {C,Y_lo} = {1'b0, S ^ {16'h0, T[15:0]}};   // XORI
			5'h19  : {C,Y_lo} = {1'b0, {T[15:0], 16'h0}};       // LUI
			
			// Other Operations
			5'h0F  : {C,Y_lo} = S + 1;                  // INC
			5'h10  : {C,Y_lo} = S - 1;                  // DEC
			5'h11  : {C,Y_lo} = S + 4;                  // INC4
			5'h12  : {C,Y_lo} = S - 4;                  // DEC4
			5'h13  : {C,Y_lo} = {1'b0, 32'h0};          // ZEROES
			5'h14  : {C,Y_lo} = {1'b0, 32'hFFFFFFFF};   // ONES
			5'h15  : {C,Y_lo} = {1'b0, 32'h3FC};        // SP_INT
			
			default: {C,Y_lo} = {1'b0,32'hF1F1F1F1};    // DEFAULT
		endcase
		
		// checks to see if an overflow has occur 
		// comparing the output to the inputs
		int_yl = Y_lo;
		if (((int_yl < 0 && int_s > 0 && int_t > 0)
		    || (int_yl > 0 && int_s < 0 && int_t < 0))
			 && (FS == 5'h02))
		   V = 1'b1;
		else if ((((int_yl < 0 && int_s > 0 && int_t < 0)
		    || (int_yl > 0 && int_s < 0 && int_t > 0))
			 && (FS == 5'h04)))
		   V = 1'b1;
		else if (C == 1'b1 && FS != 5'h02 && FS != 5'h04)
		   V = 1'b1;
		else
		   V = 1'b0;
		
			
		// negative flag checks the highest bit of Y_lo
		// to see if the number is negative, if so set
		// the negative flag high else set the flag low
		N = Y_lo[31];
		
		// check output the state of Y_lo to see if it is
		// zero then set the zero flag high else the flag
		// goes low
		if(Y_lo == 32'h0)
		   Z = 1'b1;
		else
		   Z = 1'b0;
	end
	
endmodule
