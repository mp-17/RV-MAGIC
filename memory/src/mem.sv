/*  Simple synchronous memory
*/

`include "../../common/src/rv32i_defs.sv"

module memory 
#( // parameters
    ADDR_WIDTH = `ADDR_WIDTH, 
    WORD_WIDTH = `WORD_WIDTH,
    INIT_FILE = "pippo.txt", // must be in hex
    localparam ROWS = 1 << ADDR_WIDTH // 2^ADDR_WIDTH
) 
( // ports
    input clk, memRead, memWrite,
    input [ADDR_WIDTH-1:0] address,
    input [WORD_WIDTH-1:0] data_in,
    output logic [WORD_WIDTH-1:0] data_out    
);

    // declare memory array
    logic [WORD_WIDTH-1:0] mem_array [0:ROWS-1];

    // initialize memory by reading INIT_FILE
    initial begin
        $readmemh(INIT_FILE, mem_array);
    end

    // sync read/write
    always_ff @ (posedge clk) begin
        assert(~(memRead & memWrite))
            if (memRead) begin
            data_out <= mem_array[address];
            end
            else if (memWrite) begin
                mem_array[address] <= data_in;
            end
        else $error("Memory error: memRead and memWrite active at the same time.");
    end
endmodule