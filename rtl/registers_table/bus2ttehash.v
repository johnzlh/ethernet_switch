`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/30 20:01:18
// Design Name: 
// Module Name: bus2ttehash
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


module bus2ttehash(
input               clk,
input               rstn,
input   [119:0]     flow_mux,
input   [9:0]       hash_mux,
output  reg [119:0] flow,
output  reg [9:0]   hash,
output              hash_clear,
output              hash_update,
input               r_hash_clear,
input               r_hash_update,
input               reg_rst,
output  reg         ttehash_req,
input               ttehash_ack
);

parameter   DELAY = 2;

reg r_hash_clear_reg0;
reg r_hash_clear_reg1;
reg r_hash_update_reg0;
reg r_hash_update_reg1;

always@(posedge clk or negedge  rstn)begin
    if(~rstn) begin
        r_hash_clear_reg0 <=#DELAY 0;
        r_hash_clear_reg1 <=#DELAY 0;
        r_hash_update_reg0 <=#DELAY 0;
        r_hash_update_reg1 <=#DELAY 0;
    end
    else begin
        r_hash_clear_reg0 <=#DELAY r_hash_clear;
        r_hash_clear_reg1 <=#DELAY r_hash_clear_reg0;
        r_hash_update_reg0 <=#DELAY r_hash_update;
        r_hash_update_reg1 <=#DELAY r_hash_update_reg0;       
    end
end

assign  hash_clear = r_hash_clear_reg0 & (!r_hash_clear_reg1);
assign  hash_update = r_hash_update_reg0 & (!r_hash_update_reg1);

always@(posedge clk or negedge  rstn)begin
    if(~rstn) begin
        flow <=#DELAY 0;
        hash <=#DELAY 0;
    end
    else begin
        flow <=#DELAY flow_mux;
        hash <=#DELAY hash_mux; 
    end
end

always@(posedge clk or negedge  rstn)begin
    if(~rstn) begin
        ttehash_req <=#DELAY 0;
    end
    else if(reg_rst) begin
        ttehash_req <=#DELAY 1;
    end
    else if(ttehash_ack) begin
        ttehash_req <=#DELAY 0;
    end
end

endmodule
