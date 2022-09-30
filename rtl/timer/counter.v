`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/19 14:44:12
// Design Name: 
// Module Name: counter
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
// 
//////////////////////////////////////////////////////////////////////////////////


module counter
(
input               clk,
input               rst_n,
output      [31:0]  counter_ns
);

parameter DELAY = 2;


reg [28:0]  counter;

always @(posedge clk or negedge rst_n)    
begin
  if (~rst_n)begin                           
        counter <=#DELAY 0;
  end                    
  else begin                 
        counter <=#DELAY counter+1;
  end
end

assign  counter_ns = (counter<<2)+counter; // counter_ns=counter*5

endmodule
