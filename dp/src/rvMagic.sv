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
    logic   HDU_stall_n,
            NEXT_ADDR_SEL_CU_jumpOrBranch; 
    logic [`ADDR_WIDTH-1:0] NEXT_PC_MUX_out, 
                            PC_q, 
                            NEXT_PC_ADDER_out,
                            BRJAL_JALR_MUX_out,
                            IF_ID_pc,
                            IF_ID_nextPc;


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
        .d     ({NEXT_PC_ADDER_out, PC_q}),
        .q     ({IF_ID_nextPc, IF_ID_pc})
    );

    // I_MEM interface
    assign I_MEM_memRead = HDU_stall_n;
    assign I_MEM_dataIn = PC_q;
    
    

endmodule