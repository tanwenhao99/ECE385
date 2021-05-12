module reg_unit (input  logic Clk, Reset, Load,
					  input  logic [ 2:0] DR, SR1, SR2,
					  input  logic [15:0] Data_In,
                 output logic [15:0] SR1_Out, SR2_Out);
					  
		logic [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
		
		reg_16 reg_0 (.*, .Load(Load && DR == 3'b000), .Data_Out(R0));
		reg_16 reg_1 (.*, .Load(Load && DR == 3'b001), .Data_Out(R1));
		reg_16 reg_2 (.*, .Load(Load && DR == 3'b010), .Data_Out(R2));
      reg_16 reg_3 (.*, .Load(Load && DR == 3'b011), .Data_Out(R3));
		reg_16 reg_4 (.*, .Load(Load && DR == 3'b100), .Data_Out(R4));
		reg_16 reg_5 (.*, .Load(Load && DR == 3'b101), .Data_Out(R5));
		reg_16 reg_6 (.*, .Load(Load && DR == 3'b110), .Data_Out(R6));
		reg_16 reg_7 (.*, .Load(Load && DR == 3'b111), .Data_Out(R7));
		
		always_comb
		begin
			unique case (SR1)
				3'b000: SR1_Out = R0;
				3'b001: SR1_Out = R1;
				3'b010: SR1_Out = R2;
				3'b011: SR1_Out = R3;
				3'b100: SR1_Out = R4;
				3'b101: SR1_Out = R5;
				3'b110: SR1_Out = R6;
				3'b111: SR1_Out = R7;
			endcase
			
			unique case (SR2)
				3'b000: SR2_Out = R0;
				3'b001: SR2_Out = R1;
				3'b010: SR2_Out = R2;
				3'b011: SR2_Out = R3;
				3'b100: SR2_Out = R4;
				3'b101: SR2_Out = R5;
				3'b110: SR2_Out = R6;
				3'b111: SR2_Out = R7;
			endcase
			
		end

endmodule
