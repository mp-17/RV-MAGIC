`include "../../common/src/rv32i_defs.sv"

module reg_file
#( // parameters
    ADDR_WIDTH = 5, 
    WORD_WIDTH = `WORD_WIDTH,
    localparam REGS = 1 << ADDR_WIDTH // 2^ADDR_WIDTH
) 
(
    input clk, regWrite,
    input [ADDR_WIDTH-1:0] read_addr0, read_addr1, write_addr,
    input [WORD_WIDTH-1:0] data_in,
    output logic [WORD_WIDTH-1:0] data_out0, data_out1
);

    // declare reg file array
    logic [WORD_WIDTH-1:0] regs [0:REGS-1];

    // combinational read
    assign data_out0 = regs[read_addr0];
    assign data_out1 = regs[read_addr1];

    // synchronous write
    always @ (posedge clk) begin
        if (regWrite) regs[write_addr] <= data_in;
    end

endmodule