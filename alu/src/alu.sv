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

module alu (
    input [`DATA_WIDTH - 1:0] a, b,
    input [`ALU_OP_WIDTH - 1:0] aluOp,
    output logic [`DATA_WIDTH - 1:0] out
);

    // decode aluOp input into different operations
    always_comb begin
        case (aluOp)
            // arithmetic ops
            `ALU_OP_ADD:    out = a + b;
            `ALU_OP_SUB:    out = a - b;
            // logic ops
            `ALU_OP_AND:    out = a & b;
            `ALU_OP_OR:     out = a | b;
            `ALU_OP_XOR:    out = a ^ b;
            `ALU_OP_SLL:    out = a << b[`SHAMT_WIDTH - 1:0];
            `ALU_OP_SRL:    out = a >> b[`SHAMT_WIDTH - 1:0];
            `ALU_OP_SRA:    out = $signed(a) >>> b[`SHAMT_WIDTH - 1:0];
            // set conditions
            `ALU_OP_SEQ:    out = a == b ? 1 : 0;
            `ALU_OP_SNE:    out = a != b ? 1 : 0;
            `ALU_OP_SLT:    out = $signed(a) < $signed(b) ? 1 : 0;
            `ALU_OP_SGE:    out = $signed(a) >= $signed(b) ? 1 : 0;
            `ALU_OP_SLTU:   out = a < b ? 1 : 0;
            `ALU_OP_SGEU:   out = a >= b ? 1 : 0;
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
