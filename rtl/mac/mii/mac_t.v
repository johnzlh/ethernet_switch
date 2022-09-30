`timescale 1ns / 1ps
module mac_t(
input               	rstn,
input               	clk,
input              		tx_clk,
output  reg        		tx_dv,
output  reg [3:0]    	tx_d,
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
reg         	data_fifo_rd_1;
wire[7:0]   	data_fifo_dout_1;
wire[11:0]  	data_fifo_depth_1;
reg [15:0]  	ptr_fifo_din_1;
reg        		ptr_fifo_wr_1;
reg         	ptr_fifo_rd_1;
wire[15:0]  	ptr_fifo_dout_1;
wire       		ptr_fifo_full_1;
wire       		ptr_fifo_empty_1;

wire        	bp_1;
assign      	bp_1=ptr_fifo_full_1 | (data_fifo_depth_1>2566);
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
            if(!ptr_fifo_empty & !bp_1) begin
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
afifo_w8_d4k u_data_fifo_1 (
  .rst(!rstn),                      // input rst
  .wr_clk(clk),                     // input wr_clk
  .rd_clk(tx_clk),                  // input rd_clk
  .din(data_fifo_din_1),            // input [7 : 0] din
  .wr_en(data_fifo_wr_1),           // input wr_en
  .rd_en(data_fifo_rd_1),           // input rd_en
  .dout(data_fifo_dout_1),          // output [7 : 0] dout
  .full(),                          // output full
  .empty(),                         // output empty
  .rd_data_count(),					// output [11 : 0] rd_data_count
  .wr_data_count(data_fifo_depth_1) // output [11 : 0] wr_data_count
);
afifo_w16_d32 u_ptr_fifo_1 (
  .rst(!rstn),                      // input rst
  .wr_clk(clk),                     // input wr_clk
  .rd_clk(tx_clk),                  // input rd_clk
  .din(ptr_fifo_din_1),             // input [15 : 0] din
  .wr_en(ptr_fifo_wr_1),            // input wr_en
  .rd_en(ptr_fifo_rd_1),            // input rd_en
  .dout(ptr_fifo_dout_1),           // output [15 : 0] dout
  .full(ptr_fifo_full_1),           // output full
  .empty(ptr_fifo_empty_1)      	// output empty
);

reg     [10:0]  cnt_t;
reg     [2:0]       state_t;
reg             data_fifo_rd_1_reg_0;
reg             data_fifo_rd_1_reg_1;
reg             tx_sof;
always @(posedge tx_clk or negedge rstn) 
    if(!rstn) begin
        state_t         <=#DELAY 0;
        cnt_t           <=#DELAY 0;
        data_fifo_rd_1  <=#DELAY 0;
        ptr_fifo_rd_1   <=#DELAY 0;
        data_fifo_rd_1_reg_0<=#DELAY 0;
        data_fifo_rd_1_reg_1<=#DELAY 0;
        tx_sof          <=#DELAY 0;
        end
    else begin
        ptr_fifo_rd_1<=#DELAY 0;
        data_fifo_rd_1_reg_0<=#DELAY data_fifo_rd_1;
        data_fifo_rd_1_reg_1<=#DELAY data_fifo_rd_1_reg_0;
        tx_sof          <=#DELAY 0;
        case(state_t)
        0:begin
            if(!ptr_fifo_empty_1) begin
                ptr_fifo_rd_1<=#DELAY 1;
                state_t<=#DELAY 1;
                end
            end
        1:state_t<=#DELAY 2;
        2:begin
            cnt_t   <=#DELAY ptr_fifo_dout_1[10:0];
            data_fifo_rd_1<=#DELAY 1;
            tx_sof  <=#DELAY 1;
            state_t <=#DELAY 3;
            end
        3:begin
            data_fifo_rd_1<=#DELAY 0;
            state_t <=#DELAY 4;
            end
        4:begin
            if(cnt_t>1) begin
                data_fifo_rd_1<=#DELAY 1;
                cnt_t<=#DELAY cnt_t-1;
                state_t <=#DELAY 3;
                end
            else begin
                data_fifo_rd_1<=#DELAY 0;
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

wire    tx_dv_i;
assign  tx_dv_i=data_fifo_rd_1_reg_0 |  data_fifo_rd_1_reg_1;
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
            if(data_fifo_rd_1_reg_0)        tx_d<=#DELAY data_fifo_dout_1[3:0];
            else if(data_fifo_rd_1_reg_1)   tx_d<=#DELAY data_fifo_dout_1[7:4];
            else begin
                tx_d<=#DELAY 0;
                state_tx<=#DELAY 0;
                end
            end
        endcase
        end
endmodule	
