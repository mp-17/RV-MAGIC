/*  Hazard detection unit to stall the pipeline when a data hazard occurs
    between a load instruction and the following one (unless it is a store,
    for which forwarding logic accounts in the MEM stage).
    Outputs:
        stall_n:        asserted (active low) when fetching must be stalled
        flushIdEx:      asserted when a bubble must be inserted or when the 
                            previous instruction must be flushed
        flushIfIdExMem  asserted when previous instructions must be flushed
    Connections:
        stall_n -------------> PC enable
        stall_n -------------> IF/ID enable
        flushIdEx -----------> mux before ID/EX
        flushIfIdExMem ------> mux before IF/ID
        flushIfIdExMem ------> mux before EX/MEM
*/

`include "../../common/src/rv32i_defs.sv"

module hdu (
    input [`RF_ADDR_WIDTH-1:0] ifidRs1, ifidRs2, idexRd,
    input ifidMemWrite, idexMemRead, branchOrJump, enable,
    output logic stall_n, flushIdEx, flushIfIdExMem
);

    always_comb begin
        if (branchOrJump && enable) 
            {stall_n, flushIdEx, flushIfIdExMem} = 3'b111;
        else if ((idexMemRead && (idexRd != 0) && !ifidMemWrite && ((idexRd == ifidRs1) || (idexRd == ifidRs2))) && enable)
            {stall_n, flushIdEx, flushIfIdExMem} = 3'b010;
        else 
            {stall_n, flushIdEx, flushIfIdExMem} = 3'b100;
    end

endmodule