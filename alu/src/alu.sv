/*  Parametric ALU with 4 bit control input.
    Flags could be added:  
        Z (zero), set if out is 0
        N (negative), set if out is negative (MSB = 1)
        V (overflow), set if the result is wrong due to signed overflow
        C (carry), set if out is greater than bus width (unsigned)
    The external control can compute branch conditions from those flags, 
    after subtracting, as follows:
        EQ = Z
        LT = N ^ V
        GE = ~(N ^ V)
        LTU = ~C
        GEU = C
    However, since the flags themselves are useless, the outcome of the
    comparisons is just written in the result.
*/

`include "alu_defs.sv"
`include "../../common/src/rv32i_defs.sv"

module alu (
    input [`WORD_WIDTH - 1:0] a, b,
    input [`ALU_CTL_WIDTH - 1:0] ctl,
    output logic [`WORD_WIDTH - 1:0] out
);

    // decode ctl input into different operations
    always_comb begin
        case (ctl)
            // arithmetic ops
            `ALU_ADD:    out = a + b;
            `ALU_SUB:    out = a - b;
            // logic ops
            `ALU_AND:    out = a & b;
            `ALU_OR:     out = a | b;
            `ALU_XOR:    out = a ^ b;
            `ALU_SLL:    out = a << b[`SHAMT_WIDTH - 1:0];
            `ALU_SRL:    out = a >> b[`SHAMT_WIDTH - 1:0];
            `ALU_SRA:    out = $signed(a) >>> b[`SHAMT_WIDTH - 1:0];
            // set conditions
            `ALU_SEQ:    out = a == b ? 1 : 0;
            `ALU_SNE:    out = a != b ? 1 : 0;
            `ALU_SLT:    out = $signed(a) < $signed(b) ? 1 : 0;
            `ALU_SGE:    out = $signed(a) >= $signed(b) ? 1 : 0;
            `ALU_SLTU:   out = a < b ? 1 : 0;
            `ALU_SGEU:   out = a >= b ? 1 : 0;
            // default case sets out to zero (should be unreachable)
            default: out = 0; 
        endcase
    end

/*
    // assign flags
    assign Z = (out == 0);  // assign zero output to 1 only if out is 0
    assign N = out[$left(out)]; // assign negative flag if MSB of out is 1
    
    // overflow logic (check sign of operands and result)
    always_comb begin
        if (ctl == 3) begin
            V = (a[$left(a)] & b[$left(b)] & ~out[$left(out)]) |
                (~a[$left(a)] & ~b[$left(b)] & out[$left(out)]);
        end
        else if (ctl == 4) begin
            V = (a[$left(a)] & ~b[$left(b)] & ~out[$left(out)]) |
                (~a[$left(a)] & b[$left(b)] & out[$left(out)]);
        end
        else begin
            V = 0;
        end
    end
*/
endmodule
