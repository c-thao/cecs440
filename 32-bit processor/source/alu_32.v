`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         March 7, 2016
// Module Name:  alu_32.v  
// Version:      1.01 
// Description:  This is an 32 bit alu module which instantiates
//               three 32 bit modules, a multiplication, a divi-
//               sion, and a MIPS. These various modules are given
//               two 32 bit inputs and their resultants are taken
//               depending on the input state of a function select.
//               The function select also determines which of the 
//               status flags, carry, overflow, negative, or zero 
//               to be updated depending on the operation performed.
//                              
//////////////////////////////////////////////////////////////////////////////////
module alu_32(S, T, FS, shft_amnt, Y_hi, Y_lo, C, V, N, Z);
   input      [31:0] S, T;
	input       [4:0] FS, shft_amnt;
	output reg        C, V, N, Z;
	output reg [31:0] Y_hi, Y_lo;
	
	// variables to hold outputs of four various
	// modules for different operations
	wire [31:0] a_hi, a_lo, c_hi, c_lo, e_hi, e_lo, b_lo;
   wire  [3:0]	a, s;
	wire  [1:0] b, c;
	
   //	32 bit operations which takes two 32 bit inputs
	// and returns an resulting output as well as an 
	// update to a carry and overflow flag
	MIPS_32  mips (S,T,FS,a_hi,a_lo,a[3],a[2],a[1],a[0]);
	
   // 32 bit multiplication  module which takes two 32 bit
   // inputs and returns a 64 bit product	
	MPY_32   mul  (S,T,{c_hi,c_lo},b[1],b[0]);

   //	32 bit division module which takes two 32 bit inputs
   // and returns a 32 bit quotient and 32 bit remainder	
	DIV_32   div  (S,T,e_lo,e_hi,c[1],c[0]);
	
	// 32 bit barrel shifter
	Bar_Shft bshft (T, b_lo, FS, shft_amnt, s[3], s[2], s[1], s[0]);
	
	// checks the input state of function select to determine
	// which outputs from the three modules above to set as
	// the desired output as well as update the carry, over-
	// flow, negative and zero flags accordingly
	always@(*) begin
	   case(FS)
			// Arithmetic Operations
	      5'h00  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // pass S
			5'h01  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // pass T
			5'h02  : {{C,V,N,Z},Y_hi,Y_lo} = {{a[3:0]},a_hi,a_lo};           // ADD
			5'h03  : {{C,V,N,Z},Y_hi,Y_lo} = {{a[3:0]},a_hi,a_lo};           // ADDU
			5'h04  : {{C,V,N,Z},Y_hi,Y_lo} = {{a[3:0]},a_hi,a_lo};           // SUB
			5'h05  : {{C,V,N,Z},Y_hi,Y_lo} = {{a[3:0]},a_hi,a_lo};           // SUBU
			5'h06  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // SLT
			5'h07  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // SLTU
			5'h1E  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,b[1:0]},c_hi,c_lo};      // MUL
			5'h1F  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,c[1:0]},e_hi,e_lo};      // DIV
			
			// Logical Operations
			5'h08  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // AND
			5'h09  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // OR
			5'h0A  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // XOR
			5'h0B  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // NOR
			5'h0C  : {{C,V,N,Z},Y_hi,Y_lo} = {{s[3],1'hx,s[1:0]},a_hi,b_lo}; // SLL
			5'h0D  : {{C,V,N,Z},Y_hi,Y_lo} = {{s[3],1'hx,s[1:0]},a_hi,b_lo}; // SRL
			5'h0E  : {{C,V,N,Z},Y_hi,Y_lo} = {{s[3:0]},a_hi,b_lo};           // SRA
			5'h16  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // ANDI
			5'h17  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // ORI
			5'h18  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // XORI
			5'h19  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // LUI
			
			// Other Operations
			5'h0F  : {{C,V,N,Z},Y_hi,Y_lo} = {{a[3:0]},a_hi,a_lo};           // INC
			5'h10  : {{C,V,N,Z},Y_hi,Y_lo} = {{a[3:0]},a_hi,a_lo};           // DEC
			5'h11  : {{C,V,N,Z},Y_hi,Y_lo} = {{a[3:0]},a_hi,a_lo};           // INC4
			5'h12  : {{C,V,N,Z},Y_hi,Y_lo} = {{a[3:0]},a_hi,a_lo};           // DEC4
			5'h13  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // ZEROES
			5'h14  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // ONES
			5'h15  : {{C,V,N,Z},Y_hi,Y_lo} = {{2'hx,a[1:0]},a_hi,a_lo};      // SP_INT
			
			default: {{C,V,N,Z},Y_hi,Y_lo} = {4'hx,64'hF1F1F1F1F1F1F1F1};    // DEFAULT
		endcase
	end
		
endmodule
