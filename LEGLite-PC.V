0// EE 361
// LEGLite
// 
// * PC and PC Control:  Program Counter and
//         the PC control logic

//--------------------------------------------------------------
// PC and PC Control
module PCLogic(
		pc,		// current pc value
		clock,	// clock input
		signext,	// from sign extend circuit
		branch,	// CBZ instruction
		alu_zero,	// zero from ALU, used in cond branch
		reset		// reset input
		);


output [15:0] pc;
input clock;
input [15:0] signext;  // From sign extend circuit
input branch;
input alu_zero;
input reset;

reg [15:0] pc; 
												    
// Program counter pc is updated
//   * if reset = 0 then pc = 0
//   * otherwise pc = pc +2
// What's missing is how pc is updated when a branch occurs

always @(posedge clock)
	begin
	if (reset==1) pc <= 0;
	else if(branch==1 && alu_zero==1) pc <= pc + (signext<<1);
	else pc <= pc+2; // default
	end
		
endmodule
