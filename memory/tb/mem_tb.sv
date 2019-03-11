`timescale 1ns/1ns
`define ADDR_WIDTH 7

module mem_tb ();

    // signal declarations
    logic clk, memRead, memWrite;
    logic [1:0] addrUnit;
    logic [`ADDR_WIDTH-1:0] address;
    logic [31:0] data;

    // module instantiation
    memory 
    #(
        .ADDR_WIDTH(`ADDR_WIDTH),
        .WORD_WIDTH(32),
        .INIT_FILE("../tb/init_mem.mem")
    )
    dut(
        .clk(clk),
        .memRead(memRead),
        .memWrite(memWrite),
        .addrUnit(addrUnit),
        .address(address),
        .dataIn(data)
    );

    // clock generator
    initial clk = 1;
    const integer T = 10;
    always #(T/2) clk = ~clk;

    // test signals
    initial begin
        // test read
        #T addrUnit = 'b00; memRead = 1; memWrite = 0; address = 'hA;
        #T addrUnit = 'b01; memRead = 1; memWrite = 0; address = 'hA;
        #T addrUnit = 'b10; memRead = 1; memWrite = 0; address = 'hA;
        // test write
        #T addrUnit = 'b00; memRead = 0; memWrite = 1; address = 'h3; data = 'hAABBCCDD;
        #T addrUnit = 'b10; memRead = 1; memWrite = 0; address = 'h3;
        #T addrUnit = 'b01; memRead = 0; memWrite = 1; address = 'h3; data = 'hAABBCCDD;
        #T addrUnit = 'b10; memRead = 1; memWrite = 0; address = 'h3;
        #T addrUnit = 'b10; memRead = 0; memWrite = 1; address = 'h3; data = 'hAABBCCDD;
        #T addrUnit = 'b10; memRead = 1; memWrite = 0; address = 'h3;
        // finish simulation
        #T $stop;
    end

endmodule