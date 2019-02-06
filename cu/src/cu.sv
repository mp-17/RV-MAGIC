package rv32i;
    aaa
endpackage

// this cu is only combinational since the memory part is supplied by the pipeline registers
// it simply takes all the codes from the current instruction and computes the corresponding output control signals
module cu (opcode, funct3, funct7, controls);
    output [] controls[]; // to be defined, first [] is the dimension of each element, second is number of elements
    input [] opcode;
    input [] funct3;
    input [] funct7;

    import rv32i;

    always_comb begin
        case(opcode)
            aa
        endcase
    end
endmodule
