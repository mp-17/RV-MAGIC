/*  Parametric ALU with 4 bit control input,
    zero and overflow outputs */

module alu #(parameter DATA_WIDTH = 32) (
    input signed [DATA_WIDTH - 1:0] a, b,
    input [3:0] ctl,
    output logic signed [DATA_WIDTH - 1:0] out,
    output logic zero,
    output logic ovf
);

    assign zero = (out == 0);  // assign zero output to 1 only if out is 0
    
    // overflow logic (check sign of operands and result)
    always_comb begin
        if (ctl == 3) begin
            ovf = (a[$left(a)] & b[$left(b)] & ~out[$left(out)]) |
                (~a[$left(a)] & ~b[$left(b)] & out[$left(out)]);
        end
        else if (ctl == 4) begin
            ovf = (a[$left(a)] & ~b[$left(b)] & ~out[$left(out)]) |
                (~a[$left(a)] & b[$left(b)] & out[$left(out)]);
        end
        else begin
            ovf = 0;
        end
    end

    // decode ctl input into different operations
    always_comb begin
        case (ctl)
            0: out = a & b;             // ctl = 4'b0000 -> AND
            1: out = a | b;             // ctl = 4'b0001 -> OR
            2: out = a ^ b;             // ctl = 4'b0010 -> XOR
            3: out = a + b;             // ctl = 4'b0011 -> add
            4: out = a - b;             // ctl = 4'b0100 -> subtract
            5: out = a << b;            // ctl = 4'b0101 -> shift left
            6: out = a >> b;            // ctl = 4'b0110 -> shift right
            7: out = a >>> b;           // ctl = 4'b0111 -> shift right sign ext
            8: out = a < b ? 1 : 0;     // ctl = 4'b1000 -> set less than
            default: out = 0;           // default case sets out to zero
        endcase
    end
endmodule
