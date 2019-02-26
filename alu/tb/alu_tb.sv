`include "../src/alu_defs.sv"
`timescale 1ns/1ns

module alu_tb();

    // signal declaration
    logic [31:0] a, b;
    logic [3:0] ctl;

    // module instantiation
    alu dut(
        .a(a),
        .b(b),
        .aluOp(ctl)
    );

    initial begin
        ctl = `ALU_OP_SNE;
        a = 43;
        b = 34872;
        #10

        $stop;
    end
endmodule