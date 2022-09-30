`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/10 11:18:10
// Design Name: 
// Module Name: register
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
// reset:Active low
//////////////////////////////////////////////////////////////////////////////////


module register
#(
parameter   WIDTH = 16,
parameter   RESET_VALUE = 0
)
(
input               clk,
input               reset,
input               wr,
input   [WIDTH-1:0] din,
output  [WIDTH-1:0] dout
    );

reg     [WIDTH-1:0] Data;
assign dout = Data;

always@(posedge clk or negedge reset)
begin
    if(~reset)
    Data<= RESET_VALUE;
    else if(wr)
    Data<= din;
end
endmodule
