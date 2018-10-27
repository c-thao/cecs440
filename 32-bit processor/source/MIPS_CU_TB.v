`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      CSULB Student
// Engineer:     Chou Thao
// Date:         April 17, 2016 
// Module Name:  MIPS_CU_TB.v  
// Version:      1.01 
// Description:  This is a testbench which
//				 contains 13 various test
//				 initilization files to ri-
//				 gourously test the various
//				 instructions of a MIPS ISA
//				 implementation.
//    
//////////////////////////////////////////////////////////////////////////////////
module MIPS_CU_TB;

	// Inputs
	reg sys_clk, sys_rst;
	reg print;
	integer dump_when;
	integer i;
	
	Top_Level uut(
		.sys_clk(sys_clk), .sys_rst(sys_rst)
	);
	
	always
		#5 sys_clk = ~sys_clk;
		
	// displays the register contents
	// if print is high
	always @(negedge sys_clk) begin
		if (print == 1'b1) begin
			$display("Data=%h",uut.Main.EU.IDP.registers.T);
		end
	end
	
	
	
	initial begin
		// Initialize Inputs
		sys_clk = 1'b0; sys_rst = 1'b0;
		i = 0; print = 1'b0; dump_when=0;
		
		// Wait 100 ns for global reset to finish
		#10;
		sys_rst = 1'b1;
		#10;
		sys_rst = 1'b0;
      
		i = 14;
		dump_when = 5000;
		//$display("Memory  Module  1");
		//$readmemh("dMem01_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem01_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		//$display("Memory  Module  2");
		//$readmemh("dMem02_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem02_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		//$display("Memory  Module  3");
		//$readmemh("dMem03_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem03_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		//$display("Memory  Module  4");
		//$readmemh("dMem04_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem04_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		//$display("Memory  Module  5");
		//$readmemh("dMem05_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem05_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		//$display("Memory  Module  6");
		//$readmemh("dMem06_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem06_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		//$display("Memory  Module  7");
		//$readmemh("dMem07_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem07_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		//$display("Memory  Module  8");
		//$readmemh("dMem08_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem08_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		//$display("Memory  Module  9");
		//$readmemh("dMem09_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem09_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		//$display("Memory  Module  10");
		//$readmemh("dMem10_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem10_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		//$display("Memory  Module  11");
		//$readmemh("dMem11_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem11_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		//$display("Memory  Module  12");
		//$readmemh("dMem12_Sp16.dat",uut.Data_Mem.mem);
		//$readmemh("iMem12_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		$display("Memory  Module  14");
		$readmemh("dMem14_Sp16.dat",uut.Data_Mem.mem);
		$readmemh("iMem14_Sp16.dat",uut.Main.EU.IU.Instr_Mem.mem);
		#dump_when;
		Reg_Dump;
		$finish;
	end
      
	// task to set all the control words to
	// access the registers and set print to
	// 1'b1 to display the contents of the 
	// registers
	task Reg_Dump;
		integer i;
		begin
			$display("\nR e a d i n g  R e g i s t e r s\n");
			for (i=0; i<16; i=i+1) begin
			@(negedge sys_clk)
			   uut.Main.CU.D_En = 1'b0;
				uut.Main.CU.T_addr = i;
				uut.Main.CU.T_sel = 1'b1;
				uut.Main.CU.FS = 5'h01;
				uut.Main.CU.Y_sel = 3'b010;
				uut.Main.CU.HILO_ld = 1'b0;
				print = 1'b1;
				$display("t=%t  i=%h  T_Addr=%h",
							$time, i, uut.Main.CU.T_addr);
			end
			@(negedge sys_clk)
				print = 1'b0;
				uut.Main.CU.mem_out = 1'b1;
		end
	endtask
	
endmodule

