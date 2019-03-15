/* Complete datapath of the RISC-V core
*/

`include "../../common/src/rv32i_defs.sv"
`include "../../alu/src/alu_defs.sv"

`define IDEX_CTRL_WIDTH 9
`define EXDMEM_CTRL_WIDTH 8
`define DMEMWB_CTRL_WIDTH 3

module rvMagic (
    input clk, rst_n,
    // Instruction memory interface
    output [`ADDR_WIDTH-1:0] I_MEM_dataIn,
    output I_MEM_memRead,
    input [`INST_WIDTH-1:0] I_MEM_dataOut,
    // Data memory interface
    output [`ADDR_WIDTH-1:0] D_MEM_dataIn,
    output D_MEM_memRead, D_MEM_memWrite, D_MEM_memMode,
    input [`WORD_WIDTH-1:0] D_MEM_dataOut
);

    /**** Signal declarations ****/
    logic   // HDU signals
            HDU_stall_n,
            HDU_flush_IdEx,
            HDU_flush_IfId_ExMem,
            // FWU signals
            // CU signals
            CU_RF_write,
            CU_immType,
            CU_D_MEM_write,
            CU_D_MEM_read,
            CU_D_MEM_mode,
            CU_RS2_IMM_ALU_SRC_MUX_sel,
            CU_DMEM_ALU_WB_MUX_sel,
            CU_jump,
            CU_branch,
            CU_jalr,
            // Others
            NEXT_ADDR_SEL_CU_jumpOrBranch,
            ifId_FLUSH_FF_q,
            FWU_fwdWriteData,
            NEXT_ADDR_SEL_CU_jalrOut;
    logic [`ADDR_WIDTH-1:0] NEXT_PC_MUX_out, 
                            PC_q, 
                            NEXT_PC_ADDER_out,
                            BRJAL_JALR_MUX_out,
                            IF_ID_pc,
                            IF_ID_nextPc,
                            ID_EX_pc,
                            ID_EX_nextPc,
                            EX_DMEM_nextPc,
                            EX_DMEM_jumpAddr,
                            EX_DMEM_jalrAddr,
                            DMEM_WB_nextPc;
    logic [`INST_WIDTH-1:0]    ifId_FLUSH_MUX_out;
    logic [`RF_ADDR_WIDTH-1:0]  DMEM_WB_rd,
                                ID_EX_rs1,
                                ID_EX_rs2,
                                ID_EX_rd,
                                EX_DMEM_rs2,
                                EX_DMEM_rd;
    logic [`WORD_WIDTH-1:0] JUMP_WB_MUX_out,
                            RF_dataOut0,
                            RF_dataOut1,
                            IMM_GEN_immediate,
                            ID_EX_immediate,
                            ID_EX_dataOut0,
                            ID_EX_dataOut1,
                            EX_DMEM_WB_aluOut,
                            DMEM_ALU_WB_MUX_out,
                            RS1_ALU_FWD_MUX_out,
                            RS2_ALU_FWD_MUX_out,
                            RS2_IMM_ALU_SRC_MUX_out,
                            ALU_out,
                            EX_DMEM_memDataIn,
                            DMEM_WB_aluOut;
    logic [`ALU_CTL_WIDTH-1:0]  ALU_DECODER_ctl,
                                ID_EX_aluCtl;
    logic [`IDEX_CTRL_WIDTH-1:0]    ID_EX_controls,
                                    idEx_FLUSH_MUX_out;
    logic [`EXDMEM_CTRL_WIDTH-1:0]   EX_DMEM_controls,
                                    exDmem_FLUSH_MUX_out;
    logic [`DMEMWB_CTRL_WIDTH-1:0]  DMEM_WB_controls;
    logic [1:0] FWU_fwdA, FWU_fwdB;


    /**** Module instantiations ****/
    /* IF stage */
    // PC
    register 
    #(
        .NB (`ADDR_WIDTH)
    )
    PC (
    	.clk   (clk),
        .rst_n (rst_n),
        .clr   (0),
        .en    (HDU_stall_n),
        .d     (NEXT_PC_MUX_out),
        .q     (PC_q)
    );

    // NEXT_PC_ADDER
    assign NEXT_PC_ADDER_out = PC_q + 4;

    // NEXT_PC_MUX
    mux2 
    #(
        .NB (`ADDR_WIDTH)
    )
    NEXT_PC_MUX (
    	.in0 (NEXT_PC_ADDER_out),
        .in1 (BRJAL_JALR_MUX_out),
        .sel (NEXT_ADDR_SEL_CU_jumpOrBranch),
        .out (NEXT_PC_MUX_out)
    );
    
    // IF_ID
    register 
    #(
        .NB (2 * `ADDR_WIDTH)
    )
    IF_ID (
    	.clk   (clk),
        .rst_n (rst_n),
        .clr   (0),
        .en    (HDU_stall_n),
        .d     ({   NEXT_PC_ADDER_out,  // d1 
                    PC_q                // d0
        }),             
        .q     ({   IF_ID_nextPc,       // q1 
                    IF_ID_pc            // q0
        })          
    );

    // I_MEM interface
    assign I_MEM_memRead = HDU_stall_n;
    assign I_MEM_dataIn = PC_q;

    /* ID stage */
    // ifId_FLUSH_MUX
    mux2 
    #(
        .NB (`INST_WIDTH)
    )
    ifId_FLUSH_MUX (
    	.in0 (I_MEM_dataOut),
        .in1 (`RV_NOP),
        .sel (ifId_FLUSH_FF_q),
        .out (ifId_FLUSH_MUX_out) // the actual selected instruction
    );
    
    // ifId_FLUSH_FF
    register 
    #(
        .NB (1)
    )
    ifId_FLUSH_FF (
    	.clk   (clk),
        .rst_n (rst_n),
        .clr   (0),
        .en    (1),
        .d     (HDU_flush_IfId_ExMem),
        .q     (ifId_FLUSH_FF_q)
    );
    
    // RF
    rf RF (
    	.clk       (clk),
        .regWrite  (DMEM_WB_controls[0]),
        .readAddr0 (ifId_FLUSH_MUX_out[`RV32I_RS1_START+:`RF_ADDR_WIDTH]),
        .readAddr1 (ifId_FLUSH_MUX_out[`RV32I_RS2_START+:`RF_ADDR_WIDTH]),
        .writeAddr (DMEM_WB_rd),
        .dataIn    (JUMP_WB_MUX_out),
        .dataOut0  (RF_dataOut0),
        .dataOut1  (RF_dataOut1)
    );
    
    // IMM_GEN
    immgen IMM_GEN (
    	.instruction (ifId_FLUSH_MUX_out),
        .imm_type    (CU_immType),
        .immediate   (IMM_GEN_immediate)
    );

    // ALU_DECODER
    alu_decoder ALU_DECODER (
    	.opcode (ifId_FLUSH_MUX_out[`RV32I_OPCODE_START+:`RV32I_OPCODE_WIDTH]),
        .funct3 (ifId_FLUSH_MUX_out[`RV32I_FUNCT3_START+:`RV32I_FUNCT3_WIDTH]),
        .funct7 (ifId_FLUSH_MUX_out[`RV32I_FUNCT7_START+:`RV32I_FUNCT7_WIDTH]),
        .ctl    (ALU_DECODER_ctl)
    );

    // idEx_FLUSH_MUX
    mux2 
    #(
        .NB (`IDEX_CTRL_WIDTH)
    )
    idEx_FLUSH_MUX (
    	.in0 ({
            CU_RS2_IMM_ALU_SRC_MUX_sel, // [8]
            CU_jalr,                    // [7]
            CU_branch,                  // [6]
            CU_jump,                    // [5]
            CU_D_MEM_mode,              // [4]
            CU_D_MEM_read,              // [3]
            CU_D_MEM_write,             // [2]
            CU_DMEM_ALU_WB_MUX_sel,     // [1]
            CU_RF_write                 // [0]
        }),
        .in1 (0),
        .sel (HDU_flush_IdEx),
        .out (idEx_FLUSH_MUX_out)
    );
    
    // ID_EX
    register 
    #(
        .NB (
            3 * `RF_ADDR_WIDTH + 
            2 * `ADDR_WIDTH + 
            2 * `WORD_WIDTH + 
            `ALU_CTL_WIDTH +
            `IDEX_CTRL_WIDTH
        )
    )
    ID_EX (
    	.clk   (clk),
        .rst_n (rst_n),
        .clr   (0),
        .en    (1),
        .d     ({
            ifId_FLUSH_MUX_out[`RV32I_RS2_START+:`RF_ADDR_WIDTH],   // d17
            ifId_FLUSH_MUX_out[`RV32I_RS1_START+:`RF_ADDR_WIDTH],   // d16
            ifId_FLUSH_MUX_out[`RV32I_RD_START+:`RF_ADDR_WIDTH],    // d15
            IF_ID_nextPc,                                           // d14
            IF_ID_pc,                                               // d13
            IMM_GEN_immediate,                                      // d12
            RF_dataOut1,                                            // d11 
            RF_dataOut0,                                            // d10 
            ALU_DECODER_ctl,                                        // d9 
            idEx_FLUSH_MUX_out                                      // d[8:0]
        }),
        .q     ({
            ID_EX_rs2,          // q17
            ID_EX_rs1,          // q16
            ID_EX_rd,           // q15
            ID_EX_nextPc,       // q14
            ID_EX_pc,           // q13
            ID_EX_immediate,    // q12
            ID_EX_dataOut1,     // q11
            ID_EX_dataOut0,     // q10
            ID_EX_aluCtl,       // q9
            ID_EX_controls      // q[8:0]
        })
    );
    
    /* EX stage */
    // exDmem_FLUSH_MUX
    mux2 
    #(
        .NB (`EXDMEM_CTRL_WIDTH)
    )
    exDmem_FLUSH_MUX (
    	.in0 (ID_EX_controls[7:0]),
        .in1 (0),
        .sel (HDU_flush_IfId_ExMem),
        .out (exDmem_FLUSH_MUX_out)
    );
    
    // RS1_ALU_FWD_MUX
    mux3 
    #(
        .NB (`WORD_WIDTH)
    )
    RS1_ALU_FWD_MUX (
    	.in0 (ID_EX_dataOut0),
        .in1 (EX_DMEM_WB_aluOut),
        .in2 (DMEM_ALU_WB_MUX_out),
        .sel (FWU_fwdA),
        .out (RS1_ALU_FWD_MUX_out)
    );

    // RS2_ALU_FWD_MUX
    mux3 
    #(
        .NB (`WORD_WIDTH)
    )
    RS2_ALU_FWD_MUX (
    	.in0 (ID_EX_dataOut1),
        .in1 (EX_DMEM_WB_aluOut),
        .in2 (DMEM_ALU_WB_MUX_out),
        .sel (FWU_fwdB),
        .out (RS2_ALU_FWD_MUX_out)
    );    

    // RS2_IMM_ALU_SRC_MUX
    mux2 
    #(
        .NB (`WORD_WIDTH)
    )
    RS2_IMM_ALU_SRC_MUX (
    	.in0 (RS2_ALU_FWD_MUX_out),
        .in1 (ID_EX_immediate),
        .sel (ID_EX_controls[8]),
        .out (RS2_IMM_ALU_SRC_MUX_out)
    );
    
    // ALU
    alu ALU (
    	.a   (RS1_ALU_FWD_MUX_out),
        .b   (RS2_IMM_ALU_SRC_MUX_out),
        .ctl (ID_EX_aluCtl),
        .out (ALU_out)
    );
    
    // BR_JAL_ADDER
    assign BR_JAL_ADDER_out = (ID_EX_immediate << 1) + ID_EX_pc;

    // EX_DMEM
    register 
    #(
        .NB (
            2 * `RF_ADDR_WIDTH + 
            2 * `ADDR_WIDTH + 
            2 * `WORD_WIDTH + 
            `EXDMEM_CTRL_WIDTH
        )
    )
    EX_DMEM (
    	.clk   (clk),
        .rst_n (rst_n),
        .clr   (0),
        .en    (1),
        .d     ({
            ID_EX_rs2,              // d13 (wrongly d12 in the schematic)
            ID_EX_rd,               // d12
            ID_EX_nextPc,           // d11
            BR_JAL_ADDER_out,       // d10
            ALU_out,                // d9
            RS2_ALU_FWD_MUX_out,    // d8
            ID_EX_controls[7:0]     // d[7:0]
        }),
        .q     ({
            EX_DMEM_rs2,        // q13
            EX_DMEM_rd,         // q12
            EX_DMEM_nextPc,     // q11
            EX_DMEM_jumpAddr,   // q10
            EX_DMEM_WB_aluOut,     // q9
            EX_DMEM_memDataIn,  // q8
            EX_DMEM_controls    // q[7:0]
        })
    );

    /* DMEM stage */
    // BRJAL_JALR_MUX
    mux2 
    #(
        .NB (`ADDR_WIDTH)
    )
    BRJAL_JALR_MUX (
    	.in0 (EX_DMEM_jumpAddr),
        .in1 ({EX_DMEM_WB_aluOut[`WORD_WIDTH-1:1], 0}),
        .sel (NEXT_ADDR_SEL_CU_jalrOut),
        .out (BRJAL_JALR_MUX_out)
    );

    // DMEM_FWD_MUX
    mux2 
    #(
        .NB (`ADDR_WIDTH)
    )
    DMEM_FWD_MUX (
    	.in0 (EX_DMEM_WB_aluOut),
        .in1 (DMEM_ALU_WB_MUX_out),
        .sel (FWU_fwdWriteData),
        .out (D_MEM_dataIn)
    );

    // D_MEM interface
    assign D_MEM_memWrite = EX_DMEM_controls[2];
    assign D_MEM_memRead = EX_DMEM_controls[3];
    assign D_MEM_memMode = EX_DMEM_controls[4];
    
    // DMEM_WB
    register 
    #(
        .NB (
            `WORD_WIDTH +
            `ADDR_WIDTH + 
            `WORD_WIDTH + 
            `DMEMWB_CTRL_WIDTH
        )
    )
    DMEM_WB (
    	.clk   (clk),
        .rst_n (rst_n),
        .clr   (0),
        .en    (1),
        .d     ({
            EX_DMEM_rd,                                     // d5
            EX_DMEM_nextPc,                                 // d4
            EX_DMEM_WB_aluOut,                                 // d3
            {EX_DMEM_controls[5], EX_DMEM_controls[1:0]}    // d[2:0]
        }),
        .q     ({
            DMEM_WB_rd,         // q5
            DMEM_WB_nextPc,     // q4
            DMEM_WB_aluOut,     // q3
            DMEM_WB_controls    // q[2:0]
        })
    );
    
    /* WB stage */
    // DMEM_ALU_WB_MUX
    mux2 
    #(
        .NB (`WORD_WIDTH)
    )
    DMEM_ALU_WB_MUX (
    	.in0 (DMEM_WB_aluOut),
        .in1 (D_MEM_dataOut),
        .sel (DMEM_WB_controls[1]),
        .out (DMEM_ALU_WB_MUX_out)
    );

    // JUMP_WB_MUX
    mux2 
    #(
        .NB (`WORD_WIDTH)
    )
    JUMP_WB_MUX (
    	.in0 (DMEM_ALU_WB_MUX_out),
        .in1 (DMEM_WB_nextPc),
        .sel (DMEM_WB_controls[2]),
        .out (JUMP_WB_MUX_out)
    );
    
    /* Control units */
    // CU
    cu CU (
    	.instruction             (ifId_FLUSH_MUX_out),
        .imm_type                (CU_immType),
        .D_MEM_write             (CU_D_MEM_write),
        .D_MEM_read              (CU_D_MEM_read),
        .D_MEM_mode              (CU_D_MEM_mode),
        .RF_write                (CU_RF_write),
        .RS2_IMM_ALU_SRC_MUX_sel (CU_RS2_IMM_ALU_SRC_MUX_sel),
        .DMEM_ALU_WB_MUX_sel     (CU_DMEM_ALU_WB_MUX_sel),
        .branch                  (CU_branch),
        .jump                    (CU_jump),
        .jalr                    (CU_jalr)
    );

    // HDU
    hdu HDU (
    	.ifidRs1        (ifId_FLUSH_MUX_out[`RV32I_RS1_START+:`RF_ADDR_WIDTH]),
        .ifidRs2        (ifId_FLUSH_MUX_out[`RV32I_RS2_START+:`RF_ADDR_WIDTH]),
        .idexRd         (ID_EX_rd),
        .ifidMemWrite   (CU_D_MEM_write),
        .idexMemRead    (ID_EX_controls[3]),
        .branchOrJump   (NEXT_ADDR_SEL_CU_jumpOrBranch),
        .stall_n        (HDU_stall_n),
        .flushIdEx      (HDU_flush_IdEx),
        .flushIfIdExMem (HDU_flush_IfId_ExMem)
    );

    // FWU
    fwu FWU (
    	.idexRs1       (ID_EX_rs1),
        .idexRs2       (ID_EX_rs2),
        .exmemRs2      (EX_DMEM_rs2),
        .exmemRd       (EX_DMEM_rd),
        .memwbRd       (DMEM_WB_rd),
        .exmemRegWrite (EX_DMEM_controls[0]),
        .exmemMemWrite (EX_DMEM_controls[2]),
        .memwbRegWrite (DMEM_WB_controls[0]),
        .memwbMemToReg (DMEM_WB_controls[1]),
        .fwdA          (FWU_fwdA),
        .fwdB          (FWU_fwdB),
        .fwdWriteData  (FWU_fwdWriteData)
    );

    // NEXT_ADDR_SEL_CU
    // !!!! MISSING !!!!
    
endmodule