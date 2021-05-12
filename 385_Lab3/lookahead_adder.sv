module lookahead_adder (
	input  [15:0] A, B,
	input         cin,
	output [15:0] S,
	output        cout
);
    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  
	logic [3:0] gg, pg;
	logic c1, c2, c3;
	
	assign c1 = cin & pg[0] | gg[0];
	assign c2 = cin & pg[0] & pg[1] | gg[0] & pg[1] | gg[1];
	assign c3 = cin & pg[0] & pg[1] & pg[2] | gg[0] & pg[1] & pg[2] | gg[1] & pg[2] | gg[2];
	assign cout = cin & pg[0] & pg[1] & pg[2] & pg[3] | gg[0] & pg[1] & pg[2] & pg[3] | gg[1] & pg[2] & pg[3] | gg[2] & pg[3] | gg[3];

	four_bit_la FA0(.x(A[3 : 0]), .y(B[3 : 0]), .cin(cin), .s(S[3 : 0]), .gg(gg[0]), .pg(pg[0]));
	four_bit_la FA1(.x(A[7 : 4]), .y(B[7 : 4]), .cin(c1 ), .s(S[7 : 4]), .gg(gg[1]), .pg(pg[1]));
	four_bit_la FA2(.x(A[11: 8]), .y(B[11: 8]), .cin(c2 ), .s(S[11: 8]), .gg(gg[2]), .pg(pg[2]));
	four_bit_la FA3(.x(A[15:12]), .y(B[15:12]), .cin(c3 ), .s(S[15:12]), .gg(gg[3]), .pg(pg[3]));

endmodule

module four_bit_la
(
	input 	[3:0] x, y,
	input 			cin,
	output 	[3:0] s, 
	output 			cout, gg, pg
);

	logic [3:0] g, p;
	logic c1, c2, c3;
	
	assign c1 = cin & p[0] | g[0];
	assign c2 = cin & p[0] & p[1] | g[0] & p[1] | g[1];
	assign c3 = cin & p[0] & p[1] & p[2] | g[0] & p[1] & p[2] | g[1] & p[2] | g[2];
	assign cout = cin & p[0] & p[1] & p[2] & p[3] | g[0] & p[1] & p[2] & p[3] | g[1] & p[2] & p[3] | g[2] & p[3] | g[3];
	assign gg = g[3] | g[2] & p[3] | g[1] & p[3] & p[2] | g[0] & p[3] & p[2] & p[1];
	assign pg = p[0] & p[1] & p[2] & p[3];
	
	full_adder_la fa0(.x(x[0]), .y(y[0]), .cin(cin), .s(s[0]), .g(g[0]), .p(p[0]));
	full_adder_la fa1(.x(x[1]), .y(y[1]), .cin(c1 ), .s(s[1]), .g(g[1]), .p(p[1]));
	full_adder_la fa2(.x(x[2]), .y(y[2]), .cin(c2 ), .s(s[2]), .g(g[2]), .p(p[2]));
	full_adder_la fa3(.x(x[3]), .y(y[3]), .cin(c3 ), .s(s[3]), .g(g[3]), .p(p[3]));
	

endmodule

module full_adder_la
(
	input 	x, y, cin,
	output 	s, g, p
);

	assign s = x ^ y ^ cin;
	assign g = x & y;
	assign p = x ^ y;
	
endmodule
