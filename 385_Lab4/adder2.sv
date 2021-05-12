module adder2 (input logic Clk, Reset, Run,
					input logic [7:0] SW,
					output logic [7:0] Aval, Bval,
					output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
					output logic Xval	 );

		// Declare temporary values used by other modules
		logic Load, Clear, Shift, Add, Sub, M, B_in;
		logic [8:0] S, sum;
		
		always_comb
		begin
			if (Shift)
			begin
				S[8:0] = 0;
			end
			else
			begin
				S[8:0] = {SW[7], SW[7:0]} ^ {9{Sub}};
			end
		end
		
		// Control unit allows the register to load once, and not during full duration of button press
		control control_unit( .Clk, .Reset(~Reset), .Run(~Run), .Clr_Ld(Load), .M(Bval[0]), .Clear, .Shift, .Add, .Sub);
		
		// Regist unit that holds value of one operator
		reg_8 reg_A(.Clk, .Reset(Load | Clear), .Shift_In(Xval), .Load(Add ^ Sub), .Shift_En(Shift), .D(sum[7:0]), .Shift_Out(B_in), .Data_Out(Aval[7:0]));
		reg_8 reg_B(.Clk, .Reset(0), .Shift_In(B_in), .Load(Load), .Shift_En(Shift), .D(SW[7:0]), .Data_Out(Bval[7:0]));
		reg_x reg_X(.Clk, .Reset(Load | Clear), .Shift_In(sum[8]), .Load(Add ^ Sub), .Shift_Out(Xval) );
		
		// Addition unit

		ripple_adder adder(.A({Aval[7], Aval[7:0]}), .B(S[8:0]), .cin(Sub), .S(sum[8:0]) );

		// Hex units that display contents of SW and register R in hex
		HexDriver		AHex0 (
								.In0(Bval[3:0]),
								.Out0(HEX0) );
								
		HexDriver		AHex1 (
								.In0(Bval[7:4]),
								.Out0(HEX1) );
								
		HexDriver		BHex0 (
								.In0(Aval[3:0]),
								.Out0(HEX2) );
								
		HexDriver		BHex1 (
								.In0(Aval[7:4]),
								.Out0(HEX3) );
								
		HexDriver		CHex0 (
								.In0(SW[3:0]),
								.Out0(HEX4) );
								
		HexDriver		CHex1 (
								.In0(SW[7:4]),
								.Out0(HEX5) );
														
		
		
endmodule