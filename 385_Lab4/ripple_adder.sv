module ripple_adder
(
	input  [8:0] A, B,
	input         cin,
	output [8:0] S,
	output        cout
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  
	logic c0, c1, c2;
	
	four_bit_ra   FA0(.x(A[3 : 0]), .y(B[3 : 0]), .cin(cin), .s(S[3 : 0]), .cout(c0));
	four_bit_ra   FA1(.x(A[7 : 4]), .y(B[7 : 4]), .cin(c0 ), .s(S[7 : 4]), .cout(c1));
	full_adder_ra FA2(.x(A[8])    , .y(B[8])    , .cin(c1 ), .s(S[8])    , .cout(cout));
     
endmodule

module four_bit_ra
(
	input 	[3:0] x, y,
	input 			cin,
	output 	[3:0] s,
	output 			cout
);

	logic c0, c1, c2;
	
	full_adder_ra fa0(.x(x[0]), .y(y[0]), .cin(cin), .s(s[0]), .cout(c0));
	full_adder_ra fa1(.x(x[1]), .y(y[1]), .cin(c0 ), .s(s[1]), .cout(c1));
	full_adder_ra fa2(.x(x[2]), .y(y[2]), .cin(c1 ), .s(s[2]), .cout(c2));
	full_adder_ra fa3(.x(x[3]), .y(y[3]), .cin(c2 ), .s(s[3]), .cout(cout));

endmodule

module full_adder_ra
(
	input 	x, y, cin,
	output 	s, cout
);

	assign s 	= x ^ y ^ cin;
	assign cout = (x & y) | (y & cin) | (x & cin);
	
endmodule
