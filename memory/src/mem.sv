/*  Simple synchronous memory
*/

module memory 
#( // parameters
    ADDR_WIDTH = 32, 
    WORD_WIDTH = 32,
    localparam ROWS = 1 << ADDR_WIDTH // 2^ADDR_WIDTH
) 
( // ports
    input clk, memRead, memWrite,
    input [ADDR_WIDTH-1:0] address,
    input [WORD_WIDTH-1:0] data_in,
    output [WORD_WIDTH-1:0] data_out    
);

    // declare memory array
    logic [WORD_WIDTH-1:0] mem_array [0:ROWS-1];

    // sync read/write
    always_ff @ (posedge clk) begin
        case ({memRead, memWrite})
            2'b00: data_out <= x;
            2'b10: data_out <= mem_array[address];
            2'b01: mem_array[address] <= data_in;
            2'b11: $display("Memory error: memRead and memWrite active at the same time.")
            default: $display("Memory error: unknown value of control signals.")
        endcase
endmodule