// width-related constants
`define INST_WIDTH      32
`define ADDR_WIDTH      32
`define WORD_WIDTH      32
`define HWORD_WIDTH     16
`define BYTE_WIDTH      8
`define SHAMT_WIDTH     5

// U-type opcodes
`define RV32_LUI     7'b0110111
`define RV32_AUIPC   7'b0010111

// J-type opcodes
`define RV32_JAL     7'b1101111

// I-type opcodes
`define RV32_JALR    7'b1100111
`define RV32_LOAD    7'b0000011
`define RV32_OP_IMM  7'b0010011
`define RV32_FENCE   7'b0001111
`define RV32_SYSTEM  7'b1110011

// B-type opcodes
`define RV32_BRANCH  7'b1100011

// S-type opcodes
`define RV32_STORE   7'b0100011

// R-type opcodes
`define RV32_OP      7'b0110011

// NOP
`define RV_NOP `INST_WIDTH'b0010011

// arithmetic funct3 encodings
`define FUNCT3_ADD_SUB 0
`define FUNCT3_SLL     1
`define FUNCT3_SLT     2
`define FUNCT3_SLTU    3
`define FUNCT3_XOR     4
`define FUNCT3_SRA_SRL 5
`define FUNCT3_OR      6
`define FUNCT3_AND     7

// branch funct3 encodings
`define FUNCT3_BEQ  0
`define FUNCT3_BNE  1
`define FUNCT3_BLT  4
`define FUNCT3_BGE  5
`define FUNCT3_BLTU 6
`define FUNCT3_BGEU 7

// fence funct3 encodings
`define FUNCT3_FENCE   0
`define FUNCT3_FENCE_I 1

// system funct3 encodings
`define FUNCT3_ENV    0
`define FUNCT3_CSRRW  1
`define FUNCT3_CSRRS  2
`define FUNCT3_CSRRC  3
`define FUNCT3_CSRRWI 5
`define FUNCT3_CSRRSI 6
`define FUNCT3_CSRRCI 7

// env funct12 encodings
`define FUNCT12_ECALL  12'b000000000000
`define FUNCT12_EBREAK 12'b000000000001
