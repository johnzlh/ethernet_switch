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



module mac_t_gmii_tte(
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
input              		ptr_fifo_empty,

output  reg         	tdata_fifo_rd,
input      [7:0]  		tdata_fifo_din,
output  reg        		tptr_fifo_rd, 
input       [15:0]  	tptr_fifo_din,
input              		tptr_fifo_empty,

input                   status_fifo_rd, 
output      [15:0]      status_fifo_dout,
output                  status_fifo_empty,

input       [31:0]      counter_ns,
output      [63:0]      counter_ns_tx_delay,
output      [63:0]      counter_ns_gtx_delay
    );

parameter DELAY=2;
parameter PTP_VALUE_HIGH=8'h88;
parameter PTP_VALUE_LOWER=8'hf7;

reg	[10:0]  	cnt;
reg [10:0]      pad_cnt;


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

reg [7:0]   	tdata_fifo_din_1;
reg         	tdata_fifo_wr_1;
wire            tdata_fifo_wr_tx;
wire            tdata_fifo_wr_gtx;
assign          tdata_fifo_wr_tx = (!speed[1])&tdata_fifo_wr_1;
assign          tdata_fifo_wr_gtx = speed[1]&tdata_fifo_wr_1;

reg             tdata_fifo_rd_tx;
reg             tdata_fifo_rd_gtx;


wire[7:0]   	tdata_fifo_dout_tx;
wire[11:0]  	tdata_fifo_depth_tx;
wire[7:0]   	tdata_fifo_dout_gtx;
wire[11:0]  	tdata_fifo_depth_gtx;


reg [15:0]  	tptr_fifo_din_1;
reg        		tptr_fifo_wr_1;
wire            tptr_fifo_wr_tx;
wire            tptr_fifo_wr_gtx;
assign          tptr_fifo_wr_tx = (!speed[1])&tptr_fifo_wr_1;
assign          tptr_fifo_wr_gtx = speed[1]&tptr_fifo_wr_1;

reg             tptr_fifo_rd_tx;
reg             tptr_fifo_rd_gtx;
  
wire[15:0]  	tptr_fifo_dout_tx;
wire       		tptr_fifo_full_tx;
wire       		tptr_fifo_empty_tx;

wire[15:0]  	tptr_fifo_dout_gtx;
wire       		tptr_fifo_full_gtx;
wire       		tptr_fifo_empty_gtx;


wire        	tbp_tx;
assign      	tbp_tx=tptr_fifo_full_tx | (tdata_fifo_depth_tx>2566);

wire        	tbp_gtx;
assign      	tbp_gtx=tptr_fifo_full_gtx | (tdata_fifo_depth_gtx>2566);

wire            tbp;
assign          tbp = speed[1]?tbp_gtx:tbp_tx;

reg     [15:0]  status_fifo_din;
reg             status_fifo_wr;

reg             ptp_init;

