`include "../../common/src/rv32i_defs.sv"

module rf
#( // parameters
    localparam REGS = 1 << `RF_ADDR_WIDTH // 2^ADDR_WIDTH
) 
(
    input clk, regWrite,
    input [`RF_ADDR_WIDTH-1:0] read_addr0, read_addr1, write_addr,
    input [`WORD_WIDTH-1:0] data_in,
    output logic [`WORD_WIDTH-1:0] data_out0, data_out1
);

    // declare reg file array
    logic [`WORD_WIDTH-1:0] regs [0:REGS-1];

    // combinational read
    assign data_out0 = (read_addr0 != 0) ? regs[read_addr0] : 0;
    assign data_out1 = (read_addr1 != 0) ? regs[read_addr1] : 0;

    // synchronous write
    always @ (posedge clk) begin
        if (regWrite && (write_addr != 0)) regs[write_addr] <= data_in;
    end

endmodule