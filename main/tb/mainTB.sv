// RV-MAGIC main testbench //
//

`timescale 1ns/100ps

`include "../../common/src/rv32i_defs.sv"
`include "../../main/tb/mainTB_param.sv"

module main_tb;

	// TB main signals
	logic	clk,
			rst_n;

	// Instruction memory interface
	logic 	I_MEM_memRead,
			I_MEM_memWrite;
	logic [`MEMORY_MODE_WIDTH-1:0]	I_MEM_memMode;
	logic [`INST_WIDTH-1:0]	I_MEM_dataIn,
							I_MEM_dataOut;
	logic [`ADDR_WIDTH-1:0]	I_MEM_addr;

	// Data memory interface
	logic	D_MEM_memRead,
			D_MEM_memWrite;
	logic [`MEMORY_MODE_WIDTH-1:0]	D_MEM_memMode;
	logic [`INST_WIDTH-1:0]	D_MEM_dataIn,
							D_MEM_dataOut;
	logic [`ADDR_WIDTH-1:0]	D_MEM_addr;

	// clock generation
	initial clk = 1;
    const integer half_T_clk = `T_clk/2;
    always #(half_T_clk) clk = ~clk;

	// reset generation
	initial
		begin
			rst_n <= 0; #5
			rst_n <= 1;
		end 

	// IMEM fixed signals
	assign I_MEM_memWrite = 0;
	assign I_MEM_memMode = `WORD_MEMORY_MODE;
	assign I_MEM_dataIn = 0;

    // IMEM instantiation
    memory 
    #(
        .ADDR_WIDTH(`MEM_ADDR_WIDTH),
        .WORD_WIDTH(`WORD_WIDTH),
        .INIT_FILE(`INSTRUCTIONS_FILE)
    )
    IMEM(
        .clk(clk),
        .memRead(I_MEM_memRead),
        .memWrite(I_MEM_memWrite),
        .addrUnit(I_MEM_memMode),
        .address(I_MEM_addr[`MEM_ADDR_WIDTH-1:0]),
        .dataIn(I_MEM_dataIn),
        .dataOut(I_MEM_dataOut)
    );

    // DMEM instantiation
    memory 
    #(
        .ADDR_WIDTH(`MEM_ADDR_WIDTH),
        .WORD_WIDTH(`WORD_WIDTH),
        .INIT_FILE(`RANDOM_DATA_FILE)
    )
    DMEM(
        .clk(clk),
        .memRead(D_MEM_memRead),
        .memWrite(D_MEM_memWrite),
        .addrUnit(D_MEM_memMode),
        .address(D_MEM_addr[`MEM_ADDR_WIDTH-1:0]),
        .dataIn(D_MEM_dataIn),
        .dataOut(D_MEM_dataOut)
    );

    // DUV - Device Under Verification
    rvMagic
    DUV
    (
    	.clk(clk), 
    	.rst_n(rst_n),
    	.I_MEM_addr(I_MEM_addr),
    	.I_MEM_memRead(I_MEM_memRead),
    	.I_MEM_dataOut(I_MEM_dataOut),
    	.D_MEM_dataIn(D_MEM_dataIn),
    	.D_MEM_addr(D_MEM_addr),
    	.D_MEM_memRead(D_MEM_memRead), 
    	.D_MEM_memWrite(D_MEM_memWrite), 
    	.D_MEM_memMode(D_MEM_memMode),
    	.D_MEM_dataOut(D_MEM_dataOut)
	);

endmodule