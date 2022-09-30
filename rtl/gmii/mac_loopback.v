`timescale 1ns / 1ps
module mac_loopback(
input				clk,
input				rstn,
output	reg			rx_data_fifo_rd,
input		[7:0]	rx_data_fifo_din,
output	reg			rx_ptr_fifo_rd, 
input		[15:0]	rx_ptr_fifo_din,
input				rx_ptr_fifo_empty,
input				tx_data_fifo_rd,
output		[7:0]  	tx_data_fifo_dout,
input				tx_ptr_fifo_rd, 
output		[15:0]	tx_ptr_fifo_dout,
output				tx_ptr_fifo_empty
    );
parameter	DELAY=2;

reg					data_fifo_wr;
reg		[15:0]   	ptr_fifo_din;
reg					ptr_fifo_wr;
wire			    ptr_fifo_full;
wire	[11:0]		data_fifo_depth;
wire			    bp;
reg		[10:0]		cnt;
reg					frame_valid;
reg					crc_dv;

assign bp=ptr_fifo_full | (data_fifo_depth>2560);
reg		[2:0]	state;
always @(posedge clk or negedge rstn) 
	if(!rstn)begin
		rx_data_fifo_rd<=#DELAY 0;
		rx_ptr_fifo_rd<=#DELAY 0;
		data_fifo_wr	<=#DELAY 0;
		ptr_fifo_din	<=#DELAY 0;
		ptr_fifo_wr		<=#DELAY 0;
		cnt				<=#DELAY 0;
		frame_valid		<=#DELAY 0;
		crc_dv			<=#DELAY 0;
		state			<=#DELAY 0;
		end
	else begin
		ptr_fifo_wr	<=#DELAY 0;
		data_fifo_wr<=#DELAY rx_data_fifo_rd & frame_valid & !crc_dv;
		case(state)
		0:begin	
			frame_valid<=#DELAY 0;	
			crc_dv<=#DELAY 0;
			if(!rx_ptr_fifo_empty & !bp)begin
				rx_ptr_fifo_rd	<=#DELAY 1;
				state			<=#DELAY 1;
				end
			end
		1:begin
			rx_ptr_fifo_rd	<=#DELAY 0;
			state			<=#DELAY 2;
			end
		2:begin
			cnt				<=#DELAY rx_ptr_fifo_din[10:0];
			if(rx_ptr_fifo_din[15:14]==2'b00) frame_valid<=#DELAY 1;
			else frame_valid<=#DELAY 0;
			rx_data_fifo_rd	<=#DELAY 1;
			state			<=#DELAY 3;
			end
		3:begin
			if(cnt>1) cnt<=#DELAY cnt-1;
			else begin
				rx_data_fifo_rd	<=#DELAY 0;
				ptr_fifo_din	<=#DELAY rx_ptr_fifo_din[10:0]-4;
				ptr_fifo_wr		<=#DELAY frame_valid;
				state<=#2 0;
				end
			if(cnt<=5) crc_dv<=#DELAY 1;
			end
		endcase
		end

sfifo_w8_d4k u_data_fifo (
  .clk(clk), 					// input clk
  .srst(!rstn), 					// input rst
  .din(rx_data_fifo_din),		// input [7 : 0] din
  .wr_en(data_fifo_wr), 		// input wr_en
  .rd_en(tx_data_fifo_rd),		// input rd_en
  .dout(tx_data_fifo_dout), 	// output [7 : 0] dout
  .full(), 						// output full
  .empty(), 					// output empty
  .data_count(data_fifo_depth)	// output [11 : 0] data_count
);

sfifo_w16_d32 u_ptr_fifo (
  .clk(clk), 				// input clk
  .srst(!rstn), 				// input rst
  .din(ptr_fifo_din), 		// input [15 : 0] din
  .wr_en(ptr_fifo_wr),		// input wr_en
  .rd_en(tx_ptr_fifo_rd), 	// input rd_en
  .dout(tx_ptr_fifo_dout), 	// output [15 : 0] dout
  .full(ptr_fifo_full), 	// output full
  .empty(tx_ptr_fifo_empty), // output empty
  .data_count() 			// output [4 : 0] data_count
);
endmodule
