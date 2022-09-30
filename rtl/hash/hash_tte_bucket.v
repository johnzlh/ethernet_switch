`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/29 15:01:48
// Design Name: 
// Module Name: hash_tte_bucket
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
//====================================================================
//entry structure:
//[15:0]:portmap
//[63:16]:dst mac
//[111:64]:src mac
//[119]:item valid
//=====================================================================
module hash_tte_bucket(
input               clk,
input               rstn,
//port se signals.
input       [47:0]  se_dmac,
input       [47:0]  se_smac, ///用于流表匹配时的源mac地址
input       [9:0]   se_hash,        
input               se_req,
output  reg         se_ack,
output  reg         se_nak,
output  reg [15:0]  se_result,
input               hash_clear, ///清空ram
input               hash_update, ////更新ram
input       [9:0]   hash,
input       [119:0] flow,
output  reg         reg_rst    ////插入流表成功后返回1
);
//======================================
//              main state.
//======================================

reg     [2:0]   state;
reg             clear_op;
reg             hit;
wire            item_valid;
//======================================
//              one cycle for state1.
//======================================
reg             count;

reg     [47:0]  hit_dmac;
reg     [47:0]  hit_smac;

reg             init;
reg                 ram_wr;
reg     [9:0]       ram_addr;     //input [9 : 0] addra
reg     [119:0]     ram_din;      //input [95 : 0] dina
wire    [119:0]     ram_dout;     //output [95 : 0] douta
reg     [119:0]     ram_dout_reg; //output [95 : 0] douta


parameter   HASH0 = 10'b0100101000;
parameter   DEST_MAC0 =48'h244bfe586128;
parameter   SOURCE_MAC0 = 48'h000ec657ff9d;
parameter   HASH_PORT0 = 16'b0001;
parameter   HASH_VALID0 = 8'b10000000;

always @(posedge clk or negedge rstn)
    if(!rstn) begin
        state <=#2 0;
        init <=#2 1;
        clear_op<=#2 1;
        ram_wr<=#2 0;
        ram_addr<=#2 0; 
        ram_din<=#2 0;     
        se_ack<=#2 0;
        se_nak<=#2 0;
        se_result<=#2 0;
        hit_dmac<=#2 0;
        hit_smac<=#2 0;
        count<=#2 0;
        reg_rst<=#2 0;
        end
    else begin
        ram_dout_reg<=#2 ram_dout;
        ram_wr<=#2 0;
        se_ack<=#2 0;
        se_nak<=#2 0;
        reg_rst<=#2 0;
        case(state)
            0:begin
                if(hash_clear | clear_op)begin
                    ram_addr<=#2 0;   
                    ram_wr<=#2 1;
                    ram_din<=#2 0;
                    state<=#2 6;    
                end
                else if(hash_update)begin
                    ram_addr<=#2 hash; 
                    ram_wr<=#2 1;
                    ram_din<=#2 flow; 
                    state<=#2 4; 
                end
                else if(se_req) begin
                    ram_addr<=#2 se_hash;
                    hit_dmac   <=#2 se_dmac;
                    hit_smac   <=#2 se_smac;
                    count     <=#2 0;
                    state   <=#2 1;
                end
                else if(init) begin
                    ram_addr<=#2 HASH0;   
                    ram_wr<=#2 1;
                    ram_din<=#2 {HASH_VALID0,SOURCE_MAC0,DEST_MAC0,HASH_PORT0};
                    state<=#2 7; 
                end
            end
            1:begin
                count <=#2 1;
                if(count) state<=#2 2;
            end
            2:begin
                state<=#2 3;
            end
            3:begin
                if(hit)begin
                    se_nak<=#2 0;
                    se_ack<=#2 1;
                    se_result<=#2 ram_dout_reg[15:0];
                end
                else begin
                    se_ack<=#2 0;
                    se_nak<=#2 1;
                end
                state<=#2 5;
            end
            4:begin
                reg_rst<=#2 1;
                state<=#2 0;
            end
            5:begin
                state<=#2 0;
            end
            6:begin
                if(ram_addr<10'h3ff) begin
                    ram_addr<=#2 ram_addr+1;
                    ram_wr<=#2 1;
                end
                else begin
                    ram_addr<=#2 0;
                    ram_wr<=#2 0;
                    clear_op<=#2 0;
                    reg_rst<=#2 1;
                    state<=#2 0;
                end
            end
            7:begin
                init <=#2 0;
                state<=#2 0;
            end
        endcase
    end 

always @(*)begin
    hit=(hit_dmac==ram_dout_reg[63:16])&(hit_smac==ram_dout_reg[111:64])&item_valid;                   
    end
assign item_valid=ram_dout_reg[119];


sram_w120_d1k u_sram_0 (
  .clka(clk),           // input clka
  .wea(ram_wr),       // input [0 : 0] wea
  .addra(ram_addr),   // input [9 : 0] addra
  .dina(ram_din),     // input [79 : 0] dina
  .douta(ram_dout)    // output [79 : 0] douta
);

endmodule
