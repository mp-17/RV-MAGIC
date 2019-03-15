// RV-MAGIC HW COMPONENT //
//
///////////////////////////////////////// NEXT_ADDR_SEL_CU module //////////////////////////////////////
//
// This combinatorial CU is part of the branch/jump management HW block.
// It drives the selectors of the MUXes used to determine the next instruction address (i.e. the next $PC)
//
// branchIn : asserted iff the instruction is a BRANCH
// compResult : LSB of the ALU_out signal, it is asserted iff the condition of the BRANCH is verified
// jumpIn : asserted iff the instruction is a generic JUMP
// jalrIn : asserted iff the instruction is a JALR
// jalrOut : hardwired with jalrIn
// jumpOrBranch : asserted iff the jump/branch is taken, i.e. iff (instruction == JUMP or (instruction == BRANCH and comprResult == '1')) 
//

module next_addr_sel_cu (
	input branchIn, compResult, 
	input jumpIn, jalrIn,
	output jalrOut, jumpOrBranch
);

	logic branchTaken;

	assign jalrOut = jalrIn;
	assign branchTaken = branchIn & compResult;
	assign jumpOrBranch = jumpIn | branchTaken;

endmodule