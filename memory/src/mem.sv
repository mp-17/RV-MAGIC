/*  Simple synchronous memory for simulation purposes only
    The signal addrUnit allows selection of addressable unit size, between:
        00: byte
        01: halfword (16 bit)
        10: word (32 bit)
    The address always refers to bytes.
    Remember that RISC-V is little endian so a word read will read bytes at:
        addr+3  addr+2  addr+1  addr
*/

`include "../../common/src/rv32i_defs.sv"
`define BYTE        2'b00
`define HALFWORD    2'b01
`define WORD        2'b10

module memory 
#( // parameters
    ADDR_WIDTH = `ADDR_WIDTH, 
    WORD_WIDTH = `WORD_WIDTH,
    INIT_FILE = "pippo.txt", // must be in hex
    localparam ROWS = 1 << ADDR_WIDTH // 2^ADDR_WIDTH
) 
( // ports
    input clk, memRead, memWrite,
    input [1:0] addrUnit,
    input [ADDR_WIDTH-1:0] address,
    input [WORD_WIDTH-1:0] dataIn,
    output logic [WORD_WIDTH-1:0] dataOut    
);

    // declare memory array (of bytes)
    logic [7:0] mem_array [0:ROWS-1]; 

    // initialize memory by reading INIT_FILE
    initial begin
        $readmemh(INIT_FILE, mem_array);
    end

    // sync read/write
    always_ff @ (posedge clk) begin
        assert(~(memRead & memWrite))
            if (memRead) begin
                case (addrUnit)
                    `BYTE: dataOut <= mem_array[address];
                    `HALFWORD: dataOut <= {mem_array[address+1], mem_array[address]};
                    `WORD: dataOut <= {mem_array[address+3], mem_array[address+2], mem_array[address+1], mem_array[address]};
                    default: $error("Invalid addressable unit specified.");
                endcase
            end
            else if (memWrite) begin
                case (addrUnit)
                    `BYTE: mem_array[address] <= dataIn[7:0];
                    `HALFWORD: {mem_array[address+1], mem_array[address]} <= dataIn[15:0];
                    `WORD: {mem_array[address+3], mem_array[address+2], mem_array[address+1], mem_array[address]} <= dataIn;
                    default: $error("Invalid addressable unit specified.");
                endcase
            end
        else $error("Memory error: memRead and memWrite active at the same time.");
    end
endmodule