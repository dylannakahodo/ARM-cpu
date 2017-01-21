// EE 361
// LEGLite 
// 
// The control module for LEGLite
//   The control will input the opcode value (3 bits)
//   then determine what the control signals should be
//   in the datapath
// 
//---------------------------------------------------------------
module Control(
		reg2loc,
		branch,
		memread,
		memtoreg,
		alu_select,
		memwrite,
		alusrc,
		regwrite,
		opcode
		);

output reg2loc;
output branch;
output memread;
output memtoreg;
output [2:0] alu_select; // Select to the ALU
output memwrite;
output alusrc;
output regwrite;
input  [2:0] opcode;

reg reg2loc;
reg branch;
reg memread;
reg memtoreg;
reg [2:0] alu_select;
reg memwrite;
reg alusrc;
reg regwrite;

always @(opcode)
	case(opcode)
	0:			// ADD instruction
	begin
	reg2loc = 0;   // Pick 2nd reg field
	branch = 0;    // Disable branch
	memread = 0;   // Disable memory
	emtoreg = 0;  // Select ALU to write to memory
	alu_select = 0; // Have ALU do an ADD
	memwrite = 0;  // Disable memory
	alusrc = 0;    // Select register for input to ALU
	regwrite = 1;  // Write result back to register file
	end
	3:            //LOAD Instruction
        begin
        reg2loc = 0;   //Don't Care for LD   
        branch = 0;    //Disable Branch
        memread = 1;   //Enable Memread
        memtoreg = 1;  //Memory written to register
        alu_select = 0; //ALU does ADD 
        memwrite = 0;  //Disable memory write  
        alusrc = 1;    //Changes 2nd alu input to the instruction    
        regwrite = 1;  //Writes to Register
        end
	4:            //STORE Instruction
        begin
        reg2loc = 1;   
        branch = 0;    
        memread = 0;  
        memtoreg = 0;  
        alu_select = 0; 
        memwrite = 1;  
        alusrc = 1;    
        regwrite = 0;  
        end
	5:            //CBZ Instruction
        begin
        reg2loc = 1;   
        branch = 1;    
        memread = 0;  
        memtoreg = 0;  
        alu_select = 2; 
        memwrite = 0;  
        alusrc = 0;    
        regwrite = 0;  
        end
	6:            //ADDI Instruction
        begin
        reg2loc = 0;   
        branch = 0;    
        memread = 0;  
        memtoreg = 0;  
        alu_select = 0; //ALU ADD
        memwrite = 0;  
        alusrc = 1;    
        regwrite = 1;  
        end
	7:            //ANDI Instruction
        begin
        reg2loc = 0;   
        branch = 0;    
        memread = 0;  
        memtoreg = 0;  
        alu_select = 4; //ALU AND 
        memwrite = 0;  
        alusrc = 1;    
        regwrite = 1;  
        end
	default:  // Note that default is unnecessary if all case 
		    //    values are considered
	begin
	reg2loc = 0;   
	branch = 0;    // Disable branch
	memread = 0;   
	memtoreg = 0;  
	alu_select = 0; 
	memwrite = 0;  // Disable memory
	alusrc = 0;    
	regwrite = 0;  // Disable regiter file
	end
	endcase

endmodule