reg [4:0]   state;
always @(posedge clk or negedge rstn) 
    if(!rstn)begin
        state<=#DELAY 0;
        cnt             <=#DELAY 0;
        ptp_init        <=#DELAY 0;
        pad_cnt         <=#DELAY 0;
        // crc_init        <=#DELAY 0;
        // crc_cal         <=#DELAY 0;
        // crc_dv          <=#DELAY 0;
        ptr_fifo_rd     <=#DELAY 0;
        data_fifo_rd    <=#DELAY 0;
        data_fifo_din_1 <=#DELAY 0;
        data_fifo_wr_1  <=#DELAY 0;
        ptr_fifo_din_1  <=#DELAY 0;
        ptr_fifo_wr_1   <=#DELAY 0; 
        tptr_fifo_rd     <=#DELAY 0;
        tdata_fifo_rd    <=#DELAY 0;
        tdata_fifo_din_1 <=#DELAY 0;
        tdata_fifo_wr_1  <=#DELAY 0;
        tptr_fifo_din_1  <=#DELAY 0;
        tptr_fifo_wr_1   <=#DELAY 0; 
        status_fifo_din  <=#DELAY 0;
        status_fifo_wr   <=#DELAY 0; 
        end
    else begin
        // crc_init<=#DELAY 0;
        ptr_fifo_rd<=#DELAY 0;
        tptr_fifo_rd<=#DELAY 0;
        ptp_init<=#DELAY 0;
        case(state)
        0:begin
            ptr_fifo_wr_1<=#DELAY 0;
            data_fifo_wr_1<=#DELAY 0;
            tptr_fifo_wr_1<=#DELAY 0;
            tdata_fifo_wr_1<=#DELAY 0;
            status_fifo_wr<=#DELAY 0;
            if(!tptr_fifo_empty & !tbp) begin
                tptr_fifo_rd<=#DELAY 1;
                // crc_init<=#DELAY 1;
                state<=#DELAY 9;
                end
            else if(!ptr_fifo_empty & !bp) begin
                ptr_fifo_rd<=#DELAY 1;
                // crc_init<=#DELAY 1;
                state<=#DELAY 1;
                end
            end
        1:state<=#DELAY 2;
        2:begin
            data_fifo_rd<=#DELAY 1;
            cnt<=#DELAY ptr_fifo_din[10:0];
            ptp_init<=#DELAY 1;
            state<=#DELAY 3;
            end
        3:begin
            cnt<=#DELAY cnt-1;
            if(cnt<60) pad_cnt<=#DELAY 60-cnt;
            else pad_cnt<=#DELAY 0;
            // data_fifo_wr_1<=#DELAY 0;
            state<=#DELAY 4;
            end
        4:begin
            data_fifo_wr_1 <=#DELAY 1;
            data_fifo_din_1<=#DELAY data_fifo_din;
            // crc_cal     <=#DELAY 1;
            // crc_dv      <=#DELAY 1;
            if(cnt>1) begin
            cnt   <=#DELAY cnt-1;
            end
            else begin
                data_fifo_rd<=#DELAY 0;
                cnt <=#DELAY 0;
                state   <=#DELAY 5;
                end
            end
        5:begin
            // data_fifo_wr_1  <=#DELAY 1;
            data_fifo_din_1 <=#DELAY data_fifo_din;
            state           <=#DELAY 6;
            end
        6:begin
            if(pad_cnt) begin
                cnt             <=#DELAY pad_cnt;
                // data_fifo_wr_1  <=#DELAY 1;
                data_fifo_din_1 <=#DELAY 8'b0;
                state           <=#DELAY 7;
                end
            else begin
                data_fifo_wr_1  <=#DELAY 0;
                // crc_cal         <=#DELAY 0;
                cnt             <=#DELAY 0;
                state           <=#DELAY 8;
                end
            end
        7:begin
            if(cnt>1) cnt<=#DELAY cnt-1;
            else begin
                data_fifo_wr_1  <=#DELAY 0;
                // crc_cal         <=#DELAY 0;
                cnt             <=#DELAY 0;
                state           <=#DELAY 8;
                end
            end
        // 7:begin
        //     data_fifo_wr_1  <=#DELAY 1;
        //     data_fifo_din_1 <=#DELAY crc_dout;
        //     // if(cnt==1)  crc_dv  <=#DELAY 0;
        //     if(cnt>0)   cnt     <=#DELAY cnt-1;
        //     else begin
        //         data_fifo_wr_1  <=#DELAY 0;
        //         data_fifo_din_1 <=#DELAY 0;
        //         ptr_fifo_din_1<=#DELAY ptr_fifo_din+12+pad_cnt;
        //         ptr_fifo_wr_1<=#DELAY 1;
        //         status_fifo_din<=#DELAY ptr_fifo_din+12+pad_cnt;
        //         status_fifo_wr<=#DELAY 1; 
        //         state       <=#DELAY 0;
        //         end
        //     end
        8:begin
            ptr_fifo_din_1<=#DELAY ptr_fifo_din+pad_cnt;
            ptr_fifo_wr_1<=#DELAY 1;
            status_fifo_din<=#DELAY ptr_fifo_din+12+pad_cnt;
            status_fifo_wr<=#DELAY 1; 
            state       <=#DELAY 0;
            end
        9:state<=#DELAY 10;
        10:begin 
            tdata_fifo_rd<=#DELAY 1;
            cnt<=#DELAY tptr_fifo_din[10:0];
            state<=#DELAY 11;
           end
         11:begin
            cnt<=#DELAY cnt-1;
            if(cnt<60) pad_cnt<=#DELAY 60-cnt;
            else pad_cnt<=#DELAY 0;
            // tdata_fifo_wr_1<=#DELAY 0;
            state<=#DELAY 12;
            end
         12:begin
             tdata_fifo_wr_1 <=#DELAY 1;
             tdata_fifo_din_1<=#DELAY tdata_fifo_din;
            //  crc_cal     <=#DELAY 1;
            //  crc_dv      <=#DELAY 1;
             if(cnt>1) cnt   <=#DELAY cnt-1;
             else begin
                  tdata_fifo_rd<=#DELAY 0;
                  cnt <=#DELAY 0;
                  state   <=#DELAY 13;
                end
            end
         13:begin
                // tdata_fifo_wr_1  <=#DELAY 1;
                tdata_fifo_din_1 <=#DELAY tdata_fifo_din;
                state           <=#DELAY 14;
            end
         14:begin
                if(pad_cnt) begin
                    cnt             <=#DELAY pad_cnt;
                    // tdata_fifo_wr_1  <=#DELAY 1;
                    tdata_fifo_din_1 <=#DELAY 8'b0;
                    state           <=#DELAY 15;
                    end
                else begin
                    tdata_fifo_wr_1  <=#DELAY 0;
                    // crc_cal         <=#DELAY 0;
                    cnt             <=#DELAY 0;
                    state           <=#DELAY 16;
                    end
            end
        15:begin
            if(cnt>1) cnt<=#DELAY cnt-1;
            else begin
                tdata_fifo_wr_1  <=#DELAY 0;
                // crc_cal         <=#DELAY 0;
                cnt             <=#DELAY 0;
                state           <=#DELAY 16;
                end
            end
        // 14:begin
        //     tdata_fifo_wr_1  <=#DELAY 1;
        //     tdata_fifo_din_1 <=#DELAY crc_dout;
        //     // if(cnt==1)  crc_dv  <=#DELAY 0;
        //     if(cnt>0)   cnt     <=#DELAY cnt-1;
        //     else begin
        //         tdata_fifo_wr_1  <=#DELAY 0;
        //         tdata_fifo_din_1 <=#DELAY 0;
        //         tptr_fifo_din_1<=#DELAY tptr_fifo_din+8+pad_cnt;
        //         tptr_fifo_wr_1<=#DELAY 1;
        //         status_fifo_din<=#DELAY tptr_fifo_din+12+pad_cnt;
        //         status_fifo_wr<=#DELAY 1; 
        //         state       <=#DELAY 0;
        //         end
        //     end  
        16:begin
                tptr_fifo_din_1<=#DELAY tptr_fifo_din+pad_cnt;
                tptr_fifo_wr_1<=#DELAY 1;
                status_fifo_din<=#DELAY tptr_fifo_din+12+pad_cnt;
                status_fifo_wr<=#DELAY 1; 
                state       <=#DELAY 0;
            end    
        endcase
        end


//============================================  
//PTP tx_state.   
//============================================ 

reg     [10:0]      ptp_cnt;
reg     [3:0]       ptp_state;

reg [63:0]  counter_ns_sync_message;

