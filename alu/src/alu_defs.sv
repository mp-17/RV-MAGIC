// data widths
`define DATA_WIDTH 32
`define ALU_OP_WIDTH 4
`define SHAMT_WIDTH 5

// ALU opcodes
`define ALU_OP_ADD  `ALU_OP_WIDTH'd0
`define ALU_OP_SUB  `ALU_OP_WIDTH'd1

`define ALU_OP_AND  `ALU_OP_WIDTH'd2
`define ALU_OP_OR   `ALU_OP_WIDTH'd3
`define ALU_OP_XOR  `ALU_OP_WIDTH'd4
`define ALU_OP_SLL  `ALU_OP_WIDTH'd5    // shift left
`define ALU_OP_SRL  `ALU_OP_WIDTH'd6    // shift right
`define ALU_OP_SRA  `ALU_OP_WIDTH'd7    // shift right w/ sign extension

`define ALU_OP_SEQ  `ALU_OP_WIDTH'd8    // set if equal
`define ALU_OP_SNE  `ALU_OP_WIDTH'd9    // set if not equal 
`define ALU_OP_SLT  `ALU_OP_WIDTH'd10   // set if less than
`define ALU_OP_SGE  `ALU_OP_WIDTH'd11   // set if greater or equal
`define ALU_OP_SLTU `ALU_OP_WIDTH'd12   // set if less than (unsigned)
`define ALU_OP_SGEU `ALU_OP_WIDTH'd13   // set if greater or equal (unsigned)