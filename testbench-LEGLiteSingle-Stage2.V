// Testbench for LEGLiteSingle Stage 2

module testbenchLEGLiteSingle;

wire [15:0] iaddr;
wire [15:0] draddr;
wire dwrite;
wire dread;
wire [15:0] dwdata;
wire [15:0] drdata;
wire [15:0] alu_out;
reg clock;
wire [15:0] idata;
reg reset;
wire [6:0] io_display;
reg io_sw0;
reg io_sw1;
wire [15:0] probe;

initial clock=0; // Clock generator
always #1 clock=~clock;

// Instantiations of computer components
//    * LEGLiteSingle
//    * Instruction memory (IM1.V)
//    * Data memory + I/O
//
LEGLiteSingle cpu(
	iaddr,
	draddr,
	dwrite,
	dread,
	dwdata,
	alu_out,
	clock,
	idata,
	drdata,
	reset
);

IM IM_Circuit(idata,iaddr);

DMemory_IO DMemoryIO_Circ(
	drdata,
	io_display,
	clock,
	draddr,
	dwdata,
	dwrite,
	dread,
	io_sw0,
	io_sw1
);

initial
begin
$display("Instruction[pc]=[opcode,reg,reg,reg,imm]\n");

$display("DataMemory[addr]=[read data, write data]\n");
//  Note that the "write data" value of data memory is
//  the output of the ALU.  We can use this to check
//  if the add and addi are working properly
//  For example, for the instruction ADDI X4,XZR,#3, 
//  The output of the ALU should be 3.
//  Then if the instruction were ADDI X4,X4,#3,
//  the output of the ALU should be 6.

$display("Signals C-R-Sw-Disp[clock,reset,switch0,display]");

$display("* Recall data memory addr = ALU output\n");
io_sw0 = 1;
io_sw1 = 0;
reset = 0;
#2
reset = 1;
#2
reset = 0; 
#50
io_sw0=0;
#50
$finish;
end

initial
begin
// The monitor will first display
//      Instr[ address ] =
//           [opcode, reg, reg, reg, last 4 bits]
//      DataMem[ address, data]
//      C-R-Sw-Dsp [Clock,Reset,IO switch input0, IO output ]
$monitor("Instr[%d]=[%b,%b,%b,%b,%b] DataMem[%d]=[%d,%d] C-R-Sw-Dsp[%b,%b,%b,%b] %b",
	iaddr,
	idata[15:13],
	idata[12:10],
	idata[9:6],
	idata[5:3],
	idata[2:0],
	draddr,
	drdata,
	dwdata,
	clock,
	reset,
	io_sw0,
	io_display,
	probe
);
end

endmodule
