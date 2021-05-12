module AddRoundKey (
	input  logic [127:0] in, key,
	output logic [127:0] out
);

	assign out = in ^ key;

endmodule
