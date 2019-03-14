/* Complete datapath of the RISC-V core
*/

`include "../../common/src/rv32i_defs.sv"
`include "../../alu/src/alu_defs.sv"

module rvMagic (
    input clk, rst_n,
    // Instruction memory interface
    output [`ADDR_WIDTH-1:0] I_MEM_dataIn,
    output I_MEM_memRead,
    input [`INSTR_WIDTH-1:0] I_MEM_dataOut,
    // Data memory interface
    output [`ADDR_WIDTH-1:0] D_MEM_dataIn,
    output D_MEM_memRead, D_MEM_memWrite, D_MEM_memMode,
    input [`WORD_WIDTH-1:0] D_MEM_dataOut
);

    /* Signal declarations */
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
            ifId_FLUSH_FF_q;
    logic [`ADDR_WIDTH-1:0] NEXT_PC_MUX_out, 
                            PC_q, 
                            NEXT_PC_ADDER_out,
                            BRJAL_JALR_MUX_out,
                            IF_ID_pc,
                            IF_ID_nextPc,
                            ID_EX_pc,
                            ID_EX_nextPc;
    logic [`INSTR_WIDTH-1:0]    ifId_FLUSH_MUX_out;
    logic [`RF_ADDR_WIDTH-1:0]  DMEM_WB_writeAddr,
                                ID_EX_rs1,
                                ID_EX_rs2,
                                ID_EX_rd;
    logic [`WORD_WIDTH-1:0] JUMP_WB_MUX_out,
                            RF_dataOut0,
                            RF_dataOut1,
                            IMM_GEN_immediate,
                            ID_EX_immediate,
                            ID_EX_dataOut0,
                            ID_EX_dataOut1;
    logic [`ALU_CTL_WIDTH-1:0]  ALU_DECODER_ctl,
                                ID_EX_aluCtl;
    logic [8:0] idEx_FLUSH_MUX_out,
                ID_EX_controls;


    /* Module instantiations */

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

    // ifId_FLUSH_MUX
    mux2 
    #(
        .NB (`INSTR_WIDTH)
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
        .regWrite  (CU_RF_write),
        .readAddr0 (ifId_FLUSH_MUX_out[`RV32I_RS1_START+:`RF_ADDR_WIDTH]),
        .readAddr1 (ifId_FLUSH_MUX_out[`RV32I_RS2_START+:`RF_ADDR_WIDTH]),
        .writeAddr (DMEM_WB_writeAddr),
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

    // ALU_DECODER
    alu_decoder ALU_DECODER (
    	.opcode (ifId_FLUSH_MUX_out[`RV32I_OPCODE_START+:RV32I_OPCODE_WIDTH]),
        .funct3 (ifId_FLUSH_MUX_out[`RV32I_FUNCT3_START+:RV32I_FUNCT3_WIDTH]),
        .funct7 (ifId_FLUSH_MUX_out[`RV32I_FUNCT7_START+:RV32I_FUNCT7_WIDTH]),
        .ctl    (ALU_DECODER_ctl)
    );

    // idEx_FLUSH_MUX
    mux2 
    #(
        .NB (9)
    )
    idEx_FLUSH_MUX (
    	.in0 ({
            CU_RF_write,                // [8]
            CU_DMEM_ALU_WB_MUX_sel,     // [7]
            CU_D_MEM_write,             // [6]
            CU_D_MEM_read,              // [5]
            CU_D_MEM_mode,              // [4]
            CU_jump,                    // [3]
            CU_branch,                  // [2]
            CU_jalr,                    // [1]
            CU_RS2_IMM_ALU_SRC_MUX_sel  // [0]
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
            9
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
    
    
    

endmodule