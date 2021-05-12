module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic Clk = 0;
logic Run, Continue;
logic [9:0] SW, LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
logic [15:0] PC, IR, MAR, MDR, HEX;
//enum logic State;

		
// Instantiating the DUT
// Make sure the module and signal names match with those in your design
slc3_testtop SLC3(.*);	

assign PC = SLC3.slc.PC_Out;
assign IR = SLC3.slc.IR;
assign MAR = SLC3.slc.MAR;
assign MDR = SLC3.slc.MDR;
assign HEX = SLC3.slc.memory_subsystem.hex_data;
//assign State = SLC3.slc.state_controller.State;

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
Continue = 0;		
SW = 10'h1A;
Run = 0;

#2 Run = 1;
Continue = 1;

#10 Run = 0;
#2 Run = 1;

#100 SW = 10'h33;
#2 Continue = 0;
#2 Continue = 1;

#100 SW = 10'h55;
#2 Continue = 0;
#2 Continue = 1;

	
end

endmodule
