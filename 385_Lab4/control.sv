//Two-always example for state machine

module control (input  logic Clk, Reset, Run, M,
                output logic Clr_Ld, Clear, Shift, Add, Sub );

    
    enum logic [4:0] {A, A1, B1, B, C1, C, D1, D, E1, E, F1, F, G1, G, H1, H, I1, I, J}   curr_state, next_state; 

	//updates flip flop, current state is the only one
    always_ff @ (posedge Clk)  
    begin
        if (Reset)
            curr_state <= A;
        else 
            curr_state <= next_state;
    end

    // Assign outputs based on state
	always_comb
    begin
        
		  next_state  = curr_state;	
        unique case (curr_state) 

            A :    if (Run)
							  next_state = A1;
				A1:    next_state = B1;
            B1:    next_state = B;
				B :    next_state = C1;
            C1:    next_state = C;
				C :    next_state = D1;
				D1:    next_state = D;
				D :    next_state = E1;
				E1:    next_state = E;
				E :    next_state = F1;
				F1:    next_state = F;
				F :    next_state = G1;
				G1:    next_state = G;
				G :    next_state = H1;
				H1:    next_state = H;
				H :    next_state = I1;
				I1:    next_state = I;
				I :    next_state = J;
            J :    if (~Run) 
                       next_state = A;
							  
        endcase
   
		  // Assign outputs based on ‘state’
        case (curr_state) 
	   	   A: 
	         begin
                Clr_Ld = Reset;
					 Clear = 0;
                Shift  = 0;
					 Add = 0;
					 Sub = 0;
		      end
	   	   A1: 
	         begin
                Clr_Ld = 0;
					 Clear = 1;
                Shift  = 0;
					 Add = 0;
					 Sub = 0;
		      end
				J: 
		      begin
                Clr_Ld = 0;
					 Clear = 0;
                Shift  = 0;
					 Add = 0;
					 Sub = 0;
		      end
				I1:
				begin
					 Clr_Ld = 0;
					 Clear = 0;
                Shift  = 0;
					 Add = 0;
					 Sub = M;
				end
	   	   B1, C1, D1, E1, F1, G1, H1: 
		      begin 
                Clr_Ld = 0;
					 Clear = 0;
                Shift  = 0;
					 Add = M;
					 Sub = 0;
		      end
				B, C, D, E, F, G, H, I:
				begin
				    Clr_Ld = 0;
					 Clear = 0;
                Shift  = 1;
					 Add = 0;
					 Sub = 0;
				end
        endcase
    end

endmodule
