module ALU #(parameter DATA_WIDTH = 32) (a, b, ctl, out, zero);
    input signed [DATA_WIDTH - 1:0] a, b;
    input [3:0] ctl;
    output signed [DATA_WIDTH - 1:0] out;
    output zero;

    assign zero = (out == 0);  // assign zero output to 1 only if out is 0

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
        endcase
    end
endmodule

// TODO: add overflow flag
