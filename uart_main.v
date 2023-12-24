module uart_main(
    	Clk                     ,
    	Rst_n                   ,       
    	Tx                      ,
		TxData						,
	   RxData		            ,
	);


input           Clk             ; 
input           Rst_n           ; 
reg             Rx              ; 
output          Tx              ; 
output [7:0]    RxData          ; 
input [7:0]     TxData          ; 
wire          	 RxDone          ; // Reception completed. Data is valid.
wire          	 TxDone          ; // Trnasmission completed. Data sent.
wire            tick		        ; // Baud rate clock
wire          	 TxEn            ;
wire 		       RxEn		        ;
wire [3:0]      NBits    	     ;
wire [15:0]     BaudRate        ; 
assign 		RxEn = 1'b1	;
assign 		TxEn = 1'b1	;
assign 		BaudRate = 2'd2; 	
assign 		NBits = 4'b1000	;

always@(posedge tick)
Rx <= Tx;


uart_rx RX(
    	.Clk(Clk)             	,
   	.Rst_n(Rst_n)         	,
    	.RxEn(RxEn)           	,
    	.RxData(RxData)       	,
    	.RxDone(RxDone)       	,
    	.Rx(Rx)               	,
    	.Tick(tick)           	,
    	.NBits(NBits)
    );

uart_tx TX(
   	.Clk(Clk)            	,
    	.Rst_n(Rst_n)         	,
    	.TxEn(TxEn)           	,
    	.TxData(TxData)      	,
   	.TxDone(TxDone)      	,
   	.Tx(Tx)               	,
   	.Tick(tick)           	,
   	.NBits(NBits)
    );


uart_baud BAUDGEN(
    	.Clk(Clk)               ,
    	.Rst_n(Rst_n)           ,
    	.Tick(tick)             ,
    	.BaudRate(BaudRate)
    );

endmodule


/////////////Test Bench//////////////////

`timescale 1ns/1ns

module uart_tb;

	// Inputs
	reg Clk;
	reg Rst_n;
	reg [7:0] TxData;

	// Outputs
	wire Tx;
	wire [7:0] RxData;

	// Instantiate the module under test (MUT)
	uart_main uut (
		.Clk(Clk),
		.Rst_n(Rst_n),
		.Tx(Tx),
		.TxData(TxData),
		.RxData(RxData)
	);

	// Clock generator
	initial Clk = 0;
	always #5 Clk = ~Clk;
	
	// Reset generator
	initial begin
		Rst_n = 0;
		#10;
		Rst_n = 1;
	end

	// Test case 1 - Transmit data and receive it back
	initial begin
		// Initialize inputs
		TxData = 8'b01011101;		
	end

endmodule

