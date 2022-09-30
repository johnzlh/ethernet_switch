`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/12 18:07:39
// Design Name: 
// Module Name: timer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// scale:1-20 secends in 200Mhz
//////////////////////////////////////////////////////////////////////////////////


module timer
#(
parameter REF_CLK = 200,        //reference clock frequency(MHz)
parameter TIME = 5,             // X second(s)
parameter INIT = 1              // X second(s)
)
(
input               clk,
input               rst_n,
output  reg         time_rst
);

parameter DELAY = 2;



//define the time counter
reg [31:0]      timer;     

wire    [31:0]  cycle;
assign  cycle = TIME*REF_CLK*1_000_000;
wire    [31:0]  init_value;
assign  init_value = INIT*REF_CLK*1_000_000;
//===========================================================================
// cycle counter:from 0 to Xsec
//===========================================================================
always @(posedge clk or negedge rst_n)    
begin
  if (~rst_n)begin                           
      timer <=#DELAY init_value;
      time_rst <=#DELAY 0; 
  end                    
  else if (timer == cycle)begin                 
      timer <=#DELAY 32'd0;                     //count done,clearing the time counter
      time_rst <=#DELAY 1;
  end
  else begin
      timer <=#DELAY timer + 1'b1;              //timer counter = timer counter + 1
      time_rst <=#DELAY 0;
  end
end

endmodule
