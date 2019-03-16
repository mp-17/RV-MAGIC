/* Behavioural 3-way multiplexer.
   Parameter:
   - NB is the data width
*/

`include "../../common/src/rv32i_defs.sv"

module mux3(in0, in1, in2, sel, out);
   // Parameter
   parameter NB = `WORD_WIDTH; // data width

   // Ports
   input [NB-1:0] in0, in1, in2;
   input [1:0] sel;
   output logic [NB-1:0] out;

   // Mux it!
   always_comb begin
      case(sel)
         2'b00: out = in0;
         2'b01: out = in1;
         2'b10: out = in2;
         2'b11: $error("Select signal out of range (2'b11).");
         default: $warning("Select signal value out of {00, 01, 10, 11}");
      endcase
   end

endmodule