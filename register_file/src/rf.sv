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

    // combinational read
    assign dataOut0 = (readAddr0 != 0) ? regs[readAddr0] : 0;
    assign dataOut1 = (readAddr1 != 0) ? regs[readAddr1] : 0;

    // synchronous write
    always @ (posedge clk) begin
        if (regWrite && (writeAddr != 0)) regs[writeAddr] <= dataIn;
    end

endmodule