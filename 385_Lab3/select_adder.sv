module select_adder (
	input  [15:0] A, B,
	input         cin,
	output [15:0] S,
	output        cout
);

    /* TODO
     *
     * Insert code here to implement a CSA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  
	logic  [15:0] S0, S1;
	logic  c0, c1, c2, c3, c10, c11, c20, c21, c30, c31;
	assign S0[3:0] = S[3:0];
	assign S1[3:0] = S[3:0];
	  
	four_bit_ra FA0(.x(A[3 : 0]), .y(B[3 : 0]), .cin(cin ), .s(S [3 : 0]), .cout(c0 ));
	four_bit_ra FA1(.x(A[7 : 4]), .y(B[7 : 4]), .cin(1'b0), .s(S0[7 : 4]), .cout(c10));
	four_bit_ra FA2(.x(A[7 : 4]), .y(B[7 : 4]), .cin(1'b1), .s(S1[7 : 4]), .cout(c11));
	four_bit_ra FA3(.x(A[11: 8]), .y(B[11: 8]), .cin(1'b0), .s(S0[11: 8]), .cout(c20));
	four_bit_ra FA4(.x(A[11: 8]), .y(B[11: 8]), .cin(1'b1), .s(S1[11: 8]), .cout(c21));
	four_bit_ra FA5(.x(A[15:12]), .y(B[15:12]), .cin(1'b0), .s(S0[15:12]), .cout(c30));
	four_bit_ra FA6(.x(A[15:12]), .y(B[15:12]), .cin(1'b1), .s(S1[15:12]), .cout(c31));
	  
	always_comb
	begin
		unique case(c0)
			1'b0	:	begin
						S[7:4] = S0[7:4];
						c1 = c10;
						end
			1'b1	:	begin
						S[7:4] = S1[7:4];
						c1 = c11;
						end
		endcase
	end
	
	always_comb
	begin
		unique case(c1)
			1'b0	:	begin
						S[11:8] = S0[11:8];
						c2 = c20;
						end
			1'b1	:	begin
						S[11:8] = S1[11:8];
						c2 = c21;
						end
		endcase
	end
	
	always_comb
	begin
		unique case(c2)
			1'b0	:	begin
						S[15:12] = S0[15:12]; 
						cout = c30;
						end
			1'b1	:	begin
						S[15:12] = S1[15:12];
						cout = c31;
						end
		endcase
	end
	
endmodule
