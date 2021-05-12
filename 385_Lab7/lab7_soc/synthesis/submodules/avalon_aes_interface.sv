/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
);

	logic [31:0] reg_unit[16];
	logic AES_START, AES_DONE;
	logic [127:0] AES_KEY, AES_MSG_ENC, AES_MSG_DEC;
	
	assign AES_START = reg_unit[14][0];
	assign AES_KEY = {reg_unit[0], reg_unit[1], reg_unit[2], reg_unit[3]};
	assign AES_MSG_ENC = {reg_unit[4], reg_unit[5], reg_unit[6], reg_unit[7]};

	AES mod_AES(.*);
	
	always_ff @ (posedge CLK)
   begin
	 	if (RESET) 
			reg_unit <= '{default:0};
		else if (AVL_CS && AVL_WRITE)
		begin
		   if (AVL_BYTE_EN[3])
				reg_unit[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24];
			if (AVL_BYTE_EN[2])
				reg_unit[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16];
			if (AVL_BYTE_EN[1])
				reg_unit[AVL_ADDR][15:8] <= AVL_WRITEDATA[15:8];
			if (AVL_BYTE_EN[0])
				reg_unit[AVL_ADDR][7:0] <= AVL_WRITEDATA[7:0];
		end
		else
		begin
			reg_unit[15][0] <= AES_DONE;
			reg_unit[8] <= AES_MSG_DEC[127:96];
			reg_unit[9] <= AES_MSG_DEC[95:64];
			reg_unit[10] <= AES_MSG_DEC[63:32];
			reg_unit[11] <= AES_MSG_DEC[31:0];
		end
	end
	
	always_comb
	begin
		if (AVL_CS && AVL_READ)
			AVL_READDATA = reg_unit[AVL_ADDR];
		else
			AVL_READDATA = 0;
		EXPORT_DATA[31:16] = reg_unit[0][31:16];
		EXPORT_DATA[7:0] = reg_unit[3][7:0];
	end

endmodule
