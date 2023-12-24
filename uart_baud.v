module uart_baud(
    Clk                   ,
    Rst_n                 ,
    Tick                  ,
    BaudRate
    );

input           Clk                 ; // Clock input
input           Rst_n               ; // Reset input
input [15:0]    BaudRate            ; // Value to divide the generator by
output          Tick                ; // Each "BaudRate" pulses we create a tick pulse
reg [15:0]      baudRateReg = 16'd1 ; // Register used to count


always @(posedge Clk or negedge Rst_n)
	 begin
    if (!Rst_n) 
	 baudRateReg <= 16'b1;
    else if (Tick) 
	 baudRateReg <= 16'b1;
    else baudRateReg <= baudRateReg + 1'b1;
	 end
assign Tick = (baudRateReg == BaudRate);
endmodule