always @(posedge clk  or negedge rstn)
    if(!rstn)begin
        ptp_state<=#DELAY 0;
        ptp_cnt<=#DELAY 0;
        counter_ns_sync_message<=#DELAY 0;
    end
    else begin
        case(ptp_state)
        0: begin
            ptp_cnt<=#DELAY 0;
            if(ptp_init)begin
                ptp_state<=#DELAY 1;
            end
        end
        1:begin
            if(ptp_cnt==11) begin
                ptp_cnt<=#DELAY 0;
                ptp_state<=#DELAY 2;
            end
            else    ptp_cnt<=#DELAY ptp_cnt+1;
        end
        2:begin
            if(data_fifo_din==PTP_VALUE_HIGH) begin
                ptp_state<=#2 3;
            end
            else  ptp_state<=#2 0;  
        end
        3:begin
            if(data_fifo_din==PTP_VALUE_LOWER) begin
                ptp_state<=#2 4;
            end
            else  ptp_state<=#2 0;  
        end
        4:begin
            if(data_fifo_din[3:0]==4'b1000) begin //follow up
                ptp_state<=#2 5;
            end
            else  ptp_state<=#2 0;  
        end
        5:begin
            if(ptp_cnt==6) begin
                ptp_cnt<=#DELAY 0;
                ptp_state<=#DELAY 6;
            end
            else    ptp_cnt<=#DELAY ptp_cnt+1;
        end
        6:begin
            counter_ns_sync_message[63:56]<=#DELAY data_fifo_din;
            ptp_state<=#DELAY 7;
        end
        7:begin
            counter_ns_sync_message[55:48]<=#DELAY data_fifo_din;
            ptp_state<=#DELAY 8;
        end
        8:begin
            counter_ns_sync_message[47:40]<=#DELAY data_fifo_din;
            ptp_state<=#DELAY 9;
        end
        9:begin
            counter_ns_sync_message[39:32]<=#DELAY data_fifo_din;
            ptp_state<=#DELAY 10;
        end
        10:begin
            counter_ns_sync_message[31:24]<=#DELAY data_fifo_din;
            ptp_state<=#DELAY 11;
        end
        11:begin
            counter_ns_sync_message[23:16]<=#DELAY data_fifo_din;
            ptp_state<=#DELAY 12;
        end
        12:begin
            counter_ns_sync_message[15:8]<=#DELAY data_fifo_din;
            ptp_state<=#DELAY 13;
        end
        13:begin
            counter_ns_sync_message[7:0]<=#DELAY data_fifo_din;
            ptp_state<=#DELAY 0;
        end
        endcase
    end

wire    [7:0]   data_fifo_din_tx;
assign data_fifo_din_tx = data_fifo_din_1;

afifo_w8_d4k u_data_fifo_tx (
  .rst(!rstn),                      // input rst
  .wr_clk(clk),                     // input wr_clk
  .rd_clk(tx_clk),                // input rd_clk
  .din(data_fifo_din_tx),            // input [7 : 0] din
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
afifo_w8_d4k u_tte_fifo_tx (
  .rst(!rstn),                      // input rst
  .wr_clk(clk),                     // input wr_clk
  .rd_clk(tx_clk),                // input rd_clk
  .din(tdata_fifo_din_1),            // input [7 : 0] din
  .wr_en(tdata_fifo_wr_tx),           // input wr_en
  .rd_en(tdata_fifo_rd_tx),           // input rd_en
  .dout(tdata_fifo_dout_tx),          // output [7 : 0] dout
  .full(),                          // output full
  .empty(),                         // output empty
  .rd_data_count(),					// output [11 : 0] rd_data_count
  .wr_data_count(tdata_fifo_depth_tx) // output [11 : 0] wr_data_count
);
afifo_w16_d32 u_tteptr_fifo_tx (
  .rst(!rstn),                      // input rst
  .wr_clk(clk),                     // input wr_clk
  .rd_clk(tx_clk),                // input rd_clk
  .din(tptr_fifo_din_1),             // input [15 : 0] din
  .wr_en(tptr_fifo_wr_tx),            // input wr_en
  .rd_en(tptr_fifo_rd_tx),            // input rd_en
  .dout(tptr_fifo_dout_tx),           // output [15 : 0] dout
  .full(tptr_fifo_full_tx),           // output full
  .empty(tptr_fifo_empty_tx)      	// output empty
);

afifo_w8_d4k u_tte_fifo_gtx (
  .rst(!rstn),                      // input rst
  .wr_clk(clk),                     // input wr_clk
  .rd_clk(gtx_clk),                // input rd_clk
  .din(tdata_fifo_din_1),            // input [7 : 0] din
  .wr_en(tdata_fifo_wr_gtx),           // input wr_en
  .rd_en(tdata_fifo_rd_gtx),           // input rd_en
  .dout(tdata_fifo_dout_gtx),          // output [7 : 0] dout
  .full(),                          // output full
  .empty(),                         // output empty
  .rd_data_count(),					// output [11 : 0] rd_data_count
  .wr_data_count(tdata_fifo_depth_gtx) // output [11 : 0] wr_data_count
);
afifo_w16_d32 u_tteptr_fifo_gtx (
  .rst(!rstn),                      // input rst
  .wr_clk(clk),                     // input wr_clk
  .rd_clk(gtx_clk),                // input rd_clk
  .din(tptr_fifo_din_1),             // input [15 : 0] din
  .wr_en(tptr_fifo_wr_gtx),            // input wr_en
  .rd_en(tptr_fifo_rd_gtx),            // input rd_en
  .dout(tptr_fifo_dout_gtx),           // output [15 : 0] dout
  .full(tptr_fifo_full_gtx),           // output full
  .empty(tptr_fifo_empty_gtx)      	// output empty
);

sfifo_w16_d32 u_portstatus_fifo (
  .rst(!rstn),                          // input rst
  .clk(clk),                            // input clk
  .din(status_fifo_din),                // input [15 : 0] din
  .wr_en(status_fifo_wr),               // input wr_en
  .rd_en(status_fifo_rd),               // input rd_en
  .dout(status_fifo_dout),              // output [15 : 0] dout
  .full(),                              // output full
  .empty(status_fifo_empty)             // output empty
);

reg     [10:0]  cnt_t;
reg     [3:0]       state_t;
reg             data_fifo_rd_tx_reg_0;
reg             data_fifo_rd_tx_reg_1;
reg             tx_sof;
reg             tx_sfd;
reg             tdata_fifo_rd_tx_reg_0;
reg             tdata_fifo_rd_tx_reg_1;
reg             t_tx_sof;
reg             t_tx_sfd;
reg             crc_dv_tx_reg;
reg             crc_dv_tx_reg0;
reg             crc_dv_tx_reg1;
reg             crc_tte_tx;

//============================================  
//crc tx singal.   
//============================================  

reg        		crc_init_tx;
wire	[7:0]  	crc_din_tx;
reg         	crc_cal_tx;
reg         	crc_dv_tx;
wire	[31:0]  crc_result_tx;
wire	[7:0]   crc_dout_tx;

reg             crc_ptp_tx_dv;
reg [7:0]       ptp_data_tx;

crc32_8023 u_crc32_8023_tx(
    .clk(tx_clk), 
    .reset(!rstn), 
    .d(crc_din_tx), 
    .load_init(crc_init_tx),
    .calc(crc_cal_tx), 
    .d_valid(crc_dv_tx), 
    .crc_reg(crc_result_tx), 
    .crc(crc_dout_tx)
    );

assign crc_din_tx = (crc_ptp_tx_dv==1)? ptp_data_tx:(crc_tte_tx==1)? tdata_fifo_dout_tx : data_fifo_dout_tx;

//============================================  
//ptp tx singal.   
//============================================  

reg         ptp_tx_init;

always @(posedge tx_clk or negedge rstn) 
    if(!rstn) begin
        state_t         <=#DELAY 0;
        cnt_t           <=#DELAY 0;
        data_fifo_rd_tx  <=#DELAY 0;
        ptr_fifo_rd_tx   <=#DELAY 0;
        data_fifo_rd_tx_reg_0<=#DELAY 0;
        data_fifo_rd_tx_reg_1<=#DELAY 0;
        tx_sof          <=#DELAY 0;
        tx_sfd          <=#DELAY 0;
        tdata_fifo_rd_tx  <=#DELAY 0;
        tptr_fifo_rd_tx   <=#DELAY 0;
        tdata_fifo_rd_tx_reg_0<=#DELAY 0;
        tdata_fifo_rd_tx_reg_1<=#DELAY 0;
        t_tx_sof          <=#DELAY 0;
        t_tx_sfd          <=#DELAY 0;
        crc_init_tx       <=#DELAY 0;
        crc_cal_tx        <=#DELAY 0;
        crc_dv_tx         <=#DELAY 0;
        crc_dv_tx_reg     <=#DELAY 0;
        crc_dv_tx_reg0    <=#DELAY 0;
        crc_dv_tx_reg1    <=#DELAY 0;
        crc_tte_tx           <=#DELAY 0;
        ptp_tx_init           <=#DELAY 0;
        end
    else begin
        ptr_fifo_rd_tx<=#DELAY 0;
        data_fifo_rd_tx_reg_0<=#DELAY data_fifo_rd_tx;
        data_fifo_rd_tx_reg_1<=#DELAY data_fifo_rd_tx_reg_0;
        tx_sof          <=#DELAY 0;
        tx_sfd          <=#DELAY 0;
        tptr_fifo_rd_tx<=#DELAY 0;
        tdata_fifo_rd_tx_reg_0<=#DELAY tdata_fifo_rd_tx;
        tdata_fifo_rd_tx_reg_1<=#DELAY tdata_fifo_rd_tx_reg_0;
        t_tx_sof          <=#DELAY 0;
        t_tx_sfd          <=#DELAY 0;
        crc_init_tx       <=#DELAY 0;
        crc_cal_tx        <=#DELAY 0;
        crc_dv_tx         <=#DELAY 0;
        crc_dv_tx_reg0    <=#DELAY crc_dv_tx_reg;
        crc_dv_tx_reg1    <=#DELAY crc_dv_tx_reg0;
        ptp_tx_init           <=#DELAY 0;
        case(state_t)
        0:begin
            if(!tptr_fifo_empty_tx & !speed[1]) begin
                tptr_fifo_rd_tx<=#DELAY 1;
                crc_init_tx       <=#DELAY 1;
                crc_tte_tx           <=#DELAY 1;
                cnt_t   <=#DELAY 15;
                t_tx_sof  <=#DELAY 1;
                state_t<=#DELAY 8;
                end
            else if(!ptr_fifo_empty_tx & !speed[1]) begin
                ptr_fifo_rd_tx<=#DELAY 1;
                crc_init_tx       <=#DELAY 1;
                crc_tte_tx           <=#DELAY 0;
                cnt_t   <=#DELAY 15;
                tx_sof  <=#DELAY 1;
                state_t<=#DELAY 1;
                end
            end
        1:begin
            if(cnt_t>1) cnt_t<=#DELAY cnt_t-1;
            else begin
                tx_sfd  <=#DELAY 1;
                cnt_t   <=#DELAY ptr_fifo_dout_tx[10:0];
                data_fifo_rd_tx<=#DELAY 1;
                ptp_tx_init<=#DELAY 1;
                state_t<=#DELAY 3;
            end
        end
        3:begin
            crc_cal_tx        <=#DELAY 1;
            crc_dv_tx         <=#DELAY 1;
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
                cnt_t<=#DELAY 4;
                crc_dv_tx_reg    <=#DELAY 1;
                state_t<=#DELAY 5;
                end
            end
        5:begin
            crc_dv_tx_reg<=#DELAY 0;
            state_t <=#DELAY 6;
            end
        6:begin
            crc_dv_tx         <=#DELAY 1;
            if(cnt_t>1) begin
                cnt_t<=#DELAY cnt_t-1;
                crc_dv_tx_reg<=#DELAY 1;
                state_t <=#DELAY 5;
                end
            else begin
                cnt_t<=#DELAY 24;
                state_t<=#DELAY 7;
                end
            end
        7:begin
            if(cnt_t>0) cnt_t<=#DELAY cnt_t-1;
            else begin
                cnt_t   <=#DELAY 0;
                state_t <=#DELAY 0;
                end
            end
        8:begin
            if(cnt_t>1) cnt_t<=#DELAY cnt_t-1;
            else begin
                t_tx_sfd  <=#DELAY 1;
                cnt_t   <=#DELAY tptr_fifo_dout_tx[10:0];
                tdata_fifo_rd_tx<=#DELAY 1;
                state_t<=#DELAY 10;
            end
        end
        10:begin
            crc_cal_tx        <=#DELAY 1;
            crc_dv_tx         <=#DELAY 1;
            tdata_fifo_rd_tx<=#DELAY 0;
            state_t <=#DELAY 11;
            end
        11:begin
            if(cnt_t>1) begin
                tdata_fifo_rd_tx<=#DELAY 1;
                cnt_t<=#DELAY cnt_t-1;
                state_t <=#DELAY 10;
                end
            else begin
                tdata_fifo_rd_tx<=#DELAY 0;
                cnt_t<=#DELAY 4;
                crc_dv_tx_reg    <=#DELAY 1;
                state_t<=#DELAY 12;
                end
            end
        12:begin
            crc_dv_tx_reg<=#DELAY 0;
            state_t <=#DELAY 13;
            end
        13:begin
            crc_dv_tx         <=#DELAY 1;
            if(cnt_t>1) begin
                cnt_t<=#DELAY cnt_t-1;
                crc_dv_tx_reg<=#DELAY 1;
                state_t <=#DELAY 12;
                end
            else begin
                cnt_t<=#DELAY 24;
                state_t<=#DELAY 14;
                end
            end
        14:begin
            if(cnt_t>0) cnt_t<=#DELAY cnt_t-1;
            else begin
                cnt_t   <=#DELAY 0;
                state_t <=#DELAY 0;
                end
            end
        endcase
        end


//============================================  
//ptp tx state.   
//============================================  

reg [5:0]   ptp_tx_state;
reg [4:0]   ptp_tx_cnt;

reg [31:0]  counter_ns_tx_reg;

reg         sync_tx_flag;
reg         delay_tx_flag;

reg [63:0]  counter_ns_sync_tx_message;
reg [63:0]  counter_ns_delay_tx_message;


reg         ptp_tx_sel;
reg         ptp_tx_sel_reg0;
reg         ptp_tx_sel_reg1;


assign  counter_ns_tx_delay = counter_ns_delay_tx_message;

always @(posedge tx_clk or negedge rstn)
    if(!rstn) begin
        ptp_tx_state<=#DELAY 0;
        ptp_tx_cnt<=#DELAY 0;
        counter_ns_tx_reg<=#DELAY 0;
        counter_ns_sync_tx_message<=#DELAY 0;
        counter_ns_delay_tx_message<=#DELAY 0;
        sync_tx_flag<=#DELAY 0;
        delay_tx_flag<=#DELAY 0;
        ptp_tx_sel<=#DELAY 0;
        ptp_tx_sel_reg0<=#DELAY 0;
        ptp_tx_sel_reg1<=#DELAY 0;
        ptp_data_tx<=#DELAY 0;
        crc_ptp_tx_dv<=#DELAY 0;
        end
    else begin
        ptp_tx_sel_reg0<=#DELAY ptp_tx_sel;
        ptp_tx_sel_reg1<=#DELAY ptp_tx_sel_reg0;
        case(ptp_tx_state)
        0:begin
            crc_ptp_tx_dv<=#DELAY 0;
            if(ptp_tx_init)
            begin
                ptp_tx_state<=#DELAY 1;
            end
        end
        1:begin
            if(ptp_tx_cnt==24)
            begin
                ptp_tx_cnt<=#DELAY 0;
                ptp_tx_state<=#DELAY 2;
            end
            else
            begin
                ptp_tx_cnt<=#DELAY ptp_tx_cnt+1;
            end
        end
        2:begin
            if(data_fifo_dout_tx==PTP_VALUE_HIGH) ptp_tx_state<=#DELAY 3;
            else ptp_tx_state<=#DELAY 0;
        end
        3:begin
            ptp_tx_state<=#DELAY 4;
        end
        4:begin
            if(data_fifo_dout_tx==PTP_VALUE_LOWER) ptp_tx_state<=#DELAY 5;
            else ptp_tx_state<=#DELAY 0;
        end
        5:begin
            ptp_tx_state<=#DELAY 6;
        end
        6:begin
            if(data_fifo_dout_tx[3:0]==4'b0000)
            begin
                sync_tx_flag<=#DELAY 1;
                ptp_tx_state<=#DELAY 7;
            end
            else if(data_fifo_dout_tx[3:0]==4'b0001)
            begin
                delay_tx_flag<=#DELAY 1;
                ptp_tx_state<=#DELAY 7;
            end
            else if(data_fifo_dout_tx[3:0]==4'b1000)
            begin
                ptp_tx_state<=#DELAY 16;
            end
            else    ptp_tx_state<=#DELAY 0;
        end 
        7:begin
            if(ptp_tx_cnt==30)
            begin
                ptp_tx_cnt<=#DELAY 0;
                ptp_tx_state<=#DELAY 8;
            end
            else
            begin
                ptp_tx_cnt<=#DELAY ptp_tx_cnt+1;
            end
        end
        8:begin
            counter_ns_tx_reg[31:24]<=#DELAY data_fifo_dout_tx;
            ptp_tx_state<=#DELAY 9;
        end
        9:begin
            ptp_tx_state<=#DELAY 10;
        end
        10:begin
            counter_ns_tx_reg[23:16]<=#DELAY data_fifo_dout_tx;
            ptp_tx_state<=#DELAY 11;
        end
        11:begin
            ptp_tx_state<=#DELAY 12;
        end
        12:begin
            counter_ns_tx_reg[15:8]<=#DELAY data_fifo_dout_tx;
            ptp_tx_state<=#DELAY 13;
        end
        13:begin
            ptp_tx_state<=#DELAY 14;
        end
        14:begin
            counter_ns_tx_reg[7:0]<=#DELAY data_fifo_dout_tx;
            ptp_tx_state<=#DELAY 15;
        end
        15:begin
            if(sync_tx_flag)
            begin
                if(counter_ns_tx_reg[31]^counter_ns[31])
                    counter_ns_sync_tx_message[47:16]<=#DELAY 32'h8000_0000+counter_ns[30:0]-counter_ns_tx_reg[30:0];
                else
                    counter_ns_sync_tx_message[47:16]<=#DELAY counter_ns[30:0]-counter_ns_tx_reg[30:0];
            end
            else if(delay_tx_flag)
            begin
                if(counter_ns_tx_reg[31]^counter_ns[31])
                    counter_ns_delay_tx_message[47:16]<=#DELAY 32'h8000_0000+counter_ns[30:0]-counter_ns_tx_reg[30:0];
                else
                    counter_ns_delay_tx_message[47:16]<=#DELAY counter_ns[30:0]-counter_ns_tx_reg[30:0];
            end
            sync_tx_flag<=#DELAY 0;
            delay_tx_flag<=#DELAY 0;
            ptp_tx_state<=#DELAY 0;
        end
        16:begin
            if(ptp_tx_cnt==11)
            begin
                ptp_tx_cnt<=#DELAY 0;
                counter_ns_sync_tx_message<=#DELAY counter_ns_sync_message + counter_ns_sync_tx_message;
                ptp_tx_state<=#DELAY 17;
            end
            else
            begin
                ptp_tx_cnt<=#DELAY ptp_tx_cnt+1;
            end
        end
        17:begin
            ptp_tx_sel<=#DELAY 1;
            ptp_tx_state<=#DELAY 18;
        end
        18:begin
            crc_ptp_tx_dv<=#DELAY 1;
            ptp_tx_sel<=#DELAY 0;
            ptp_data_tx<=#DELAY counter_ns_sync_tx_message[63:56];
            ptp_tx_state<=#DELAY 19;
        end
        19:begin
            ptp_tx_sel<=#DELAY 1;
            ptp_tx_state<=#DELAY 20;
        end
        20:begin
            ptp_tx_sel<=#DELAY 0;
            ptp_data_tx<=#DELAY counter_ns_sync_tx_message[55:48];
            ptp_tx_state<=#DELAY 21;
        end
        21:begin
            ptp_tx_sel<=#DELAY 1;
            ptp_tx_state<=#DELAY 22;
        end
        22:begin
            ptp_tx_sel<=#DELAY 0;
            ptp_data_tx<=#DELAY counter_ns_sync_tx_message[47:40];
            ptp_tx_state<=#DELAY 23;
        end
        23:begin
            ptp_tx_sel<=#DELAY 1;
            ptp_tx_state<=#DELAY 24;
        end
        24:begin
            ptp_tx_sel<=#DELAY 0;
            ptp_data_tx<=#DELAY counter_ns_sync_tx_message[39:32];
            ptp_tx_state<=#DELAY 25;
        end
        25:begin
            ptp_tx_sel<=#DELAY 1;
            ptp_tx_state<=#DELAY 26;
        end
        26:begin
            ptp_tx_sel<=#DELAY 0;
            ptp_data_tx<=#DELAY counter_ns_sync_tx_message[31:24];
            ptp_tx_state<=#DELAY 27;
        end
        27:begin
            ptp_tx_sel<=#DELAY 1;
            ptp_tx_state<=#DELAY 28;
        end
        28:begin
            ptp_tx_sel<=#DELAY 0;
            ptp_data_tx<=#DELAY counter_ns_sync_tx_message[23:16];
            ptp_tx_state<=#DELAY 29;
        end
        29:begin
            ptp_tx_sel<=#DELAY 1;
            ptp_tx_state<=#DELAY 30;
        end
        30:begin
            ptp_tx_sel<=#DELAY 0;
            ptp_data_tx<=#DELAY counter_ns_sync_tx_message[15:8];
            ptp_tx_state<=#DELAY 31;
        end
        31:begin
            ptp_tx_sel<=#DELAY 1;
            ptp_tx_state<=#DELAY 32;
        end
        32:begin
            ptp_tx_sel<=#DELAY 0;
            ptp_data_tx<=#DELAY counter_ns_sync_tx_message[7:0];
            ptp_tx_state<=#DELAY 33;
        end
        33:begin
            ptp_tx_state<=#DELAY 0;
        end
    endcase
    end


//============================================  
//tx state.   
//============================================ 
reg     tx_dv;
reg     [3:0]   tx_d;
// wire    tx_dv_i;
// assign  tx_dv_i=(data_fifo_rd_tx_reg_0|data_fifo_rd_tx_reg_1|crc_dv_tx_reg0|crc_dv_tx_reg1)&(!speed[1]);
// wire    t_tx_dv_i;
// assign  t_tx_dv_i=(tdata_fifo_rd_tx_reg_0|tdata_fifo_rd_tx_reg_1|crc_dv_tx_reg0|crc_dv_tx_reg1)&(!speed[1]);
reg     [2:0]   state_tx;
always @(posedge tx_clk or negedge rstn) 
    if(!rstn) begin
        state_tx<=#DELAY 0;
        tx_dv<=#DELAY 0;
        tx_d<=#DELAY 0;
        end
    else begin
        // tx_dv<=#DELAY tx_dv_i|t_tx_dv_i;
        case(state_tx)
        0:begin
            if(t_tx_sof)
            begin
                tx_d<=#DELAY 4'h5;
                tx_dv<=#DELAY 1;
                state_tx<=#DELAY 3;
            end
            else if(tx_sof)
            begin
                tx_d<=#DELAY 4'h5;
                tx_dv<=#DELAY 1;
                state_tx<=#DELAY 1;
            end
        end
        1:begin
            if(tx_sfd)
            begin
                tx_d<=#DELAY 4'hd;
                state_tx<=#DELAY 2;
            end
        end
        2:begin
            if(ptp_tx_sel_reg0)             tx_d<=#DELAY ptp_data_tx[3:0];
            else if(ptp_tx_sel_reg1)        tx_d<=#DELAY ptp_data_tx[7:4];
            else if(data_fifo_rd_tx_reg_0)  tx_d<=#DELAY data_fifo_dout_tx[3:0];
            else if(data_fifo_rd_tx_reg_1)  tx_d<=#DELAY data_fifo_dout_tx[7:4];
            else if(crc_dv_tx_reg0)         tx_d<=#DELAY crc_dout_tx[3:0];
            else if(crc_dv_tx_reg1)         tx_d<=#DELAY crc_dout_tx[7:4];
            else begin
                tx_d<=#DELAY 0;
                tx_dv<=#DELAY 0;
                state_tx<=#DELAY 0;
                end
            end
        3:begin
            if(t_tx_sfd)
            begin
                tx_d<=#DELAY 4'hd;
                state_tx<=#DELAY 4;
            end
        end
        4:begin
            if(tdata_fifo_rd_tx_reg_0)        tx_d<=#DELAY tdata_fifo_dout_tx[3:0];
            else if(tdata_fifo_rd_tx_reg_1)   tx_d<=#DELAY tdata_fifo_dout_tx[7:4];
            else if(crc_dv_tx_reg0)           tx_d<=#DELAY crc_dout_tx[3:0];
            else if(crc_dv_tx_reg1)           tx_d<=#DELAY crc_dout_tx[7:4];
            else begin
                tx_d<=#DELAY 0;
                tx_dv<=#DELAY 0;
                state_tx<=#DELAY 0;
                end
            end
        endcase
        end



reg     [10:0]  gcnt_t;
reg     [3:0]       state_gt;
reg             data_fifo_rd_gtx_reg;
reg             gtx_sof;
reg             gtx_sfd;
reg             tdata_fifo_rd_gtx_reg;
reg             t_gtx_sof;
reg             t_gtx_sfd;
reg             crc_dv_gtx_reg;
reg             crc_dv_gtx_dv;
reg             crc_tte_gtx;

//============================================  
//crc gtx singal.   
//============================================ 

reg        		crc_init_gtx;
wire	[7:0]  	crc_din_gtx;
reg         	crc_cal_gtx;
reg         	crc_dv_gtx;
wire	[31:0]  crc_result_gtx;
wire	[7:0]   crc_dout_gtx;

reg             crc_ptp_gtx_dv;
reg [7:0]       ptp_data_gtx;

crc32_8023 u_crc32_8023_gtx(
    .clk(gtx_clk), 
    .reset(!rstn), 
    .d(crc_din_gtx), 
    .load_init(crc_init_gtx),
    .calc(crc_cal_gtx), 
    .d_valid(crc_dv_gtx), 
    .crc_reg(crc_result_gtx), 
    .crc(crc_dout_gtx)
    );

assign crc_din_gtx = (crc_ptp_gtx_dv==1)? ptp_data_gtx:(crc_tte_gtx==1)? tdata_fifo_dout_gtx : data_fifo_dout_gtx;

//============================================  
//ptp gtx singal.   
//============================================  

reg         ptp_gtx_init;

always @(posedge gtx_clk or negedge rstn) 
    if(!rstn) begin
        state_gt         <=#DELAY 0;
        gcnt_t           <=#DELAY 0;
        data_fifo_rd_gtx  <=#DELAY 0;
        ptr_fifo_rd_gtx   <=#DELAY 0;
        data_fifo_rd_gtx_reg<=#DELAY 0;
        gtx_sof          <=#DELAY 0;
        gtx_sfd          <=#DELAY 0;
        tdata_fifo_rd_gtx  <=#DELAY 0;
        tptr_fifo_rd_gtx   <=#DELAY 0;
        tdata_fifo_rd_gtx_reg<=#DELAY 0;
        t_gtx_sof          <=#DELAY 0;
        t_gtx_sfd          <=#DELAY 0;
        crc_init_gtx       <=#DELAY 0;
        crc_cal_gtx        <=#DELAY 0;
        crc_dv_gtx         <=#DELAY 0;
        crc_dv_gtx_reg     <=#DELAY 0;
        crc_dv_gtx_dv      <=#DELAY 0;
        crc_tte_gtx        <=#DELAY 0;
        ptp_gtx_init        <=#DELAY 0;
        end
    else begin
        ptr_fifo_rd_gtx<=#DELAY 0;
        data_fifo_rd_gtx_reg<=#DELAY data_fifo_rd_gtx;
        gtx_sof          <=#DELAY 0;
        gtx_sfd          <=#DELAY 0;
        tptr_fifo_rd_gtx<=#DELAY 0;
        tdata_fifo_rd_gtx_reg<=#DELAY tdata_fifo_rd_gtx;
        t_gtx_sof          <=#DELAY 0;
        t_gtx_sfd          <=#DELAY 0;
        crc_init_gtx       <=#DELAY 0;
        crc_cal_gtx        <=#DELAY 0;
        crc_dv_gtx         <=#DELAY 0;
        crc_dv_gtx_reg     <=#DELAY crc_dv_gtx_dv;
        ptp_gtx_init        <=#DELAY 0;
        case(state_gt)
        0:begin
            if(!tptr_fifo_empty_gtx & speed[1]) begin
                tptr_fifo_rd_gtx<=#DELAY 1;
                crc_init_gtx       <=#DELAY 1;
                crc_tte_gtx        <=#DELAY 1;
                gcnt_t           <=#DELAY 7;
                t_gtx_sof  <=#DELAY 1;
                state_gt<=#DELAY 6;
                end
            else if(!ptr_fifo_empty_gtx & speed[1]) begin
                ptr_fifo_rd_gtx<=#DELAY 1;
                crc_init_gtx       <=#DELAY 1;
                crc_tte_gtx        <=#DELAY 0;
                gcnt_t           <=#DELAY 7;
                gtx_sof  <=#DELAY 1;
                state_gt<=#DELAY 1;
                end
            end
        1:begin
            if(gcnt_t>1) gcnt_t<=#DELAY gcnt_t-1;
            else begin
                gtx_sfd  <=#DELAY 1;
                gcnt_t   <=#DELAY ptr_fifo_dout_gtx[10:0];
                data_fifo_rd_gtx<=#DELAY 1;
                ptp_gtx_init        <=#DELAY 1;
                state_gt<=#DELAY 3;
            end
        end
        3:begin //data ready
            crc_cal_gtx        <=#DELAY 1;
            crc_dv_gtx         <=#DELAY 1;
            if(gcnt_t>1) begin
                gcnt_t<=#DELAY gcnt_t-1;
                end
            else begin
                data_fifo_rd_gtx<=#DELAY 0;
                gcnt_t<=#DELAY 4;
                crc_dv_gtx_dv     <=#DELAY 1;
                state_gt<=#DELAY 4;
                end
            end
        4:begin
            crc_dv_gtx         <=#DELAY 1;
            if(gcnt_t>1) begin
                gcnt_t<=#DELAY gcnt_t-1;
                end
            else begin
                crc_dv_gtx_dv     <=#DELAY 0;
                gcnt_t<=#DELAY 12;
                state_gt<=#DELAY 5;
                end
            end
        5:begin
            if(gcnt_t>0) gcnt_t<=#DELAY gcnt_t-1;
            else begin
                gcnt_t   <=#DELAY 0;
                state_gt <=#DELAY 0;
                end
            end
        6:begin
            if(gcnt_t>1) gcnt_t<=#DELAY gcnt_t-1;
            else begin
                t_gtx_sfd  <=#DELAY 1;
                gcnt_t   <=#DELAY tptr_fifo_dout_gtx[10:0];
                tdata_fifo_rd_gtx<=#DELAY 1;
                state_gt<=#DELAY 8;
            end
        end
        8:begin
            crc_cal_gtx        <=#DELAY 1;
            crc_dv_gtx         <=#DELAY 1;
            if(gcnt_t>1) begin
                gcnt_t<=#DELAY gcnt_t-1;
                end
            else begin
                tdata_fifo_rd_gtx<=#DELAY 0;
                gcnt_t<=#DELAY 4;
                crc_dv_gtx_dv     <=#DELAY 1;
                state_gt<=#DELAY 9;
                end
            end
        9:begin
            crc_dv_gtx         <=#DELAY 1;
            if(gcnt_t>1) begin
                gcnt_t<=#DELAY gcnt_t-1;
                end
            else begin
                crc_dv_gtx_dv     <=#DELAY 0;
                gcnt_t<=#DELAY 12;
                state_gt<=#DELAY 10;
                end
            end
        10:begin
            if(gcnt_t>0) gcnt_t<=#DELAY gcnt_t-1;
            else begin
                gcnt_t   <=#DELAY 0;
                state_gt <=#DELAY 0;
                end
            end
        endcase
        end


//============================================  
//ptp gtx state.   
//============================================  

reg [4:0]   ptp_gtx_state;
reg [4:0]   ptp_gtx_cnt;

reg [31:0]  counter_ns_gtx_reg;

reg         sync_gtx_flag;
reg         delay_gtx_flag;

reg [63:0]  counter_ns_sync_gtx_message;
reg [63:0]  counter_ns_delay_gtx_message;

reg         ptp_gtx_sel;
reg         ptp_gtx_sel_reg;

assign  counter_ns_gtx_delay = counter_ns_delay_gtx_message;

always @(posedge gtx_clk or negedge rstn)
    if(!rstn) begin
        ptp_gtx_state<=#DELAY 0;
        ptp_gtx_cnt<=#DELAY 0;
        counter_ns_gtx_reg<=#DELAY 0;
        counter_ns_sync_gtx_message<=#DELAY 0;
        counter_ns_delay_gtx_message<=#DELAY 0;
        sync_gtx_flag<=#DELAY 0;
        delay_gtx_flag<=#DELAY 0;
        ptp_gtx_sel<=#DELAY 0;
        ptp_gtx_sel_reg<=#DELAY 0;
        ptp_data_gtx<=#DELAY 0;
        crc_ptp_gtx_dv<=#DELAY 0;
        end
    else begin
        ptp_gtx_sel_reg<=#DELAY ptp_gtx_sel;
        case(ptp_gtx_state)
        0:begin
            crc_ptp_gtx_dv<=#DELAY 0;
            if(ptp_gtx_init)
            begin
                ptp_gtx_state<=#DELAY 1;
            end
        end
        1:begin
            if(ptp_gtx_cnt==11)
            begin
                ptp_gtx_cnt<=#DELAY 0;
                ptp_gtx_state<=#DELAY 2;
            end
            else
            begin
                ptp_gtx_cnt<=#DELAY ptp_gtx_cnt+1;
            end
        end
        2:begin
            if(data_fifo_dout_gtx==PTP_VALUE_HIGH) ptp_gtx_state<=#DELAY 3;
            else ptp_gtx_state<=#DELAY 0;
        end
        3:begin
            if(data_fifo_dout_gtx==PTP_VALUE_LOWER) ptp_gtx_state<=#DELAY 4;
            else ptp_gtx_state<=#DELAY 0;
        end
        4:begin
            if(data_fifo_dout_gtx[3:0]==4'b0000) 
            begin 
                sync_gtx_flag<=#DELAY 1;
                ptp_gtx_state<=#DELAY 5;
            end
            else if(data_fifo_dout_gtx[3:0]==4'b0001) 
            begin
                delay_gtx_flag<=#DELAY 1;
                ptp_gtx_state<=#DELAY 5;
            end
            else if(data_fifo_dout_gtx[3:0]==4'b1000) 
            begin
                ptp_gtx_state<=#DELAY 11;
            end
            else    ptp_gtx_state<=#DELAY 0;
        end 
        5:begin
            if(ptp_gtx_cnt==14)
            begin
                ptp_gtx_cnt<=#DELAY 0;
                ptp_gtx_state<=#DELAY 6;
            end
            else
            begin
                ptp_gtx_cnt<=#DELAY ptp_gtx_cnt+1;
            end
        end
        6:begin
            counter_ns_gtx_reg[31:24]<=#DELAY data_fifo_dout_gtx;
            ptp_gtx_state<=#DELAY 7;
        end
        7:begin
            counter_ns_gtx_reg[23:16]<=#DELAY data_fifo_dout_gtx;
            ptp_gtx_state<=#DELAY 8;
        end
        8:begin
            counter_ns_gtx_reg[15:8]<=#DELAY data_fifo_dout_gtx;
            ptp_gtx_state<=#DELAY 9;
        end
        9:begin
            counter_ns_gtx_reg[7:0]<=#DELAY data_fifo_dout_gtx;
            ptp_gtx_state<=#DELAY 10;
        end
        10:begin
            if(sync_gtx_flag)
            begin
                if(counter_ns_gtx_reg[31]^counter_ns[31])
                    counter_ns_sync_gtx_message[47:16]<=#DELAY 32'h8000_0000+counter_ns[30:0]-counter_ns_gtx_reg[30:0];
                else
                    counter_ns_sync_gtx_message[47:16]<=#DELAY counter_ns[30:0]-counter_ns_gtx_reg[30:0];
            end
            else if(delay_gtx_flag)
            begin
                if(counter_ns_gtx_reg[31]^counter_ns[31])
                    counter_ns_delay_gtx_message[47:16]<=#DELAY 32'h8000_0000+counter_ns[30:0]-counter_ns_gtx_reg[30:0];
                else
                    counter_ns_delay_gtx_message[47:16]<=#DELAY counter_ns[30:0]-counter_ns_gtx_reg[30:0];
            end
            sync_gtx_flag<=#DELAY 0;
            delay_gtx_flag<=#DELAY 0;
            ptp_gtx_state<=#DELAY 0;
        end
        11:begin
            if(ptp_gtx_cnt==5)
            begin
                ptp_gtx_cnt<=#DELAY 0;
                counter_ns_sync_gtx_message<=#DELAY counter_ns_sync_message + counter_ns_sync_gtx_message;
                ptp_gtx_sel<=#DELAY 1;
                ptp_gtx_state<=#DELAY 12;
            end
            else
            begin
                ptp_gtx_cnt<=#DELAY ptp_gtx_cnt+1;
            end
        end
        12:begin
            crc_ptp_gtx_dv<=#DELAY 1;
            ptp_data_gtx<=#DELAY counter_ns_sync_gtx_message[63:56];
            ptp_gtx_state<=#DELAY 13;
        end
        13:begin
            ptp_data_gtx<=#DELAY counter_ns_sync_gtx_message[55:48];
            ptp_gtx_state<=#DELAY 14;
        end
        14:begin
            ptp_data_gtx<=#DELAY counter_ns_sync_gtx_message[47:40];
            ptp_gtx_state<=#DELAY 15;
        end
        15:begin
            ptp_data_gtx<=#DELAY counter_ns_sync_gtx_message[39:32];
            ptp_gtx_state<=#DELAY 16;
        end
        16:begin
            ptp_data_gtx<=#DELAY counter_ns_sync_gtx_message[31:24];
            ptp_gtx_state<=#DELAY 17;
        end
        17:begin
            ptp_data_gtx<=#DELAY counter_ns_sync_gtx_message[23:16];
            ptp_gtx_state<=#DELAY 18;
        end
        18:begin
            ptp_data_gtx<=#DELAY counter_ns_sync_gtx_message[15:8];
            ptp_gtx_state<=#DELAY 19;
        end
        19:begin
            ptp_gtx_sel<=#DELAY 0;
            ptp_data_gtx<=#DELAY counter_ns_sync_gtx_message[7:0];
            ptp_gtx_state<=#DELAY 0;
        end
    endcase
    end

reg     gtx_dv_rg;
reg     [7:0]   gtx_d;
// wire    gtx_dv_i;
// assign  gtx_dv_i=data_fifo_rd_gtx_reg&(speed[1]);
// wire    t_gtx_dv_i;
// assign  t_gtx_dv_i=tdata_fifo_rd_gtx_reg&(speed[1]);
reg     [2:0]   state_gtx;
always @(posedge gtx_clk or negedge rstn) 
    if(!rstn) begin
        state_gtx<=#DELAY 0;
        gtx_dv_rg<=#DELAY 0;
        gtx_d<=#DELAY 0;
        end
    else begin
        // gtx_dv_rg<=#DELAY gtx_dv_i|t_gtx_dv_i;
        case(state_gtx)
        0:begin
            if(t_gtx_sof)
            begin
                gtx_d<=#DELAY 8'h55;
                gtx_dv_rg<=#DELAY 1;
                state_gtx<=#DELAY 3;
            end
            else if(gtx_sof)
            begin
                gtx_d<=#DELAY 8'h55;
                gtx_dv_rg<=#DELAY 1;
                state_gtx<=#DELAY 1;
            end
        end
        1:begin
            if(gtx_sfd)
            begin
                gtx_d<=#DELAY 8'hd5;
                state_gtx<=#DELAY 2;
            end
        end
        2:begin
            if(ptp_gtx_sel_reg)             gtx_d<=#DELAY ptp_data_gtx;
            else if(data_fifo_rd_gtx_reg)   gtx_d<=#DELAY data_fifo_dout_gtx;
            else if(crc_dv_gtx_reg)         gtx_d<=#DELAY crc_dout_gtx;
            else begin
                gtx_d<=#DELAY 0;
                gtx_dv_rg<=#DELAY 0;
                state_gtx<=#DELAY 0;
                end
            end
        3:begin
            if(t_gtx_sfd)
            begin
                gtx_d<=#DELAY 8'hd5;
                state_gtx<=#DELAY 4;
            end
        end
        4:begin
            if(tdata_fifo_rd_gtx_reg)        gtx_d<=#DELAY tdata_fifo_dout_gtx;
            else if(crc_dv_gtx_reg)         gtx_d<=#DELAY crc_dout_gtx;
            else begin
                gtx_d<=#DELAY 0;
                gtx_dv_rg<=#DELAY 0;
                state_gtx<=#DELAY 0;
                end
            end
        endcase
        end

assign  gtx_dv = (speed[1]==1)? gtx_dv_rg : tx_dv;
assign  gm_tx_d = (speed[1]==1)? gtx_d : {4'b0,tx_d};
endmodule
