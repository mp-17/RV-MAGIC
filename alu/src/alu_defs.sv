// data widths
`define ALU_CTL_WIDTH 4

// ALU opcodes
`define ALU_ADD  `ALU_CTL_WIDTH'h0
`define ALU_SUB  `ALU_CTL_WIDTH'h1

`define ALU_AND  `ALU_CTL_WIDTH'h2
`define ALU_OR   `ALU_CTL_WIDTH'h3
`define ALU_XOR  `ALU_CTL_WIDTH'h4
`define ALU_SLL  `ALU_CTL_WIDTH'h5    // shift left
`define ALU_SRL  `ALU_CTL_WIDTH'h6    // shift right
`define ALU_SRA  `ALU_CTL_WIDTH'h7    // shift right w/ sign extension

`define ALU_SEQ  `ALU_CTL_WIDTH'h8    // set if equal
`define ALU_SNE  `ALU_CTL_WIDTH'h9    // set if not equal 
`define ALU_SLT  `ALU_CTL_WIDTH'hA    // set if less than
`define ALU_SGE  `ALU_CTL_WIDTH'hB    // set if greater or equal
`define ALU_SLTU `ALU_CTL_WIDTH'hC    // set if less than (unsigned)
`define ALU_SGEU `ALU_CTL_WIDTH'hD    // set if greater or equal (unsigned)