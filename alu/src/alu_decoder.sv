`include "alu_defs.sv"
`include "../../common/src/rv32i_defs.sv"

module alu_decoder (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output logic [`ALU_CTL_WIDTH-1:0] ctl
);

    always_comb begin
        case (opcode)
            `RV32_LOAD, `RV32_STORE: ctl = `ALU_ADD;
            `RV32_BRANCH: 
                case (funct3)
                    `FUNCT3_BEQ:    ctl = `ALU_SEQ;
                    `FUNCT3_BNE:    ctl = `ALU_SNE;
                    `FUNCT3_BLT:    ctl = `ALU_SLT;
                    `FUNCT3_BGE:    ctl = `ALU_SGE;
                    `FUNCT3_BLTU:   ctl = `ALU_SLTU;
                    `FUNCT3_BGEU:   ctl = `ALU_SGEU;
                    default: $display("ALU decoder error: unknown funct3 field for branch instruction.")
                endcase
            `RV32_OP, `RV32_OP_IMM:
                case (funct3)
                    `FUNCT3_ADD_SUB:    
                        ctl = (opcode == `RV32_OP && funct7[5]) ? 
                        `ALU_SUB : `ALU_ADD;
                    `FUNCT3_SLL:        ctl = `ALU_SLL;
                    `FUNCT3_SLT:        ctl = `ALU_SLT;
                    `FUNCT3_SLTU:       ctl = `ALU_SLTU;
                    `FUNCT3_XOR:        ctl = `ALU_XOR;
                    `FUNCT3_SRA_SRL:    ctl = funct7[5] ? `ALU_SRA : `ALU_SRL;
                    `FUNCT3_OR:         ctl = `ALU_OR;
                    `FUNCT3_AND:        ctl = `ALU_AND;
                    default: $display("ALU decoder error: unknown funct3 field for arithmetic instruction.")
                endcase
            default: $display("ALU decoder error: unknown opcode field for ALU instruction.")
        endcase
    end
endmodule