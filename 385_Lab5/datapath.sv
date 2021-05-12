module datapath (input logic   Clk, Reset, Run, Continue,
										 
					  input logic   LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED,
					  input logic   GatePC, GateMDR, GateALU, GateMARMUX,
					  input logic   MIO_EN, DRMUX, SR1MUX, SR2MUX, ADDR1MUX, MARMUX,
					  input logic  [1: 0]   PCMUX, ADDR2MUX, ALUK,
					  input logic  [15:0]   Mem_Out,
					  
					  output logic BEN, 
					  output logic [9:0] LED,
					  output logic [15:0]   MAR, MDR, IR, PC_Out
						);
		logic [15:0] bus, Addr1, Addr2, PC_In, Add_Out, SR1_Out, SR2_Out, ALU_A, ALU_B, ALU_Out, MDR_In;
		logic [2:0] DR, SR1, SR2;
		logic N,Z,P, Ben_In;
						
		reg_16 reg_PC  (.*, .Load(LD_PC ), .Data_In(PC_In ), .Data_Out(PC_Out));
		reg_16 reg_MAR (.*, .Load(LD_MAR), .Data_In(bus   ), .Data_Out(MAR));
		reg_16 reg_MDR (.*, .Load(LD_MDR), .Data_In(MDR_In), .Data_Out(MDR));
		reg_16 reg_IR  (.*, .Load(LD_IR ), .Data_In(bus   ), .Data_Out(IR));
		
		register reg_N (.*, .Load(LD_CC), .In(ALU_Out[15] == 1), .Out(N));
		register reg_Z (.*, .Load(LD_CC), .In(ALU_Out == 16'd0), .Out(Z));
		register reg_P (.*, .Load(LD_CC), .In(ALU_Out[15] == 0 && ALU_Out != 16'd0), .Out(P));
		
		register reg_BEN (.*, .Load(LD_BEN), .In(Ben_In), .Out(BEN));
		
		reg_unit reg_FILE(.*, .Load(LD_REG), .Data_In(bus));
		
		assign ALU_A = SR1_Out;
		assign Add_Out = Addr1 + Addr2;
		assign SR2 = IR[2:0];
		assign Ben_In = (IR[11] & N) | (IR[10] & Z) | (IR[9] & P);
		assign LED = IR[9:0];
		
		always_comb
		begin
			if (GatePC)
				bus = PC_Out;
			else if (GateMDR)
				bus = MDR;
			else if (GateMARMUX)
				bus = Add_Out;
			else if (GateALU)
				bus = ALU_Out;
			else
				bus = 16'd0;
				
			unique case (ADDR1MUX)
				1'b0: Addr1 = PC_Out;
				1'b1: Addr1 = SR1_Out;
			endcase
			
			unique case (ADDR2MUX)
				2'b00: Addr2 = 0;
				2'b01: Addr2 = {{10{IR[ 5]}}, IR[ 5:0]};
				2'b10: Addr2 = {{ 7{IR[ 8]}}, IR[ 8:0]};
				2'b11: Addr2 = {{ 5{IR[10]}}, IR[10:0]};
			endcase
			
			unique case (PCMUX)
				2'b00: PC_In = PC_Out + 16'd1;
				2'b01: PC_In = bus;
				2'b10: PC_In = Add_Out;
				2'b11: PC_In = PC_Out;
			endcase
			
			unique case (SR1MUX)
				1'b0: SR1 = IR[11:9];
				1'b1: SR1 = IR[ 8:6];
			endcase
			
			unique case (SR2MUX)
				1'b0: ALU_B = SR2_Out;
				1'b1: ALU_B = {{11{IR[4]}}, IR[4:0]};
			endcase
			
			unique case (ALUK)
				2'b00: ALU_Out = ALU_A + ALU_B;
				2'b01: ALU_Out = ALU_A & ALU_B;
				2'b10: ALU_Out = ~ALU_A;
				2'b11: ALU_Out = ALU_A;
			endcase
			
			unique case (DRMUX)
				1'b0: DR = IR[11:9];
				1'b1: DR = 3'b111;
			endcase
			
			unique case (MIO_EN)
				1'b0: MDR_In = bus;
				1'b1: MDR_In = Mem_Out;
			endcase
			
		end
		

		
endmodule
