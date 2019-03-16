`include "../../common/src/rv32i_defs.sv"

module rf
#( // parameters
    localparam REGS = 1 << `RF_ADDR_WIDTH // 2^ADDR_WIDTH
)
(
    input clk, regWrite,
    input [`RF_ADDR_WIDTH-1:0] readAddr0, readAddr1, writeAddr,
    input [`WORD_WIDTH-1:0] dataIn,
    output logic [`WORD_WIDTH-1:0] dataOut0, dataOut1
);

    // declare reg file array
    logic [`WORD_WIDTH-1:0] regs [0:REGS-1];

    // combinational read and bypass in case of simultaneous write
    always_comb begin
        if (!readAddr0) dataOut0 = 0;
        else if ((readAddr0 == writeAddr) && regWrite) dataOut0 = dataIn;
        else dataOut0 = regs[readAddr0];

        if (!readAddr1) dataOut1 = 0;
        else if ((readAddr1 == writeAddr) && regWrite) dataOut1 = dataIn;
        else dataOut1 = regs[readAddr1];
    end

    // synchronous write
    always @ (posedge clk) begin
        if (regWrite && (writeAddr != 0)) regs[writeAddr] <= dataIn;
    end

endmodule