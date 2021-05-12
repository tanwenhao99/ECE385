/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);
	logic [3:0] Count, Next_count, PauseCount, Next_pause;
	logic [127:0] Bus, Shift_Out, SubByte_Out, RoundKey_Out, RoundKey_In;
	logic [1407:0] ExpandedKey; 
	logic [31:0] MixCol_In, MixCol_Out;
	
	enum logic [3:0] { Wait, Pause, RoundKey, Shift, SubByte, MixCol_1, MixCol_2, MixCol_3, MixCol_4, Done} State, Next_state;

	
	reg_128 reg128(.Clk(CLK), .Reset(RESET && State == Wait), .Load(AES_START && ~AES_DONE), .Data_In(Bus), .Data_Out(AES_MSG_DEC));
		
	KeyExpansion mod_Expand(.clk(CLK), .Cipherkey(AES_KEY), .KeySchedule(ExpandedKey));
	
	InvShiftRows mod_Shift(.data_in(AES_MSG_DEC), .data_out(Shift_Out));
	
	AddRoundKey mod_RoundKey(.in(AES_MSG_DEC), .key(RoundKey_In), .out(RoundKey_Out));
	
	InvMixColumns mod_MixCol(.in(MixCol_In), .out(MixCol_Out));
	
	InvSubBytes S1 (.clk(CLK), .in(AES_MSG_DEC[127:120]), .out(SubByte_Out[127:120]));
	InvSubBytes S2 (.clk(CLK), .in(AES_MSG_DEC[119:112]), .out(SubByte_Out[119:112]));
	InvSubBytes S3 (.clk(CLK), .in(AES_MSG_DEC[111:104]), .out(SubByte_Out[111:104]));
	InvSubBytes S4 (.clk(CLK), .in(AES_MSG_DEC[103:96]),  .out(SubByte_Out[103:96]));
	InvSubBytes S5 (.clk(CLK), .in(AES_MSG_DEC[95:88]),   .out(SubByte_Out[95:88]));
	InvSubBytes S6 (.clk(CLK), .in(AES_MSG_DEC[87:80]),   .out(SubByte_Out[87:80]));
	InvSubBytes S7 (.clk(CLK), .in(AES_MSG_DEC[79:72]),   .out(SubByte_Out[79:72]));
	InvSubBytes S8 (.clk(CLK), .in(AES_MSG_DEC[71:64]),   .out(SubByte_Out[71:64]));
	InvSubBytes S9 (.clk(CLK), .in(AES_MSG_DEC[63:56]),   .out(SubByte_Out[63:56]));
	InvSubBytes S10(.clk(CLK), .in(AES_MSG_DEC[55:48]),   .out(SubByte_Out[55:48]));
	InvSubBytes S11(.clk(CLK), .in(AES_MSG_DEC[47:40]),   .out(SubByte_Out[47:40]));
	InvSubBytes S12(.clk(CLK), .in(AES_MSG_DEC[39:32]),   .out(SubByte_Out[39:32]));
	InvSubBytes S13(.clk(CLK), .in(AES_MSG_DEC[31:24]),   .out(SubByte_Out[31:24]));
	InvSubBytes S14(.clk(CLK), .in(AES_MSG_DEC[23:16]),   .out(SubByte_Out[23:16]));
	InvSubBytes S15(.clk(CLK), .in(AES_MSG_DEC[15:8]),    .out(SubByte_Out[15:8]));
	InvSubBytes S16(.clk(CLK), .in(AES_MSG_DEC[7:0]),     .out(SubByte_Out[7:0]));
	
	always_ff @ (posedge CLK)
   begin
	 	if (RESET)
		begin
			State <= Wait;
			Count <= 0;
			PauseCount <= 0;
		end
		else
		begin
			State <= Next_state;
			Count <= Next_count;
			PauseCount <= Next_pause;
		end
	end
			
	always_comb
	begin
		Next_state = State;
		Next_count = Count;
		Next_pause = PauseCount;
		Bus = AES_MSG_ENC;
		AES_DONE = 0;
		MixCol_In = 0;
		
		unique case (State)
			Wait:
				if (AES_START)
				begin
					Next_count = 0;
					Next_pause = 0;
					Next_state = Pause;
				end
			Pause:
				if (PauseCount == 4'd10)
					Next_state = RoundKey;
				else
				begin
					Next_state = Pause;
					Next_pause = PauseCount + 1;
				end
			RoundKey:
				if (Count == 4'd0)
				begin
					Next_state = Shift;
					Next_count = Count + 1;
				end
				else if (Count == 4'd10)
					Next_state = Done;
				else
				begin
					Next_state = MixCol_1;
					Next_count = Count + 1;
				end
			Shift:
				Next_state = SubByte;
			SubByte:
				Next_state = RoundKey;
			MixCol_1:
				Next_state = MixCol_2;
			MixCol_2:
				Next_state = MixCol_3;
			MixCol_3:
				Next_state = MixCol_4;
			MixCol_4:
				Next_state = Shift;
			Done:
				if (~AES_START)
					Next_state = Wait;
					
		endcase
		
		case (State)
			RoundKey:
				Bus = RoundKey_Out;
			Shift:
				Bus = Shift_Out;
			SubByte:
				Bus = SubByte_Out;
			MixCol_1:
				begin
					MixCol_In = AES_MSG_DEC[127:96];
					Bus[127:96] = MixCol_Out;
					Bus[95:0] = AES_MSG_DEC[95:0];
				end
			MixCol_2:
				begin
					MixCol_In = AES_MSG_DEC[95:64];
					Bus[95:64] = MixCol_Out;
					Bus[127:96] = AES_MSG_DEC[127:96];
					Bus[63:0] = AES_MSG_DEC[63:0];
				end
			MixCol_3:
				begin
					MixCol_In = AES_MSG_DEC[63:32];
					Bus[63:32] = MixCol_Out;
					Bus[127:64] = AES_MSG_DEC[127:64];
					Bus[31:0] = AES_MSG_DEC[31:0];
				end
			MixCol_4:
				begin
					MixCol_In = AES_MSG_DEC[31:0];
					Bus[31:0] = MixCol_Out;
					Bus[127:32] = AES_MSG_DEC[127:32];
				end
			Done:
				AES_DONE = 1;
			default: ;
			
		endcase
		
		if (Count == 10)
			RoundKey_In = ExpandedKey[128*11-1:128*10];
		else if (Count == 9)
			RoundKey_In = ExpandedKey[128*10-1:128*9];
		else if (Count == 8)
			RoundKey_In = ExpandedKey[128*9-1:128*8];
		else if (Count == 7)
			RoundKey_In = ExpandedKey[128*8-1:128*7];
		else if (Count == 6)
			RoundKey_In = ExpandedKey[128*7-1:128*6];
		else if (Count == 5)
			RoundKey_In = ExpandedKey[128*6-1:128*5];
		else if (Count == 4)
			RoundKey_In = ExpandedKey[128*5-1:128*4];
		else if (Count == 3)
			RoundKey_In = ExpandedKey[128*4-1:128*3];
		else if (Count == 2)
			RoundKey_In = ExpandedKey[128*3-1:128*2];
		else if (Count == 1)
			RoundKey_In = ExpandedKey[128*2-1:128*1];
		else if (Count == 0)
			RoundKey_In = ExpandedKey[128*1-1:128*0];
		else
			RoundKey_In = 0;
		
	end
		

endmodule

module reg_128 (input  logic Clk, Reset, Load, 
               input  logic [127:0] Data_In,
               output logic [127:0] Data_Out);

    always_ff @ (posedge Clk)
    begin
	 	 if (Reset) 
			  Data_Out <= 0;
		 else if (Load)
			  Data_Out <= Data_In;
    end

endmodule	
