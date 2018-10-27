`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         March 7, 2016
// Module Name:  Instruction_Unit.v  
// Version:      1.01 
// Description:  This is an Instruction_Unit which contains
//				 a 32 bit program counter register to keep
//				 track of the next instruction's memory lo-
//				 cation. An instruction register which con-
//				 tains the 32 bit instruction word along with
//				 an Instruction Memory where each individual
//				 32 bit instruction word are stored. 
//					  				             
//////////////////////////////////////////////////////////////////////////////////
module Instruction_Unit(clk, reset, pc_ld, pc_inc, im_cs, im_rd,
							   ir_ld, PC_in, PC_out, IR_out, SE_16, pc_sel);
	input         clk, reset, pc_ld, pc_inc,
					  im_cs, im_rd, ir_ld;
	input   [1:0] pc_sel;
	input  [31:0] PC_in;
	output [31:0] PC_out, IR_out, SE_16;
	
	// PC register and D_Out wire
	reg    [31:0] PC;
	wire   [31:0] D_Out;
	
	// 32 bit PC register if reset is
	// active high goes to zero, else
	// if pc_inc is high and pc_ld is
	// low then it increments by 4, if
	// pc_inc is low and pc_ld is high 
	// then PC looks at the two bit bi-
	// nary state of pc_sel to determine
	// the next value of PC else PC is
	// set to PC
	always@(posedge clk)begin
		if (reset)
			PC = 32'h0;
		else if ({pc_ld, pc_inc} == 2'b01)
			PC = PC + 4;
		else if ({pc_ld, pc_inc} == 2'b10)
			case(pc_sel)
				2'b00  : PC = PC_in;
				2'b01  : PC = {PC[31:28], IR_out[25:0],2'b00};
				2'b10  : PC = PC + {SE_16[29:0],2'b00};
				default: PC = PC;
			endcase
		else
			PC = PC;
	end
	
	// PC_out gets PC
	assign PC_out = PC;
	
	// Instruction Memory where instruction words are 
	// stored                                    
	ReadOnlyMemory   Instr_Mem(clk, im_cs, im_rd, {20'h0, PC_out[11:0]}, D_Out);
	
	// IR register which holds instruction words
	regfile  		  IR(clk, reset, ir_ld, D_Out, IR_out);
	
	// sign extend IR_out[15:0]
	assign SE_16 = {{16{IR_out[15]}},IR_out[15:0]};
	
endmodule
