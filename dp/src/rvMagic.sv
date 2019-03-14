/* Complete datapath of the RISC-V core
*/

`include "../../common/src/rv32i_defs.sv"

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
            HDU_flush_IfId_ExMem,
            // FWU signals
            // CU signals
            CU_RF_write,
            // Others
            NEXT_ADDR_SEL_CU_jumpOrBranch,
            ifId_FLUSH_FF_q;
    logic [`ADDR_WIDTH-1:0] NEXT_PC_MUX_out, 
                            PC_q, 
                            NEXT_PC_ADDER_out,
                            BRJAL_JALR_MUX_out,
                            IF_ID_pc,
                            IF_ID_nextPc;
    logic [`INSTR_WIDTH-1:0]    ifId_FLUSH_MUX_out;
    logic [`RF_ADDR_WIDTH-1:0]  DMEM_WB_writeAddr;
    logic [`WORD_WIDTH-1:0] JUMP_WB_MUX_out,
                            RF_dataOut0,
                            RF_dataOut1;


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
        .d     ({   NEXT_PC_ADDER_out,  // [63:32]
                    PC_q}),             // [31:0]
        .q     ({   IF_ID_nextPc,       // [63:32]
                    IF_ID_pc})          // [31:0]
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
    rf RF(
    	.clk       (clk),
        .regWrite  (CU_RF_write),
        .readAddr0 (ifId_FLUSH_MUX_out[`RV32I_RS1_START+:`RF_ADDR_WIDTH]),
        .readAddr1 (ifId_FLUSH_MUX_out[`RV32I_RS2_START+:`RF_ADDR_WIDTH]),
        .writeAddr (DMEM_WB_writeAddr),
        .dataIn    (JUMP_WB_MUX_out),
        .dataOut0  (RF_dataOut0),
        .dataOut1  (RF_dataOut1)
    );
    
    
    

endmodule