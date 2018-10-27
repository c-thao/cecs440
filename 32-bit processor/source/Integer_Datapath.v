`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         March 7, 2016
// Module Name:  Integer_Datapath.v  
// Version:      1.02 
// Description:  This is an Integer Datapath which interconnects
//				 an ALU to an array of registers. The interlinking
//				 of these allows the ALU to perform 32 bit operat-
//				 ions on 32 bit inputs obtain from the register
//				 array as well as write the resultant back into
//				 the array.
//					  
//					             
//////////////////////////////////////////////////////////////////////////////////
module Integer_Datapath(clk, reset, D_En, D_Addr, S_Addr,
	T_Addr, DT, T_Sel, FS, shft_amnt, C, V, N, Z, DY_d,
	DY_i, DY_sel, PC_in, Y_Sel, HILO_ld, ALU_OUT, D_OUT,
	D_Sel);
	
	input [31:0] DT, DY_d, DY_i, PC_in;
	input  [4:0] FS, shft_amnt, D_Addr, S_Addr, T_Addr;
	input  [2:0] Y_Sel;
	input  [1:0] D_Sel;
	input        clk, reset, D_En, T_Sel, HILO_ld, DY_sel;
	
	output reg [31:0] ALU_OUT, D_OUT;
	output reg        C, V, N, Z;
	
	wire [31:0] T_MUX, D, S, T, Y_hi, Y_lo, Y_hout, Y_lout,
					D_in, ALU_out, S_out, T_out, D_MUX, DY_MUX;
	wire        c, v, n, z;
	
	// a 32 bit input into an array of
	// registers is always the output
	// ALU_OUT
	assign D = ALU_OUT;
	
	// a two bit binary input D_Sel
	// determines which of four five
	//	bit binary inputs to determine
	// an address of a register to write
	assign D_MUX = (D_Sel==2'b00) ? D_Addr:
						(D_Sel==2'b01) ? T_Addr:
						(D_Sel==2'b10) ? 5'b11111:
						                 5'b11101;
	
	// an array of registers which reads
	// and write if clk is high
	regfile32 registers (clk, reset, D_En, D_MUX[4:0], S_Addr,
							   T_Addr, ALU_OUT, S, T);
								
	// a 2 to 1 mux which selects a 32
	// bit value dependent on the binary
	// value of T_Sel
	assign  T_MUX =   (T_Sel) ? DT: T;
	
	// a 2 to 1 mux which selects a 32
	// bit value dependent on the binary
	// value of DY_sel
	assign  DY_MUX =  (DY_sel) ? DY_i: DY_d;
	
	// a register to hold the value of S
	// if an input clk is asserted
	regfile  RS       (clk, reset, 1'b1, S, S_out);
	
	// a register to hold the value of T
	// if an input clk is asserted
	regfile  RT       (clk, reset, 1'b1, T_MUX, T_out);
	
	// this is an ALU which performs 32 bit
	// arithmetic and logical operations with
	// two 32 bit inputs depending on a 5 bit
	// value of input FS outputting the result-
	// ants to 2 32 bit outputs Y_hi and Y_lo
	// along with four binary flags c, v, n, z
	alu_32   ALU      (S_out, T_out, FS, shft_amnt, Y_hi, Y_lo, c, v, n, z);
	
	// a register to hold the value of Y_hi
	// if an input clk is asserted
	regfile  HI       (clk, reset, HILO_ld, Y_hi, Y_hout);
	
	// a register to hold the value of Y_lo
	// if an input clk is asserted
	regfile  LO       (clk, reset, HILO_ld, Y_lo, Y_lout);
	
	// a register to hold the value of ALU_out
	// if an input clk is asserted
	regfile  ALU_Out  (clk, reset, 1'b1, Y_lo, ALU_out);
	
	// a register to hold the value of D_In
	// if an input clk is asserted
	regfile  D_In     (clk, reset, 1'b1, DY_MUX, D_in);
	
	// a 32 bit output ALU_OUT's value
	// is sensitive to the binary state
	// of Y_Sel which determines which
	// of 6 32 bit values ALU_OUT will
	// take as well as obtaining the
	// outputs of four binary flags
	// C, V, N, Z, and a 32 bit output
	// D_OUT
	always@(posedge clk) begin
		case(Y_Sel)
			3'b000:  ALU_OUT = Y_hout;
			3'b001:  ALU_OUT = Y_lout;
			3'b010:  ALU_OUT = ALU_out;
			3'b011:  ALU_OUT = D_in;
			3'b100:  ALU_OUT = PC_in;
			default: ALU_OUT = 32'hzzzzzzzz;
		endcase
		
		D_OUT = T_out;
		{C,V,N,Z} = {c,v,n,z}; // needs to fix to implement flags register correctly
	end
	
endmodule
