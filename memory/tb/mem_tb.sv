`timescale 1ns/1ns

module mem_tb ();

    // signal declarations
    logic clk, memRead, memWrite;
    logic [3:0] address;
    logic [31:0] data;

    // module instantiation
    memory 
    #(
        .ADDR_WIDTH(4),
        .WORD_WIDTH(32),
        .INIT_FILE("../tb/init_mem.mem")
    )
    dut(
        .clk(clk),
        .memRead(memRead),
        .memWrite(memWrite),
        .address(address),
        .data_in(data)
    );

    // clock generator
    initial clk = 1;
    const integer T = 10;
    always #(T/2) clk = ~clk;

    // test signals
    initial begin
        // test read
        #T memRead = 1; memWrite = 0; address = 'h0;
        #T memRead = 0; address = 'h1;
        #T memRead = 1; address = 'hA;
        // test write
        #T memRead = 0; memWrite = 1; address = 'h3; data = 1;
        #T memRead = 1; memWrite = 0;
        // out of range address on read
        #T address = 'h7F;
        // out of range address on write
        #T memRead = 0; memWrite = 1; address = 'h44; data = 0;
        // read/write confict
        #T memRead = 1; memWrite = 1; address = 'hF; data = 'hFFFF;
        #T memWrite = 0;
        // finish simulation
        #T $stop;
    end

endmodule