`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/11 16:42:24
// Design Name: 
// Module Name: mac_t_gmii
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



module mac_t_gmii_n(
input               	rstn,
input               	clk,
input              		tx_clk,
input                   gtx_clk,
output          		gtx_dv,
output      [7:0]    	gm_tx_d,


input       [1:0]       speed, //ethernet speed 00:10M 01:100M 10:1000M

output  reg         	data_fifo_rd,
input      [7:0]  		data_fifo_din,
output  reg        		ptr_fifo_rd, 
input       [15:0]  	ptr_fifo_din,
input              		ptr_fifo_empty
    );
parameter       DELAY=2;
reg	[10:0]  	cnt;
reg 	[10:0]  pad_cnt;
reg        		crc_init;
wire	[7:0]  	crc_din;
reg         	crc_cal;
reg         	crc_dv;
wire	[31:0]  crc_result;
wire	[7:0]   crc_dout;

reg [7:0]   	data_fifo_din_1;
reg         	data_fifo_wr_1;
wire            data_fifo_wr_tx;
wire            data_fifo_wr_gtx;
assign          data_fifo_wr_tx = (!speed[1])&data_fifo_wr_1;
assign          data_fifo_wr_gtx = speed[1]&data_fifo_wr_1;

reg             data_fifo_rd_tx;
reg             data_fifo_rd_gtx;


wire[7:0]   	data_fifo_dout_tx;
wire[11:0]  	data_fifo_depth_tx;
wire[7:0]   	data_fifo_dout_gtx;
wire[11:0]  	data_fifo_depth_gtx;


reg [15:0]  	ptr_fifo_din_1;
reg        		ptr_fifo_wr_1;
wire            ptr_fifo_wr_tx;
wire            ptr_fifo_wr_gtx;
assign          ptr_fifo_wr_tx = (!speed[1])&ptr_fifo_wr_1;
assign          ptr_fifo_wr_gtx = speed[1]&ptr_fifo_wr_1;

reg             ptr_fifo_rd_tx;
reg             ptr_fifo_rd_gtx;
  
wire[15:0]  	ptr_fifo_dout_tx;
wire       		ptr_fifo_full_tx;
wire       		ptr_fifo_empty_tx;

wire[15:0]  	ptr_fifo_dout_gtx;
wire       		ptr_fifo_full_gtx;
wire       		ptr_fifo_empty_gtx;


wire        	bp_tx;
assign      	bp_tx=ptr_fifo_full_tx | (data_fifo_depth_tx>2566);

wire        	bp_gtx;
assign      	bp_gtx=ptr_fifo_full_gtx | (data_fifo_depth_gtx>2566);

wire            bp;
assign          bp = speed[1]?bp_gtx:bp_tx;
reg [2:0]   state;
always @(posedge clk or negedge rstn) 
    if(!rstn)begin
        state<=#DELAY 0;
        ptr_fifo_rd     <=#DELAY 0;
        data_fifo_rd    <=#DELAY 0;
        cnt             <=#DELAY 0;
        pad_cnt         <=#DELAY 0;
        crc_init        <=#DELAY 0;
        crc_cal         <=#DELAY 0;
        crc_dv          <=#DELAY 0;
        data_fifo_din_1 <=#DELAY 0;
        data_fifo_wr_1  <=#DELAY 0;
        ptr_fifo_din_1  <=#DELAY 0;
        ptr_fifo_wr_1   <=#DELAY 0; 
        end
    else begin
        crc_init<=#DELAY 0;
        ptr_fifo_rd<=#DELAY 0;
        case(state)
        0:begin
            ptr_fifo_wr_1<=#DELAY 0;
            data_fifo_wr_1<=#DELAY 0;
            if(!ptr_fifo_empty & !bp) begin
                ptr_fifo_rd<=#DELAY 1;
                crc_init<=#DELAY 1;
                data_fifo_wr_1<=#DELAY 1;
                data_fifo_din_1<=#DELAY 8'h55;
                cnt<=#DELAY 7;
                state<=#DELAY 1;
                end
            end
        1:begin
            if(cnt>1) cnt<=#DELAY cnt-1;
            else begin  
                data_fifo_din_1<=#DELAY 8'hd5;
                data_fifo_rd<=#DELAY 1;
                cnt<=#DELAY ptr_fifo_din[10:0];
                state<=#DELAY 2;
                end
            end
        2:begin
            cnt<=#DELAY cnt-1;
            if(cnt<60) pad_cnt<=#DELAY 60-cnt;
            else pad_cnt<=#DELAY 0;
            data_fifo_wr_1<=#DELAY 0;
            state<=#DELAY 3;
            end
        3:begin
            data_fifo_wr_1 <=#DELAY 1;
            data_fifo_din_1<=#DELAY data_fifo_din;
            crc_cal     <=#DELAY 1;
            crc_dv      <=#DELAY 1;
            if(cnt>1) cnt   <=#DELAY cnt-1;
            else begin
                data_fifo_rd<=#DELAY 0;
                cnt <=#DELAY 0;
                state   <=#DELAY 4;
                end
            end
        4:begin
            data_fifo_wr_1  <=#DELAY 1;
            data_fifo_din_1 <=#DELAY data_fifo_din;
            state           <=#DELAY 5;
            end
        5:begin
            if(pad_cnt) begin
                cnt             <=#DELAY pad_cnt;
                data_fifo_wr_1  <=#DELAY 1;
                data_fifo_din_1 <=#DELAY 8'b0;
                state           <=#DELAY 6;
                end
            else begin
                data_fifo_wr_1  <=#DELAY 0;
                crc_cal         <=#DELAY 0;
                cnt             <=#DELAY 4;
                state           <=#DELAY 7;
                end
            end
        6:begin
            if(cnt>1) cnt<=#DELAY cnt-1;
            else begin
                data_fifo_wr_1  <=#DELAY 0;
                crc_cal         <=#DELAY 0;
                cnt             <=#DELAY 4;
                state           <=#DELAY 7;
                end
            end
        7:begin
            data_fifo_wr_1  <=#DELAY 1;
            data_fifo_din_1 <=#DELAY crc_dout;
            if(cnt==1)  crc_dv  <=#DELAY 0;
            if(cnt>0)   cnt     <=#DELAY cnt-1;
            else begin
                data_fifo_wr_1  <=#DELAY 0;
                ptr_fifo_din_1<=#DELAY ptr_fifo_din+12+pad_cnt;
                ptr_fifo_wr_1<=#DELAY 1;
                state       <=#DELAY 0;
                end
            end
        endcase
        end
crc32_8023 u_crc32_8023(
    .clk(clk), 
    .reset(!rstn), 
    .d(crc_din), 
    .load_init(crc_init),
    .calc(crc_cal), 
    .d_valid(crc_dv), 
    .crc_reg(crc_result), 
    .crc(crc_dout)
    );
assign  crc_din=data_fifo_din_1;
afifo_w8_d4k u_data_fifo_tx (
  .rst(!rstn),                      // input rst
  .wr_clk(clk),                     // input wr_clk
  .rd_clk(tx_clk),                // input rd_clk
  .din(data_fifo_din_1),            // input [7 : 0] din
  .wr_en(data_fifo_wr_tx),           // input wr_en
  .rd_en(data_fifo_rd_tx),           // input rd_en
  .dout(data_fifo_dout_tx),          // output [7 : 0] dout
  .full(),                          // output full
  .empty(),                         // output empty
  .rd_data_count(),					// output [11 : 0] rd_data_count
  .wr_data_count(data_fifo_depth_tx) // output [11 : 0] wr_data_count
);
afifo_w16_d32 u_ptr_fifo_tx (
  .rst(!rstn),                      // input rst
  .wr_clk(clk),                     // input wr_clk
  .rd_clk(tx_clk),                // input rd_clk
  .din(ptr_fifo_din_1),             // input [15 : 0] din
  .wr_en(ptr_fifo_wr_tx),            // input wr_en
  .rd_en(ptr_fifo_rd_tx),            // input rd_en
  .dout(ptr_fifo_dout_tx),           // output [15 : 0] dout
  .full(ptr_fifo_full_tx),           // output full
  .empty(ptr_fifo_empty_tx)      	// output empty
);

afifo_w8_d4k u_data_fifo_gtx (
  .rst(!rstn),                      // input rst
  .wr_clk(clk),                     // input wr_clk
  .rd_clk(gtx_clk),                // input rd_clk
  .din(data_fifo_din_1),            // input [7 : 0] din
  .wr_en(data_fifo_wr_gtx),           // input wr_en
  .rd_en(data_fifo_rd_gtx),           // input rd_en
  .dout(data_fifo_dout_gtx),          // output [7 : 0] dout
  .full(),                          // output full
  .empty(),                         // output empty
  .rd_data_count(),					// output [11 : 0] rd_data_count
  .wr_data_count(data_fifo_depth_gtx) // output [11 : 0] wr_data_count
);
afifo_w16_d32 u_ptr_fifo_gtx (
  .rst(!rstn),                      // input rst
  .wr_clk(clk),                     // input wr_clk
  .rd_clk(gtx_clk),                // input rd_clk
  .din(ptr_fifo_din_1),             // input [15 : 0] din
  .wr_en(ptr_fifo_wr_gtx),            // input wr_en
  .rd_en(ptr_fifo_rd_gtx),            // input rd_en
  .dout(ptr_fifo_dout_gtx),           // output [15 : 0] dout
  .full(ptr_fifo_full_gtx),           // output full
  .empty(ptr_fifo_empty_gtx)      	// output empty
);


reg     [10:0]  cnt_t;
reg     [2:0]       state_t;
reg             data_fifo_rd_tx_reg_0;
reg             data_fifo_rd_tx_reg_1;
reg             tx_sof;
always @(posedge tx_clk or negedge rstn) 
    if(!rstn) begin
        state_t         <=#DELAY 0;
        cnt_t           <=#DELAY 0;
        data_fifo_rd_tx  <=#DELAY 0;
        ptr_fifo_rd_tx   <=#DELAY 0;
        data_fifo_rd_tx_reg_0<=#DELAY 0;
        data_fifo_rd_tx_reg_1<=#DELAY 0;
        tx_sof          <=#DELAY 0;
        end
    else begin
        ptr_fifo_rd_tx<=#DELAY 0;
        data_fifo_rd_tx_reg_0<=#DELAY data_fifo_rd_tx;
        data_fifo_rd_tx_reg_1<=#DELAY data_fifo_rd_tx_reg_0;
        tx_sof          <=#DELAY 0;
        case(state_t)
        0:begin
            if(!ptr_fifo_empty_tx & !speed[1]) begin
                ptr_fifo_rd_tx<=#DELAY 1;
                state_t<=#DELAY 1;
                end
            end
        1:state_t<=#DELAY 2;
        2:begin
            cnt_t   <=#DELAY ptr_fifo_dout_tx[10:0];
            data_fifo_rd_tx<=#DELAY 1;
            tx_sof  <=#DELAY 1;
            state_t <=#DELAY 3;
            end
        3:begin
            data_fifo_rd_tx<=#DELAY 0;
            state_t <=#DELAY 4;
            end
        4:begin
            if(cnt_t>1) begin
                data_fifo_rd_tx<=#DELAY 1;
                cnt_t<=#DELAY cnt_t-1;
                state_t <=#DELAY 3;
                end
            else begin
                data_fifo_rd_tx<=#DELAY 0;
                cnt_t<=#DELAY 24;
                state_t<=#DELAY 5;
                end
            end
        5:begin
            if(cnt_t>0) cnt_t<=#DELAY cnt_t-1;
            else begin
                cnt_t   <=#DELAY 0;
                state_t <=#DELAY 0;
                end
            end
        endcase
        end


reg     tx_dv;
reg     [3:0]   tx_d;
wire    tx_dv_i;
assign  tx_dv_i=(data_fifo_rd_tx_reg_0 |  data_fifo_rd_tx_reg_1)&(!speed[1]);
reg     [1:0]   state_tx;
always @(posedge tx_clk or negedge rstn) 
    if(!rstn) begin
        state_tx<=#DELAY 0;
        tx_dv<=#DELAY 0;
        tx_d<=#DELAY 0;
        end
    else begin
        tx_dv<=#DELAY tx_dv_i;
        case(state_tx)
        0:begin
            if(tx_sof)state_tx<=#DELAY 1;
            end
        1:begin
            if(data_fifo_rd_tx_reg_0)        tx_d<=#DELAY data_fifo_dout_tx[3:0];
            else if(data_fifo_rd_tx_reg_1)   tx_d<=#DELAY data_fifo_dout_tx[7:4];
            else begin
                tx_d<=#DELAY 0;
                state_tx<=#DELAY 0;
                end
            end
        endcase
        end



reg     [10:0]  gcnt_t;
reg     [2:0]       state_gt;
reg             data_fifo_rd_gtx_reg;
reg             gtx_sof;
always @(posedge gtx_clk or negedge rstn) 
    if(!rstn) begin
        state_gt         <=#DELAY 0;
        gcnt_t           <=#DELAY 0;
        data_fifo_rd_gtx  <=#DELAY 0;
        ptr_fifo_rd_gtx   <=#DELAY 0;
        data_fifo_rd_gtx_reg<=#DELAY 0;
        gtx_sof          <=#DELAY 0;
        end
    else begin
        ptr_fifo_rd_gtx<=#DELAY 0;
        data_fifo_rd_gtx_reg<=#DELAY data_fifo_rd_gtx;
        gtx_sof          <=#DELAY 0;
        case(state_gt)
        0:begin
            if(!ptr_fifo_empty_gtx & speed[1]) begin
                ptr_fifo_rd_gtx<=#DELAY 1;
                state_gt<=#DELAY 1;
                end
            end
        1:state_gt<=#DELAY 2;
        2:begin
            gcnt_t   <=#DELAY ptr_fifo_dout_gtx[10:0];
            data_fifo_rd_gtx<=#DELAY 1;
            gtx_sof  <=#DELAY 1;
            state_gt <=#DELAY 3;
            end
        3:begin
            if(gcnt_t>1) begin
                gcnt_t<=#DELAY gcnt_t-1;
                end
            else begin
                data_fifo_rd_gtx<=#DELAY 0;
                gcnt_t<=#DELAY 12;
                state_gt<=#DELAY 4;
                end
            end
        4:begin
            if(gcnt_t>0) gcnt_t<=#DELAY gcnt_t-1;
            else begin
                gcnt_t   <=#DELAY 0;
                state_gt <=#DELAY 0;
                end
            end
        endcase
        end


reg     gtx_dv_rg;
reg     [7:0]   gtx_d;
wire    gtx_dv_i;
assign  gtx_dv_i=data_fifo_rd_gtx_reg&(speed[1]);
reg     [1:0]   state_gtx;
always @(posedge gtx_clk or negedge rstn) 
    if(!rstn) begin
        state_gtx<=#DELAY 0;
        gtx_dv_rg<=#DELAY 0;
        gtx_d<=#DELAY 0;
        end
    else begin
        gtx_dv_rg<=#DELAY gtx_dv_i;
        case(state_gtx)
        0:begin
            if(gtx_sof)state_gtx<=#DELAY 1;
            end
        1:begin
            if(data_fifo_rd_gtx_reg)        gtx_d<=#DELAY data_fifo_dout_gtx;
            else begin
                gtx_d<=#DELAY 0;
                state_gtx<=#DELAY 0;
                end
            end
        endcase
        end

assign  gtx_dv = (speed[1]==1)? gtx_dv_rg : tx_dv;
assign  gm_tx_d = (speed[1]==1)? gtx_d : {4'b0,tx_d};
endmodule
