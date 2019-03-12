/*  Hazard detection unit to stall the pipeline when a data hazard occurs
    between a load instruction and the following one (unless it is a store,
    for which forwarding logic accounts in the MEM stage).
    The "stall" output should be connected to:
        - PC enable (negated)
        - IF/ID pipe register enable (negated)
        - mux that selects EX, MEM and WB control signals, to set them
            all to 0 
*/

`include "../../common/src/rv32i_defs.sv"

module hdu (
    input [`RF_ADDR_WIDTH-1:0] ifidRs1, ifidRs2, idexRd,
    input ifidMemWrite, idexMemRead, branchOrJump,
    output stall, flush
);

    always_comb begin
        if (idexMemRead && (idexRd != 0) && !ifidMemWrite && ((idexRd == ifidRs1) || (idexRd == ifidRs2)))
            stall = 1; // stall pipeline
        else stall = 0;
    end

    assign flush = branchOrJump;

endmodule