module uart_tx (Clk,Rst_n,TxEn,TxData,TxDone,Tx,Tick,NBits);	

input Clk, Rst_n, TxEn,Tick;	
input [3:0]NBits;		
input [7:0]TxData;		

output reg Tx;
output TxDone;


parameter  IDLE = 1'b0, WRITE = 1'b1;	
reg  State, Next;			
reg  TxDone = 1'b0;			
reg write_enable = 1'b0;				
reg start_bit = 1'b1;			
reg stop_bit = 1'b0;			
reg [4:0] Bit = 5'b00000;		
reg [1:0] counter = 2'b00;		
reg [7:0] in_data=8'b00000000;		
reg [1:0] R_edge;			
wire D_edge;				



always @ (posedge Clk or negedge Rst_n)			
begin
if (!Rst_n)	State <= IDLE;				//If reset pin is low, we get to the initial state which is IDLE
else 		State <= Next;				   //If not we go to the next state
end


always @ (State or TxData or TxDone or TxEn) 
begin
    case(State)	
	IDLE:	if(TxEn)		Next = WRITE;		      //If we are into IDLE and Tx gets activated, we start the WRITE process
		else			Next = IDLE;
	WRITE:	if(TxDone)		Next = IDLE;  		//If we are into WRITE and TxDone gets high, we get back to IDLE and wait
		else			Next = WRITE;
	default 			Next = IDLE;
    endcase
end


always @ (State)
begin
    case (State)
	WRITE: begin
		write_enable <= 1'b1;	//If we are in the WRITE state, we enable the write process
	end
	
	IDLE: begin
		write_enable <= 1'b0;	//If we are in the IDLE state, we disable the write process
	end
    endcase
end



always @ (posedge Tick)
begin

	if (write_enable)				   //if write_enable is activated, then we start counting and changing the Tx output
	begin
	counter <= counter+1;			//Increase the counter by one each positive edge of the Tick input
	
	
	if(start_bit & !stop_bit)		//We set the Tx to LOW (start bit) and pass the TxData input to the in data register
	begin
	Tx <=1'b0;					      //Create start bit  (low pulse)
	in_data <= TxData;				//Pass the data to be sent to the in_data register so we could use it
	end		

	if ((counter == 2'b11) & (start_bit) )	//If counter reaches 4, then we create the first bit and set "start_bit" to low
	begin		
	start_bit <= 1'b0;
	Tx <= in_data[0];             
	in_data <= {1'b0,in_data[7:1]};
	end


	if ((counter == 2'b11) & (!start_bit) &  (Bit < NBits-1))	//If we reach 4 once again, we make a loop for the next 7 bits (NBits-1)
	begin		
	in_data <= {1'b0,in_data[7:1]};
	Bit<=Bit+1;
	Tx <= in_data[0];
	start_bit <= 1'b0;
	counter <= 2'b00;     
	end	

	
	if ((counter == 2'b11) & (Bit == NBits-1) & (!stop_bit))	//We finish, so we set Tx to HIGH (Stop bit)
	begin
	Tx <= 1'b1;	
	counter <= 2'b00;	
	stop_bit<=1'b1;
	end

	if ((counter == 2'b11) & (Bit == NBits-1) & (stop_bit) )	//If stop bit was enabeled, than we reset the values and wait for next write process
	begin
	Bit <= 4'b0000;
	TxDone <= 1'b1;
	counter <= 2'b00;
	end
	
	end
		

end

endmodule
