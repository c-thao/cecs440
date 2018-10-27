`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         April 17, 2016 
// Module Name:  MCU.v  
// Version:      1.01 
// Description:  This is a finite state machine which
//				 outputs various control words depend-
//				 end upon the current state it is cur-
//				 rently in.
//               
//////////////////////////////////////////////////////////////////////////////////
module MCU (sys_clk, sys_rst, intr, // system inputs
	c, n, z, v, ie, // ALU status inputs
	IR_out,         // Instruction Register input
	int_ack,        // output to I/O subsystem
	FS, T_addr, Y_sel,
	pc_sel, DA_sel,
	pc_ld, pc_inc, ir_ld, 
	im_cs, im_rd, 
	dm_cs, dm_rd, dm_wr, 
	io_cs, io_rd, io_wr,
	D_En, T_sel, HILO_ld,
	DY_sel, mem_out); // rest of control word fields
//*****************************************************************************
	input sys_clk, sys_rst;     // system clock, sys_rst, and interrupt request
	input c, n, z, v, intr;     // Integer ALU status inputs
	input [31:0] IR_out;        // Instruction Register input from IU
	output reg [4:0] FS, T_addr;
	output reg [2:0] Y_sel;
	output reg [1:0] pc_sel, DA_sel;
	output reg       int_ack, ie;          //interrupt acknowledge
	output reg       pc_ld, pc_inc, ir_ld, //to contain all of the bits
						  im_cs, im_rd,         // for all the control word fields
						  dm_cs, dm_rd, dm_wr,  // needed by the IU, DP and Data Memory
						  io_cs, io_rd, io_wr,
					  	  D_En, T_sel, HILO_ld,
					  	  DY_sel, mem_out;
	
	//****************************
	// internal data structures
	//****************************
	// state assignments
	parameter
	RESET = 00, FETCH = 01, DECODE = 02,
	ADD = 10, ADDU = 11, AND = 12, OR = 13,
	JR = 15, SUB = 16, SUBU = 17, J = 18, NOR = 04, 
	JAL = 19, BEQ = 24, BNE = 25, MUL = 26, 
	DIV = 27, SLT = 28, SLTU = 29, ORI = 20,
	LUI = 21, LW = 22, SW = 23, WB_alu = 30, 
	WB_imm = 31, WB_Din = 32, WB_hi = 33,
	WB_lo = 34, WB_mem = 35, XOR = 36, SLL = 37, 
	SRL = 38, SRA = 39, ANDI = 40, XORI = 41,
	BRE = 49, ADDI = 50, WB_PC = 51, SLTI = 52,
	MFLO = 53, MFHI = 54, BRNE = 55, WB_ld = 56,
	RD_mem = 57, WB_lk = 58, BLEZ = 59, BGTZ = 60,
	BRLEZ = 61, BRGTZ = 62, SLTIU = 63, SETIE = 64,
	INPUT = 65, OUTPUT = 66, RETI = 67, IO_WR = 68,
	IO_RD1 = 69, IO_RD2 = 70, INTR_1 = 501, 
	INTR_2 = 502, INTR_3 = 503,
	BREAK = 510, SW_2 = 511,
	ILLEGAL_OP= 511;
	
	//state register (up to 512 states)
	reg [8:0] state;
	reg       ps_c,ps_v,ps_n,ps_z,ps_ie;
	
	/************************************************
	* 440 MIPS CONTROL UNIT (Finite State Machine) *
	************************************************/
	always @(posedge sys_clk or posedge sys_rst)
		if (sys_rst) begin
			//*** control word assignments for the sys_rst condition should be here ***
			{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
			{im_cs, im_rd} = 2'b0_0;
			DY_sel = 1'b0;
			T_addr = IR_out[20:16];
			{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
			{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack = 1'b0;
			state = RESET;
		end
		else
			case (state)
			// fetches an instruction
			FETCH:
			if (int_ack==0 & intr==1) begin
				$display("\nDETECTED INTR");
				@(negedge sys_clk)
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				state = INTR_1;
			end
			else begin
				@(negedge sys_clk)
				$display("\nFETCH");
				if (int_ack==1 & intr==0) int_ack=1'b0;
				// control word assignments for IR ? iM[PC]; PC ? PC+4
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_1_1;
				{im_cs, im_rd} = 2'b1_1;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				state = DECODE;
			end
			
			// set every control word into their reset state
			RESET: begin
				@(negedge sys_clk)
				$display("RESET");
				// control word assignments for $sp <-- ALU_Out(32'h3FC)
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0; ie=0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  5'h0;
				state = FETCH;
			end
			
			// decodes the instruction
			DECODE: begin
				@(negedge sys_clk)
				$display("DECODING");
				if (IR_out[31:26] == 6'h0) // check for MIPS format
				begin // it is an R-type format
					// control word assignments: RS <-- $rs RT <-- $rt (default)
					{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
					{im_cs, im_rd} = 2'b0_0;
					DY_sel = 1'b0;
					T_addr = IR_out[20:16];
					{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
					{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack = 1'b0;
					case (IR_out[5:0])
					6'h00  : state = SLL;
					6'h02  : state = SRL;
					6'h03  : state = SRA;
					6'h08  : state = JR;
					6'h0D  : state = BREAK;
					6'h10  : state = MFHI;
					6'h12  : state = MFLO;
					6'h18  : state = MUL;
					6'h1a  : state = DIV;
					6'h1f  : state = SETIE;
					6'h20  : state = ADD;
					6'h21  : state = ADDU;
					6'h22  : state = SUB;
					6'h23  : state = SUBU;
					6'h24  : state = AND;
					6'h25  : state = OR;
					6'h26  : state = XOR;
					6'h27  : state = NOR;
					6'h2a  : state = SLT;
					6'h2b  : state = SLTU;
					default: state = ILLEGAL_OP;
					endcase
 				end // end of if for R-type Format
				else
				begin // it is an I-type or J-type format or E-type
					// control word assignments: RS <-- $rs RT <-- DT(se_16)
					{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
					{im_cs, im_rd} = 2'b0_0;
					DY_sel = 1'b0;
					T_addr = IR_out[20:16];
					{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_000; FS = 5'h0;
					{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack = 1'b0;
					case (IR_out[31:26])
					6'h02  : state = J;
					6'h03  : state = JAL;
					6'h04  : state = BEQ;
					6'h05  : state = BNE;
					6'h06  : state = BLEZ;
					6'h07  : state = BGTZ;
					6'h08  : state = ADDI;
					6'h0a  : state = SLTI;
					6'h0b  : state = SLTIU;
					6'h0c  : state = ANDI;
					6'h0d  : state = ORI;
					6'h0e  : state = XORI;
					6'h0f  : state = LUI;
					6'h1c  : state = INPUT;
					6'h1d  : state = OUTPUT;
					6'h1e  : state = RETI;
					6'h23  : state = LW;
					6'h2b  : state = SW;
					default: state = ILLEGAL_OP;
 					endcase
 				end // end of else for I-type or J-type formats
 			end // end of DECODE
			
			INPUT: begin
				@(negedge sys_clk)
				$display("INPUT INSTR");
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_010; FS=5'h02;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = IO_RD1;
 			end
			
			OUTPUT: begin
				@(negedge sys_clk)
				$display("OUTPUT INSTR");
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_010; FS=5'h02;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = IO_WR;
 			end
			
			IO_RD1: begin
				@(negedge sys_clk)
				$display("IO RD1");
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b1;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_011; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b1_1_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = IO_RD2;
 			end
			
			IO_RD2: begin
				@(negedge sys_clk)
				$display("IO RD2");
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_0_0_010; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
			IO_WR: begin
				@(negedge sys_clk)
				$display("IO WR");
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b1_0_1;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
			BEQ: begin
				// control word assignments: (ps_z) = $rs - $rt
				@(negedge sys_clk)
				$display("BEQ");
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h05;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = BRE;
 			end
			
			BNE: begin
				@(negedge sys_clk)
				$display("BNE");
				// control word assignments: (ps_z) = $rs - $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h05;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = BRNE;
 			end
			
			BLEZ: begin
				@(negedge sys_clk)
				$display("BLEZ");
				// control word assignments: (ps_z, ps_n) = $rs - $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h04;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = BRLEZ;
 			end
			
			BGTZ: begin
				@(negedge sys_clk)
				$display("BGTZ");
				// control word assignments: (ps_z, ps_n) = $rs - $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h04;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = BRGTZ;
 			end
			
			J: begin
				@(negedge sys_clk)
				$display("JUMP");
				// control word assignments: PC <-- {PC[31:28],PC[25:0],2'b0}
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b01_1_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
			JAL: begin
				@(negedge sys_clk)
				$display("JUMP AND LINK");
				// control word assignments:  $ra <-- PC,
				// PC <-- {PC[31:28],PC[25:0],2'b0} 
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_10_0_0_100; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_lk;
 			end
			
			JR: begin
				@(negedge sys_clk)
				$display("JUMP REGISTER");
				// control word assignments: PC <-- $rs
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_PC;
 			end
			
			RETI: begin
				@(negedge sys_clk)
				$display("RETI");
				// control word assignments: PC <-- $29(SP)
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0; ie = 1'b0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_PC;
 			end
			
			// arithmetic
			ADD: begin
				@(negedge sys_clk)
				$display("ADD");
				// control word assignments: ALU_Out <-- $rs + $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h02;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			ADDI: begin
				@(negedge sys_clk)
				$display("ADDI");
				// control word assignments: ALU_Out <-- $rs + SE_16
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_1_010; FS=5'h02;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_imm;
 			end
			
			ADDU: begin
				@(negedge sys_clk)
				$display("ADDU");
				// control word assignments: ALU_Out <-- $rs + $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h03;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			SUB: begin
				@(negedge sys_clk)
				$display("SUB");
				// control word assignments: ALU_Out <-- $rs + $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h04;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			SUBU: begin
				@(negedge sys_clk)
				$display("SUBU");
				// control word assignments: ALU_Out <-- $rs + $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h05;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			MUL: begin
				@(negedge sys_clk)
				$display("MUL");
				// control word assignments: ALU_Out <-- $rs * $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_1_010; FS=5'h1E;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
			DIV: begin
				@(negedge sys_clk)
				$display("DIV");
				// control word assignments: ALU_Out <-- $rs/$rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_1_010; FS=5'h1F;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
			SLT: begin
				@(negedge sys_clk)
				$display("SHIFT LESS THAN");
				// control word assignments: $rd <-- $rs < $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h06;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			SLTI: begin
				@(negedge sys_clk)
				$display("SHIFT LESS THAN IMMEDIATE");
				// control word assignments: $rd <-- $rs < SE_16
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_010; FS=5'h06;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_imm;
 			end
			
			SLTU: begin
				@(negedge sys_clk)
				$display("SHIFT LESS THAN UNSIGNED");
				// control word assignments: $rd <-- $rs < $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h07;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			SLTIU: begin
				@(negedge sys_clk)
				$display("SHIFT LESS THAN IMMEDIATE UNSIGNED");
				// control word assignments: $rd <-- $rs < SE_16
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_010; FS=5'h07;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_imm;
 			end
			
			AND: begin
				@(negedge sys_clk)
				$display("AND");
				// control word assignments: ALU_Out <-- $rs & $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h08;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			OR: begin
				@(negedge sys_clk)
				$display("OR");
				// control word assignments: ALU_Out <-- $rs | $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h09;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			NOR: begin
				@(negedge sys_clk)
				$display("NOR");
				// control word assignments: ALU_Out <-- $rs + $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h0B;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			XOR: begin
				@(negedge sys_clk)
				$display("XOR");
				// control word assignments: ALU_Out <-- $rs ^ $rt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h0A;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			SLL: begin
				@(negedge sys_clk)
				$display("SLL");
				// control word assignments: ALU_Out <-- $rt << shftamnt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h0C;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			SRL: begin
				@(negedge sys_clk)
				$display("SRL");
				// control word assignments: ALU_Out <-- $rs >> shftamnt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h0D;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			SRA: begin
				@(negedge sys_clk)
				$display("SRA");
				// control word assignments: ALU_Out <-- $rs >> shftamnt
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h0E;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_alu;
 			end
			
			ANDI: begin
				@(negedge sys_clk)
				$display("ANDI");
				// control word assignments: ALU_Out <-- $rs & SE_16
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_010; FS=5'h16;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_imm;
 			end
			
 			ORI: begin
				@(negedge sys_clk)
				$display("ORI");
				// ctrl word assignments for ALU_Out <-- $rs | {16'h0, RT[15:0]}
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_010; FS=5'h17;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_imm;
 			end
			
			XORI: begin
				@(negedge sys_clk)
				$display("XORI");
				// control word assignments: ALU_Out <-- $rs ^ {16'h0, RT[15:0]}
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_010; FS=5'h18;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_imm;
 			end
			
 			LUI: begin
				@(negedge sys_clk)
				$display("LUI");
				// control word assignments for ALU_Out <-- { RT[15:0], 16'h0}
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_010; FS=5'h19;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_imm;
 			end
			
 			SW: begin
				@(negedge sys_clk)
				$display("SW");
				// control word assignments for ALU_Out <-- $rs + $rt(se_16) "EA calc"
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h02;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_mem;
 			end
			
			LW: begin
				@(negedge sys_clk)
				$display("LW");
				// control word assignments for ALU_Out <-- $rs + $rt(se_16) "EA calc"
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_010; FS=5'h02;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = RD_mem;
 			end
			
			RD_mem: begin
				@(negedge sys_clk)
				$display("RD_mem");
				// control word assignments for RT(rt) <-- M[ ALU_Out(rs+se_16)]
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_010; FS=5'h01;
				{dm_cs, dm_rd, dm_wr} = 3'b1_1_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = WB_ld;
 			end
			
 			WB_alu: begin
				@(negedge sys_clk)
				$display("WB_alu");
				// control word assignments for R[rd] <-- ALU_Out
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_010; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
 			WB_imm: begin
				@(negedge sys_clk)
				$display("WB_imm");
				// control word assignments for R[rt] <-- ALU_Out
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_1_0_010; FS=5'h17;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
 			WB_mem: begin
				@(negedge sys_clk)
				$display("WB_mem");
				// control word assignments for M[ ALU_Out(rs+se_16)] <-- RT(rt)
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h01;
				{dm_cs, dm_rd, dm_wr} = 3'b1_0_1; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
			WB_ld: begin
				@(negedge sys_clk)
				$display("WB_ld");
				// control word assignments for R[rt] <-- ALU_Out
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_0_0_011; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
			WB_lk: begin
				@(negedge sys_clk)
				$display("WB_lk");
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b01_1_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_10_0_0_100; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
			MFLO: begin
				@(negedge sys_clk)
				$display("MFLO");
				// control word assignments for R[rd] <-- LO
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_001; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
			MFHI: begin
				@(negedge sys_clk)
				$display("MFHI");
				// control word assignments for R[rd] <-- HI
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_000; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
			WB_PC: begin
				@(negedge sys_clk)
				$display("WB_PC");
				// control work assignment for PC = JMPADDR
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_1_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
			end
			
			BRE: begin
				@(negedge sys_clk)
				$display("BRE");
				// control work assignment for PC = BRNHADDR
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b1_0_1; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				if (ps_z) begin	
					{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b10_1_0_0;
				end
				else begin
					{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				end
				state = FETCH;
			end
			
			BRNE: begin
				@(negedge sys_clk)
				$display("BRNE");
				// control work assignment for BRNHADDR
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b1_0_1; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				if (!ps_z) begin	
					{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b10_1_0_0;
				end
				else begin
					{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				end
				state = FETCH;
			end
			
			BRLEZ: begin
				@(negedge sys_clk)
				$display("BRLEZ");
				// control work assignment for BRNHADDR
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b1_0_1; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				if (ps_n || ps_z) begin	
					{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b10_1_0_0;
				end
				else begin
					{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				end
				state = FETCH;
			end
			
			BRGTZ: begin
				@(negedge sys_clk)
				$display("BRGTZ");
				// control work assignment for BRNHADDR
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b1_0_1; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				if (!ps_n) begin	
					{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b10_1_0_0;
				end
				else begin
					{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				end
				state = FETCH;
			end
			
			// FINAL DESTINATION
 			BREAK: begin
				@(negedge sys_clk)
				$display("BREAK INSTRUCTION FETCHED %t",$time);
				//$stop;
				// control word assignments for "deasserting" everything
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
 			end
			
 			ILLEGAL_OP: begin
				@(negedge sys_clk)
				$display("ILLEGAL OPCODE FETCHED %t",$time);
				//$stop;
				// control word assignments for "deasserting" everything
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
			end
			
 			SETIE: begin
				@(negedge sys_clk)
				$display("SETIE");
				// control word assignments for ie
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_000; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0; ie = 1'b1;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end
			
 			INTR_1: begin
				@(negedge sys_clk)
				$display("INTR1");
				// PC gets address of interrupt vector; Save PC in $ra
				// control word assignments for ALU_Out ? 0x3FC, R[$ra] ? PC
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_11_0_0_100; FS=5'h15;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=0; ie = 1'b1;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = INTR_2;
 			end
			
 			INTR_2: begin
				@(negedge sys_clk)
				$display("INTR2");
				// Read address of ISR into D_in;
				// control word assignments for D_in ? dM[ALU_Out(0x3FC]
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS=5'h00;
				{dm_cs, dm_rd, dm_wr} = 3'b1_1_0; int_ack=0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = INTR_3;
 			end
			
 			INTR_3: begin
				@(negedge sys_clk)
				$display("INTR3");
				// Reload PC with address of ISR; ack the intr; goto FETCH
				// control word assignments for PC ? D_in( dM[0x3FC] ), int_ack ? 1
				{pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_1_0_0;
				{im_cs, im_rd} = 2'b0_0;
				DY_sel = 1'b0;
				{D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_011; FS=5'h0;
				{dm_cs, dm_rd, dm_wr} = 3'b0_0_0; int_ack=1; ie = 0;
				{io_cs, io_rd, io_wr} = 3'b0_0_0;
				{ps_c,ps_v,ps_n,ps_z,ps_ie} =  {c,v,n,z,ie};
				state = FETCH;
 			end	
 		endcase // end of FSM logic
		
endmodule