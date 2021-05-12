module register (input  logic Clk, Reset, Load, In,
                 output logic Out);
					  
    always_ff @ (posedge Clk)
    begin
	 	 if (Reset) 
			  Out <= 1'b0;
		 else if (Load)
			  Out <= In;
	 end

endmodule

module reg_16 (input  logic Clk, Reset, Load, 
               input  logic [15:0] Data_In,
               output logic [15:0] Data_Out);

    always_ff @ (posedge Clk)
    begin
	 	 if (Reset) 
			  Data_Out <= 16'd0;
		 else if (Load)
			  Data_Out <= Data_In;
    end

endmodule
