module register(clk, rst_n, clr, en, d, q);
	parameter NB = 32;
	input clk, rst_n, clr, en;
	input [NB-1:0] d;
	output logic [NB-1:0] q;

	always_ff @(posedge clk, negedge rst_n) begin
		if (rst_n == 0)
			q <= 0;
		else 
			if (clr == 1)
				q <= 0;
			else 
				if (en == 1)
					q <= d;
		end
endmodule