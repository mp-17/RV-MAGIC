`timescale 1ns/1ns

module alu_tb();

    // signal declaration
    logic signed [31:0] a, b;
    logic [3:0] ctl;

    // module instantiation
    alu #(.DATA_WIDTH(32)) dut(
        .a(a),
        .b(b),
        .ctl(ctl)
    );

    initial begin
        ctl = 0;
        a = 95129849;
        b = 0;
        #10
        a = 32'hFFFFFFFF;
        b = 32'hAAAAAAAA;
        #10

        ctl = 1;
        a = 0;
        b = 32'hAAAAAAAA;
        #10

        ctl = 2;
        a = 32'hFFFFFFFF;
        b = 32'hAAAAAAAA;
        #10

        ctl = 3;
        a = 2348672;
        b = -9519;
        #10
        a = 32'h7FFFFFFF;
        b = 1;
        #10

        ctl = 4;
        a = 0;
        b = 3;
        #10

        ctl = 5;
        a = 32'hF;
        b = 2;
        #10
        a = 32'hF0000000;
        b = 1;
        #10

        ctl = 6;
        a = 32'hF;
        b = 4;
        #10
        a = 32'hF0000000;
        b = 3;
        #10

        ctl = 7;
        a = 32'hF;
        b = 4;
        #10
        a = 32'hF0000000;
        b = 3;
        #10

        ctl = 8;
        a = -1;
        b = 0;
        #10
        a = 5;
        b = -10;
        #10
        $stop;
    end
endmodule