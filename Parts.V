// 16-bit ARM Parts
// 
// * Data Memory and IO:  This is the data memory, and some IO hardware
// * 8x16 register file:  eight 16-bit registers
// * 16-bit ALU
// * 2:1 16-bit Multiplexer
// * 4:1 16-bit Multiplexer

//----------------------------------------------------------
// Data Memory and IO
// The data memory is 128 16-bit words.  The addresses are
// 0, 2, 4, ...., 254.  Note that the address of words are 
// divisible by 2 (memory is byte addressable and big endian).
// This module also has some hardware for IO.  In particular,
// There are three ports:
//
//     Address	Type		What's it connected to
//     0xfffa	Output	Seven segment display
//     0xfff0	Input		Sliding Switches
//
// Output port 0xfffa is connected to an 7-bit register. So
// when storing a word "w" to the port, the value
// w[6:0] gets stored in the port's register.  The output
// of this register is connected to a seven segment display.
// The display has pin names
//
//    -a-
//   f   b
//    -g-
//   e   c
//    -d-
//
// and (a,b,c,d,e,f,g) = (w[6],w[5],....w[0]).  For example,
// to display the number "5", then w = (1,0,1,1,0,1,1).
//
// The input port 0xfff0 is connected to sliding switches SW1,
// SW0, and pushbutton PB0.  
//
// After reading a word "w" from the port,
// the word has value w[2] = SW1, w[1] = SW0, and w[0] = PB0.
//
// 
module DMemory_IO(
		rdata,  // read data
		io_display,	// IO port connected to 7 segment display
		clock,  // clock
		addr,   // address
		wdata,  // write data
		write,  // write enable
		read,   // read enable
		io_sw0, // IO port connected to sliding switch 0
		io_sw1  // IO port connected to sliding switch 1
		);
		

output [15:0] rdata;
output [6:0] io_display;
input clock;
input [15:0] addr;
input [15:0] wdata;
input write;
input read;
input io_sw0;
input io_sw1;

reg [15:0] memcell[0:127]; // 128 words = 256 bytes.  Each byte
                           //    has an addresses from
                           //    0, 1, ...., 255

reg [15:0] rdata;
wire [15:0] mem_rdata; // Output of data memory
wire [15:0] io_rdata;  // Input from io port 0xfffe, 
                       //      which is connected to 
                       //      sliding switches SW1 and SW0
                       //      through bits 1 and 0,
                       //      respectively

reg [6:0] io_display; // 7-segment display

// Output of data memory
assign mem_rdata = memcell[addr[7:1]]; // Only need bits 6, 5, 
                                       //  ..., 1 of the address

