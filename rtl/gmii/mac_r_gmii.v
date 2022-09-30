`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/11 16:43:39
// Design Name: 
// Module Name: mac_r_gmii
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


module mac_r_gmii_n(
input               rstn,
input               clk,

input               rx_clk,
input               rx_dv,
input       [7:0]   gm_rx_d,
output              gtx_clk,

input       [1:0]   speed,  //ethernet speed 00:10M 01:100M 10:1000M

input               data_fifo_rd,
output      [7:0]   data_fifo_dout,
input               ptr_fifo_rd, 
output      [15:0]  ptr_fifo_dout,
output              ptr_fifo_empty
    );

parameter DELAY=2;  
parameter CRC_RESULT_VALUE=32'hc704dd7b;

assign  gtx_clk = rx_clk & speed[1];
//============================================  
//generte a pipeline of input gm_rx_d.   
//============================================  
reg     [7:0]  rx_d_reg;
always @(posedge rx_clk or negedge rstn)
    if(!rstn)begin
        rx_d_reg<=#DELAY 0;
        end
    else if(speed[1])begin
        rx_d_reg<=#DELAY gm_rx_d;
        end
    else begin
        rx_d_reg<=#DELAY 0;
        end
//============================================  
//generte a pipeline of input m_rx_d.   
//============================================  
reg     [3:0]	rx_d_reg0;
reg     [3:0]   rx_d_reg1;
always @(posedge rx_clk or negedge rstn)
    if(!rstn)begin
        rx_d_reg0<=#DELAY 0;
        rx_d_reg1<=#DELAY 0;
        end
    else if(!speed[1])begin
        rx_d_reg0<=#DELAY gm_rx_d;
        rx_d_reg1<=#DELAY rx_d_reg0;        
        end
    else begin
        rx_d_reg0<=#DELAY 0;
        rx_d_reg1<=#DELAY 0;
        end
//============================================  
//generte a pipeline of input rx_dv.   
//============================================  
reg             rx_dv_reg0;
reg             rx_dv_reg1;
always @(posedge rx_clk or negedge rstn)
    if(!rstn)begin
        rx_dv_reg0<=#DELAY 0;
        rx_dv_reg1<=#DELAY 0;
        end
    else begin
        rx_dv_reg0<=#DELAY rx_dv;
        rx_dv_reg1<=#DELAY rx_dv_reg0;
        end
//============================================  
//generte internal control signals. 
//============================================  
wire dv_sof;
wire dv_eof;
wire sfd;
assign  dv_sof=rx_dv_reg0  & !rx_dv_reg1;
assign  dv_eof=!rx_dv_reg0 &  rx_dv_reg1;
assign  sfd=rx_dv_reg0  & ((rx_d_reg==8'b11010101) | (rx_d_reg0==4'b1101));

wire    nib_cnt_clr;
reg     [11:0]  nib_cnt;
always @(posedge rx_clk  or negedge rstn)
    if(!rstn)nib_cnt<=#DELAY 0;
    else if(nib_cnt_clr) nib_cnt<=#DELAY 0; 
    else nib_cnt<=#DELAY nib_cnt+1; 

wire    byte_dv;
assign  byte_dv=nib_cnt[0] | speed[1]; 

wire    [7:0]	data_fifo_din;
wire            data_fifo_wr;
wire    [11:0]  data_fifo_depth;
reg     [15:0]  ptr_fifo_din;
reg             ptr_fifo_wr;
wire            ptr_fifo_full;
reg             fv;
wire    [31:0]  crc_result;
wire			bp;
assign bp=(data_fifo_depth>2578) | ptr_fifo_full;
//============================================  
//main state.   
//============================================  
reg     [2:0]   state;
always @(posedge rx_clk  or negedge rstn)
    if(!rstn)begin
        state<=#DELAY 0;
        ptr_fifo_din<=#DELAY 0;
        ptr_fifo_wr<=#DELAY 0;
        fv<=#DELAY 0;
        end
    else begin
        case(state)
        0: begin
            if(dv_sof & !bp)begin
                if(!sfd) begin
                    state<=#DELAY 1;
                    end
                else begin
                    state<=#DELAY 2;
                    fv<=#2 1;
                    end
                end
            end
        1:begin
            if(rx_dv_reg0)begin
                if(sfd) begin
                    fv<=#2 1;
                    state<=#DELAY 2;
                    end
                end
            else state<=#DELAY 0;
            end
        2:begin
            if(dv_eof)begin
                fv<=#2 0;
                if(speed[1]) ptr_fifo_din[11:0]<=#DELAY nib_cnt;
                else ptr_fifo_din[11:0]<=#DELAY {1'b0,nib_cnt[11:1]};
                if(speed[1])begin
                    if((nib_cnt<64) | (nib_cnt>1518)) ptr_fifo_din[14]<=#DELAY 1;
                    else ptr_fifo_din[14]<=#DELAY 0;
                end
                else begin
                    if((nib_cnt[11:1]<64) | (nib_cnt[11:1]>1518))ptr_fifo_din[14]<=#DELAY 1;
                    else ptr_fifo_din[14]<=#DELAY 0;
                end
                if(crc_result==CRC_RESULT_VALUE) ptr_fifo_din[15]<=#DELAY 1'b0;
                else ptr_fifo_din[15]<=#DELAY 1'b1;
                ptr_fifo_wr<=#DELAY 1;
                state<=#DELAY 3;
                end
            end
        3:begin
            ptr_fifo_wr<=#DELAY 0;
            state<=#DELAY 0;
            end
        endcase
        end

assign  nib_cnt_clr=(dv_sof & sfd) | ((state==1)& sfd);
assign  data_fifo_din=rx_d_reg | {rx_d_reg0[3:0],rx_d_reg1[3:0]};
assign  data_fifo_wr=rx_dv_reg0 & fv & byte_dv;
//============================================  
//modules used. 
//============================================  
crc32_8023 u_crc32_8023(
    .clk(rx_clk), 
    .reset(!rstn), 
    .d(data_fifo_din), 
    .load_init(dv_sof),
    .calc(data_fifo_wr), 
    .d_valid(data_fifo_wr), 
    .crc_reg(crc_result), 
    .crc()
    );

afifo_w8_d4k u_data_fifo (
  .rst(!rstn),                      // input rst
  .wr_clk(rx_clk),                  // input wr_clk
  .rd_clk(clk),                     // input rd_clk
  .din(data_fifo_din),              // input [7 : 0] din
  .wr_en(data_fifo_wr),             // input wr_en
  .rd_en(data_fifo_rd),             // input rd_en
  .dout(data_fifo_dout),            // output [7 : 0]       
  .full(), 
  .empty(), 
  .rd_data_count(), 				// output [11 : 0] rd_data_count
  .wr_data_count(data_fifo_depth) 	// output [11 : 0] wr_data_count
);

afifo_w16_d32 u_ptr_fifo (
  .rst(!rstn),                      // input rst
  .wr_clk(rx_clk),                  // input wr_clk
  .rd_clk(clk),                     // input rd_clk
  .din(ptr_fifo_din),               // input [15 : 0] din
  .wr_en(ptr_fifo_wr),              // input wr_en
  .rd_en(ptr_fifo_rd),              // input rd_en
  .dout(ptr_fifo_dout),             // output [15 : 0] dout
  .full(ptr_fifo_full),             // output full
  .empty(ptr_fifo_empty)            // output empty
);
endmodule
