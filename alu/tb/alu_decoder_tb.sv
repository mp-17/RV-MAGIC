`timescale 1ns/1ns

module alu_decoder_tb();

    // signal declaration
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    // module instantiation
    alu_decoder dut(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7)
    );

    initial begin
        opcode = 'h33;
        funct3 = 0;
        funct7 = 0;
        #10

        opcode = 'h13;
        funct3 = 0;
        #10

        opcode = 'h3;
        funct3 = 0;
        #10

        opcode = 'h3;
        funct3 = 1;
        #10

        opcode = 'h3;
        funct3 = 2;
        #10

        opcode = 'h3;
        funct3 = 4;
        #10

        opcode = 'h3;
        funct3 = 5;
        #10

        opcode = 'h23;
        funct3 = 0;
        #10

        opcode = 'h23;
        funct3 = 1;
        #10

        opcode = 'h23;
        funct3 = 2;
        #10

        opcode = 'h33;
        funct3 = 0;
        funct7 = 'h20;
        #10

        opcode = 'h33;
        funct3 = 7;
        funct7 = 0;
        #10

        opcode = 'h13;
        funct3 = 7;
        #10

        opcode = 'h33;
        funct3 = 6;
        funct7 = 0;
        #10

        opcode = 'h13;
        funct3 = 6;
        #10

        opcode = 'h33;
        funct3 = 4;
        funct7 = 0;
        #10

        opcode = 'h13;
        funct3 = 4;
        #10

        opcode = 'h33;
        funct3 = 1;
        funct7 = 0;
        #10

        opcode = 'h13;
        funct3 = 1;
        funct7 = 0;
        #10

        opcode = 'h33;
        funct3 = 5;
        funct7 = 0;
        #10

        opcode = 'h13;
        funct3 = 5;
        funct7 = 0;
        #10

        opcode = 'h33;
        funct3 = 5;
        funct7 = 'h20;
        #10

        opcode = 'h13;
        funct3 = 5;
        funct7 = 'h20;
        #10

        opcode = 'h63;
        funct3 = 0;
        #10

        opcode = 'h63;
        funct3 = 1;
        #10

        opcode = 'h33;
        funct3 = 2;
        funct7 = 0;
        #10

        opcode = 'h13;
        funct3 = 2;
        #10

        opcode = 'h63;
        funct3 = 4;
        #10

        opcode = 'h63;
        funct3 = 5;
        #10

        opcode = 'h33;
        funct3 = 3;
        funct7 = 0;
        #10

        opcode = 'h13;
        funct3 = 3;
        #10

        opcode = 'h63;
        funct3 = 6;
        #10

        opcode = 'h63;
        funct3 = 7;
        #10

        $stop;
    end
endmodule