// The io port of the sliding switches.  
// Last two bits are the sliding switches
// SW1 and SW0 as bits 1 and 0, respectively.
assign io_rdata = {14'd0,io_sw1,io_sw0};

// This is basically a multiplexer, that chooses to output the
// memory or IO.  If data memory is being accessed then the
// address is between 0 and 255.  If the address is 0xfff0 then
// the io port is being accessed.  This io port is connected to
// the sliding switches SW1 and SW0 at bits 1 and 0, respectively.
always @(addr or mem_rdata or io_rdata or read)
	begin
	if (read == 0) rdata = 0;
	else // read = 1
		begin
		if (addr >= 0 && addr < 256) 	rdata = mem_rdata; 
		else if (addr == 16'hfff0) 		rdata = io_rdata;
		else rdata = 0; // default 
		end
	end

// IO port 0xfffa that is connected to the seven segment display.
// This loads the port register.
always @(posedge clock)
	if (write == 1 && addr == 16'hfffa) 
         io_display <= wdata[6:0];

// Note that if waddr[15:0] = 0 
//   then 0 <= waddr < 256 and one of the
// 256 memory cells is being accessed
always @(posedge clock)
	if (write == 1 && addr[15:8] == 0) memcell[addr[7:1]] <= wdata;

endmodule

//----------------------------------------------------------
// 8x16 Register File
module RegFile(
	rdata1,  // read data output 1
	rdata2,  // read data output 2
	clock,		
	wdata,   // write data input
	waddr,   // write address
	raddr1,  // read address 1
	raddr2,  // read address 2
	write    // write enable
	);			

output [15:0] rdata1, rdata2; 	
input clock;
input [15:0] wdata; 			

input [2:0] raddr1, raddr2; 	
input [2:0] waddr; 			
input write;					

reg [15:0] rdata1, rdata2;

reg [15:0] regcell[0:7];		// Eight registers

// Writing to a register
always @(negedge clock) if (write==1) regcell[waddr]<=wdata;

// Reading from a register
always @(raddr1 or regcell[raddr1]) 
	if (raddr1 == 7) 	rdata1 = 0;
	else 				rdata1 = regcell[raddr1];

// Reading from a register
always @(raddr2 or regcell[raddr2]) 
	if (raddr2 == 7) 	rdata2 = 0;
	else 				rdata2 = regcell[raddr2];

endmodule

//----------------------------------------------------------
// ALU
// 
// Function table
// select	function

// 0		add
// 1		subtract
// 2		pass through 'indata1' to the output 'result'
// 3		or
// 4		and
//
module ALU(
	result,      // 16-bit output from the ALU
	zero_result, // equals 1 if the result is 0, and 0 otherwise
	indata0,     // data input
	indata1,     // data input
	select       // 3-bit select
	);		

output [15:0] result;
output zero_result;
input [15:0] indata0, indata1;
input [2:0] select;


reg [15:0] result;
reg zero_result;

always @(indata0 or indata1 or select)
	case(select)
	0: result = indata0 + indata1;
	1: result = indata0 - indata1;
	2: result = indata1;
	3: result = indata0 | indata1;
	4: result = indata0 & indata1;
	default: result = 0;
	endcase

always @(result) // This is basically a NOR operation
	if (result == 0) 	zero_result = 1;
	else 			  	zero_result = 0;

endmodule

//----------------------------------------------------------
// 2:1 Multiplexer

module MUX2(
	result,   // Output of multiplexer
	indata0,  // Input 0
	indata1,  // Input 1
	select    // 1-bit select
	);	

output [15:0] result;
input [15:0] indata0, indata1;
input select;

reg [15:0] result;

always @(indata0 or indata1 or select)
	case(select)
	0: result = indata0;
	1: result = indata1;
	endcase

endmodule

//----------------------------------------------------------
// 4:1 Multiplexer
module MUX4(
	result,  // 16 bit output
	indata0, // Input 0
	indata1, // Input 1
	indata2, // Input 2
	indata3, // Input 3
	select   // 2-bit select input
	);	

output [15:0] result;
input [15:0] indata0, indata1, indata2, indata3;
input [1:0] select;

reg [15:0] result;

always @(indata0 or indata1 or indata2 or indata3 or select)
	case(select)
	0: result = indata0;
	1: result = indata1;
	2: result = indata2;
	3: result = indata3;
	endcase

endmodule

//-----------------------------------------------------------
// Pipeline Register Modules
//-----------------------------------------------------------

//-----------------------------------------------------------
// IF/ID Register
module IFID(
    clock,  
    idata,  //Instruction memory data from IM
    pc,     //Current PC
    IFID_instr, //Reg for IM data
    IFID_pc      //Reg for PC
    );
    
input clock;
input [15:0] idata, pc;
output [15:0] IFID_instr, IFID_pc;

reg [15:0] IFID_instr, IFID_pc;

always @(posedge clock)
    begin
        IFID_instr <= idata;
        IFID_pc <= pc;
    end
endmodule

//-----------------------------------------------------------
// ID/EX Register
module IDEX(
    clock,
    ID_pc, //PC from IF/ID reg
    ID_regwrite, //regwrite signal from control
    ID_memtoreg, //memtoreg signal from control
    ID_branch,   //branch signal from control
    ID_memread, //memread signal from control
    ID_memwrite, //memwrite signal from control
    ID_alusrc, //alusrc signal from control
    ID_aluselect, //aluselect signal from control
    ID_rdata1, //read data 1 from register file
    ID_rdata2, //read data 2 from register file
    ID_signext, //16-bit sign extend of instruction
    ID_writereg, //write register from instruction memory
    IDEX_pc,
    IDEX_regwrite, //reg for regwrite
    IDEX_memtoreg, //reg for memtoreg
    IDEX_branch, //reg for branch
    IDEX_memread,//reg for memread
    IDEX_memwrite, //reg for memwrite
    IDEX_alusrc, //reg for alusrc
    IDEX_aluselect, //reg for aluselect
    IDEX_rdata1, //reg for rdata1
    IDEX_rdata2, //reg for rdata2
    IDEX_signext, //reg for signext
    IDEX_writereg //reg for writereg
    );
input clock, ID_regwrite, ID_memtoreg, ID_branch, ID_memread, ID_memwrite, ID_alusrc;
input [15:0] ID_pc, ID_rdata1, ID_rdata2, ID_signext;
input [2:0] ID_aluselect, ID_writereg;
output IDEX_regwrite, IDEX_memtoreg, IDEX_branch, IDEX_memread, IDEX_memwrite, IDEX_alusrc;
output [15:0] IDEX_rdata1, IDEX_rdata2, IDEX_signext, IDEX_pc;
output [2:0] IDEX_aluselect, IDEX_writereg;

reg IDEX_regwrite, IDEX_memtoreg, IDEX_branch, IDEX_memread, IDEX_memwrite, IDEX_alusrc;
reg [15:0] IDEX_rdata1, IDEX_rdata2, IDEX_signext, IDEX_pc;
reg [2:0] IDEX_aluselect, IDEX_writereg;

always @(posedge clock)
    begin
         IDEX_pc <= ID_pc;
         IDEX_regwrite <= ID_regwrite;
         IDEX_memtoreg <= ID_memtoreg;
         IDEX_branch <= ID_branch;
         IDEX_memread <= ID_memread;
         IDEX_memwrite <= ID_memwrite;
         IDEX_alusrc <= ID_alusrc;
         IDEX_rdata1 <= ID_rdata1;
         IDEX_rdata2 <= ID_rdata2;
         IDEX_signext <= ID_signext;
         IDEX_aluselect <= ID_aluselect;
         IDEX_writereg <= ID_writereg;
     end
endmodule

//-----------------------------------------------------------
// EX/MEM Register
module EXMEM(
    clock,
    EX_regwrite, //regwrite signal from ID/EX
    EX_memtoreg, //memtoreg signal from ID/EX
    EX_branch,   //branch signal from ID/EX
    EX_memread,  //memread signal from ID/EX
    EX_memwrite, //memwrite signal from ID/EX
    EX_branchaddr, //branch address calculated from CBZ circuit
    EX_aluzero,  //aluzero result from alu
    EX_aluresult, //calculated alu result
    EX_rdata2, //read data 2 from ID/EX
    EX_writereg, //write register from ID/EX
    EXMEM_regwrite,
    EXMEM_memtoreg,
    EXMEM_branch,
    EXMEM_memread,
    EXMEM_memwrite,
    EXMEM_branchaddr,
    EXMEM_aluzero,
    EXMEM_aluresult,
    EXMEM_rdata2,
    EXMEM_writereg
    );
input clock, EX_regwrite, EX_memtoreg, EX_branch, EX_memread, EX_memwrite, EX_aluzero;
input [15:0] EX_branchaddr, EX_aluresult, EX_rdata2;
input [2:0] EX_writereg;
output EXMEM_regwrite, EXMEM_memtoreg, EXMEM_branch, EXMEM_memread, EXMEM_memwrite, EXMEM_aluzero;
output [15:0] EXMEM_branchaddr, EXMEM_aluresult, EXMEM_rdata2;
output [2:0] EXMEM_writereg;

reg EXMEM_regwrite, EXMEM_memtoreg, EXMEM_branch, EXMEM_memread, EXMEM_memwrite, EXMEM_aluzero;
reg [15:0] EXMEM_branchaddr, EXMEM_aluresult, EXMEM_rdata2;
reg [2:0] EXMEM_writereg;

always @(posedge clock)
    begin
        EXMEM_regwrite <= EX_regwrite;
        EXMEM_memtoreg <= EX_memtoreg;
        EXMEM_branch <= EX_branch;
        EXMEM_memread <= EX_memread;
        EXMEM_memwrite <= EX_memwrite;
        EXMEM_aluzero <= EX_aluzero;
        EXMEM_branchaddr <= EX_branchaddr;
        EXMEM_aluresult <= EX_aluresult;
        EXMEM_rdata2 <= EX_rdata2;
        EXMEM_writereg <= EX_writereg;
    end
endmodule

//-----------------------------------------------------------
// MEM/WB Register
module MEMWB (
    clock,
    MEM_regwrite,
    MEM_memtoreg,
    MEM_DMreaddata,
    MEM_aluresult,
    MEM_writereg,
    MEMWB_regwrite,
    MEMWB_memtoreg,
    MEMWB_DMreaddata,
    MEMWB_aluresult,
    MEMWB_writereg
    );
input clock;
input MEM_regwrite, MEM_memtoreg;
input [15:0] MEM_DMreaddata, MEM_aluresult;
input [2:0] MEM_writereg;
output MEMWB_regwrite, MEMWB_memtoreg;
output [15:0] MEMWB_DMreaddata, MEMWB_aluresult;
output [2:0] MEMWB_writereg;

reg MEMWB_regwrite, MEMWB_memtoreg;
reg [15:0] MEMWB_DMreaddata, MEMWB_aluresult;
reg [2:0] MEMWB_writereg;

always @(posedge clock)
    begin
    MEMWB_regwrite <= MEM_regwrite;
    MEMWB_memtoreg <= MEM_memtoreg;
    MEMWB_DMreaddata <= MEM_DMreaddata;
    MEMWB_aluresult <= MEM_aluresult;
    MEMWB_writereg <=  MEM_writereg;
    end
endmodule    
    
