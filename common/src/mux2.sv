/* Behavioural 2-way multiplexer.
   Parameter:
   - NB is the data width
*/

`include "../../common/src/rv32i_defs.sv"

module mux2(in0, in1, sel, out);
   // Parameter
   parameter NB = `WORD_WIDTH; // data width

   // Ports
   input [NB-1:0] in0, in1;
   input sel;
   output logic [NB-1:0] out;

   // Mux it!
   assign out = sel ? in1 : in0;

endmodule