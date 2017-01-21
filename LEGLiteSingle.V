// EE 361
// LEGLite Single Cycle
// Author: Dylan Nakahodo
// Date: 11/26/2016
//

module LEGLiteSingle(
	iaddr,		// Program memory address.  This is the program counter
	daddr,		// Data memory address
	dwrite,		// Data memory write enable
	dread,		// Data memory read enable
	dwdata,		// Data memory write output
	alu_out,	// Output of alu for debugging purposes
	clock,
	idata,		// Program memory output, which is the current instruction
	ddata,		// Data memory output
	reset
	);

output [15:0] iaddr;
output [15:0] daddr;	
output dwrite;
output dread;
output [15:0] dwdata;
output [15:0] alu_out;
input clock;
input [15:0] idata; // Instructions 
input [15:0] ddata;	
input reset;

//Begin Instantiations

//RegMux Wires
wire [2:0] regmux_result;
//PC Wires
wire [15:0] signext;
wire reset;
//Register Wires
wire [15:0] rdata1, rdata2;
//ALU Wires 
wire [15:0] ALU_result;
wire zero_result;
//ALUMux Wires
wire [15:0] ALUmux_result;
//DMemMux Wires
wire [15:0] DMemMux_result;
//Control Unit Wires
wire reg2loc, branch, memread, memtoreg, memwrite, alusrc, regwrite;
wire [2:0] alu_select;

assign signext = {{9{idata[12]}}, idata[12:6]};
assign daddr = ALU_result;
assign dwrite = memwrite;
assign dread = memread;
assign dwdata = rdata2;

MUX2 ALUMux(ALUmux_result,rdata2,signext,alusrc);

ALU alu(ALU_result,zero_result,rdata1,ALUmux_result,alu_select);

PCLogic ProgramCounter(iaddr,clock,signext,branch,zero_result,reset);

Control ControlUnit(reg2loc,branch,memread,memtoreg,alu_select,memwrite,alusrc,regwrite,idata[15:13]);

MUX2 RegMux(regmux_result,idata[12:10],idata[2:0],reg2loc);

RegFile Registers(rdata1,rdata2,clock,DMemMux_result,idata[2:0],idata[5:3],regmux_result,regwrite);

MUX2 DMemMux(DMemMux_result,ALU_result,ddata,memtoreg);

endmodule

