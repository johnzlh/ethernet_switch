
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/19 15:50:49
// Design Name: 
// Module Name: tb_counter
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


`timescale  1ns / 1ps

module tb_counter;

// counter Parameters
parameter PERIOD = 5;
parameter DELAY  = 2;

// counter Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;

// counter Outputs
wire  [15:0]  counter_ns                   ;
wire  flag                                 ;


initial
begin
    forever #2.5  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

counter #(
    .DELAY ( DELAY ))
 u_counter (
    .clk                     ( clk                ),
    .rst_n                   ( rst_n              ),

    .counter_ns              ( counter_ns  [15:0] ),
    .flag                    ( flag               )
);


endmodule
