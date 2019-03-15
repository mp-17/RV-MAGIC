`include "../../common/src/rv32i_defs.sv"

// this cu is only combinational since the memory part is supplied by the pipeline registers
// it simply takes all the codes from the current instruction and computes the corresponding output control signals
module cu
(
    input [`INST_WIDTH-1:0] instruction,  // input instruction to be decoded
    output [`IMMEDIATE_SELECTION_WIDTH-1:0] imm_type, // to control the immediate generation unit
    output D_MEM_write, D_MEM_read, // control signal for the DMEM. "mode" is for bit width selection. #Old: MemWrite, MemRead, -
    output [`MEMORY_MODE_WIDTH-1:0] D_MEM_mode,
    output RF_write, // write control signal for the RF. #Old: RegWrite
    output RS1_PC_ALU_SRC_MUX_sel, // sel for the mux on the second input (b) of the ALU. Select either IMM or $(Rs2). #Old: ALUSrc
    output RS2_IMM_ALU_SRC_MUX_sel, // sel for the mux on the second input (b) of the ALU. Select either IMM or $(Rs2). #Old: ALUSrc
    output DMEM_ALU_WB_MUX_sel, // sel for the mux in WB stage. Let pass either DMEM_dataOut or ALU_out. #Old: MemtoReg
    output branch, jump, jalr // asserted if the instruction is respectivly a branch, a JAL, a JALR. #OLD: Branch
);

    always_comb begin
        // default values
        imm_type = `NOP_TYPE;
        D_MEM_write = 0;
        D_MEM_read = 0;
        D_MEM_mode = `BYTE_MEMORY_MODE;
        RF_write = 0;
        RS1_PC_ALU_SRC_MUX_sel = 0;
        RS2_IMM_ALU_SRC_MUX_sel = 0;
        DMEM_ALU_WB_MUX_sel = 0;
        branch = 0;
        jump = 0;
        jalr = 0;

        if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_LUI_OPCODE)
        begin
            imm_type = `U_TYPE;
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RS2_IMM_ALU_SRC_MUX_sel = 1; // immediate
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_AUIPC_OPCODE)
        begin
            imm_type = `U_TYPE;
            RS1_PC_ALU_SRC_MUX_sel = 1; // PC
            RS2_IMM_ALU_SRC_MUX_sel = 1; // immediate
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_JAL_OPCODE)
        begin
            imm_type = `J_TYPE;
            jump = 1;
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_JALR_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_JALR_FUNCT3)
        begin
            imm_type = `I_TYPE;
            jalr = 1;
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_BEQ_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_BEQ_FUNCT3)
        begin
            imm_type = `B_TYPE;
            branch = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_BNE_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_BNE_FUNCT3)
        begin
            imm_type = `B_TYPE;
            branch = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_BLT_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_BLT_FUNCT3)
        begin
            imm_type = `B_TYPE;
            branch = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_BGE_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_BGE_FUNCT3)
        begin
            imm_type = `B_TYPE;
            branch = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_BLTU_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_BLTU_FUNCT3)
        begin
            imm_type = `B_TYPE;
            branch = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_BGEU_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_BGEU_FUNCT3)
        begin
            imm_type = `B_TYPE;
            branch = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_LB_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_LB_FUNCT3)
        begin
            imm_type = `I_TYPE;
            DMEM_ALU_WB_MUX_sel = 1; // DMEM
            D_MEM_read = 1;
            D_MEM_mode = `BYTE_MEMORY_MODE;
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_LH_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_LH_FUNCT3)
        begin
            imm_type = `I_TYPE;
            DMEM_ALU_WB_MUX_sel = 1; // DMEM
            D_MEM_read = 1;
            D_MEM_mode = `HALFWORD_MEMORY_MODE;
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_LW_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_LW_FUNCT3)
        begin
            imm_type = `I_TYPE;
            DMEM_ALU_WB_MUX_sel = 1; // DMEM
            D_MEM_read = 1;
            D_MEM_mode = `WORD_MEMORY_MODE;
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_LBU_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_LBU_FUNCT3)
        begin
            imm_type = `I_TYPE;
            DMEM_ALU_WB_MUX_sel = 1; // DMEM
            D_MEM_read = 1;
            D_MEM_mode = `BYTE_MEMORY_MODE;
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_LHU_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_LHU_FUNCT3)
        begin
            imm_type = `I_TYPE;
            DMEM_ALU_WB_MUX_sel = 1; // DMEM
            D_MEM_read = 1;
            D_MEM_mode = `HALFWORD_MEMORY_MODE;
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SB_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SB_FUNCT3)
        begin
            imm_type = `S_TYPE;
            D_MEM_write = 1;
            D_MEM_mode = `BYTE_MEMORY_MODE;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SH_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SH_FUNCT3)
        begin
            imm_type = `S_TYPE;
            D_MEM_write = 1;
            D_MEM_mode = `HALFWORD_MEMORY_MODE;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SW_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SW_FUNCT3)
        begin
            imm_type = `S_TYPE;
            D_MEM_write = 1;
            D_MEM_mode = `WORD_MEMORY_MODE;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_ADDI_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_ADDI_FUNCT3)
        begin
            imm_type = `I_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 1; // immediate
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SLTI_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SLTI_FUNCT3)
        begin
            imm_type = `I_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 1; // immediate
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SLTIU_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SLTIU_FUNCT3)
        begin
            imm_type = `I_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 1; // immediate
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_XORI_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_XORI_FUNCT3)
        begin
            imm_type = `I_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 1; // immediate
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_ORI_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_ORI_FUNCT3)
        begin
            imm_type = `I_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 1; // immediate
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_ANDI_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_ANDI_FUNCT3)
        begin
            imm_type = `I_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 1; // immediate
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SLLI_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SLLI_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_SLLI_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 1; // immediate --> uses rs2 position but it is the same as lowest bits of immediate --> we need the value directly, not the value from the regfile
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SRLI_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SRLI_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_SRLI_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 1; // immediate --> uses rs2 position but it is the same as lowest bits of immediate --> we need the value directly, not the value from the regfile
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SRAI_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SRAI_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_SRAI_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 1; // immediate --> uses rs2 position but it is the same as lowest bits of immediate --> we need the value directly, not the value from the regfile
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_ADD_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_ADD_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_ADD_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 0; // Rs2
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SUB_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SUB_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_SUB_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 0; // Rs2
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SLL_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SLL_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_SLL_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 0; // Rs2
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SLT_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SLT_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_SLT_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 0; // Rs2
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SLTU_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SLTU_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_SLTU_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 0; // Rs2
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_XOR_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_XOR_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_XOR_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 0; // Rs2
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SRL_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SRL_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_SRL_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 0; // Rs2
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_SRA_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_SRA_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_SRA_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 0; // Rs2
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_OR_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_OR_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_OR_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 0; // Rs2
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
        else if (instruction[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH] == RV32I_AND_OPCODE && instruction[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH] == RV32I_AND_FUNCT3 && instruction[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH] == RV32I_AND_FUNCT7)
        begin
            imm_type = `R_TYPE;
            RS2_IMM_ALU_SRC_MUX_sel = 0; // Rs2
            DMEM_ALU_WB_MUX_sel = 0; // ALU
            RF_write = 1;
        end
    end
endmodule
