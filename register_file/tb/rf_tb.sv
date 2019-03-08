`timescale 1ns/1ns

module rf_tb ();

    // signal declarations
    logic clk, regWrite;
    logic [4:0] readAddr0, readAddr1, writeAddr;
    logic [31:0] dataIn;
    logic [31:0] dataOut0, dataOut1;

    // module instantiation
    rf u_rf(
    	.clk       (clk       ),
        .regWrite  (regWrite  ),
        .readAddr0 (readAddr0 ),
        .readAddr1 (readAddr1 ),
        .writeAddr (writeAddr ),
        .dataIn    (dataIn    ),
        .dataOut0  (dataOut0  ),
        .dataOut1  (dataOut1  )
    );
    
    // clock generator
    initial clk = 1;
    const integer T = 10;
    always #(T/2) clk = ~clk;

    // test signals
    initial begin
        // write some values
        #T regWrite = 1; writeAddr = 5; dataIn = 879;
        #T regWrite = 1; writeAddr = 2; dataIn = 512;
        #T regWrite = 1; writeAddr = 23; dataIn = 6549;
        // read some values
        #T regWrite = 0; readAddr0 = 2; readAddr1 = 23;
        // simultaneous read and write
        #T regWrite = 1; writeAddr = 5; dataIn = 36; readAddr0 = 5;
        // finish simulation
        #T $stop;
    end

endmodule