`timescale 1ns / 1ps
module mac_t_tb;
// Inputs
reg rstn;
reg clk;
reg tx_clk;
// Outputs
wire tx_dv;
wire [3:0] tx_d;
always #5 clk=~clk;
always #20 tx_clk=~tx_clk;
// Instantiate the Unit Under Test (UUT)
reg		[7:0]	data_fifo_din;
reg				data_fifo_wr;
wire			data_fifo_rd;
wire 	[7:0] 	data_fifo_dout;
wire	[11:0]	data_fifo_depth;

reg		[15:0]  ptr_fifo_din;
reg				ptr_fifo_wr;
wire			ptr_fifo_rd;
wire	[15:0]	ptr_fifo_dout;
wire			ptr_fifo_full;
wire			ptr_fifo_empty;

mac_t u_mac_t_pad (
	.rstn(rstn), 
	.clk(clk), 
	.tx_clk(tx_clk), 
	.tx_dv(tx_dv), 
	.tx_d(tx_d), 
	.data_fifo_rd(data_fifo_rd), 
	.data_fifo_din(data_fifo_dout), 
	.ptr_fifo_rd(ptr_fifo_rd), 
	.ptr_fifo_din(ptr_fifo_dout), 
	.ptr_fifo_empty(ptr_fifo_empty)
);

initial begin
	// Initialize Inputs
	rstn = 0;
	clk = 0;
	tx_clk = 0;

	data_fifo_din=0;
	data_fifo_wr=0;
	ptr_fifo_din=0;
	ptr_fifo_wr=0;

	// Wait 100 ns for global reset to finish
	#100;
    rstn=1;
	// Add stimulus here
	#1000;
	send_frame(100);
	send_frame(58);
	send_frame(60);
	send_frame(1514);
end

task send_frame;
input	[10:0]	len;
integer			i;
begin
	$display ("start to send frame");
	repeat(1)@(posedge clk);
	#2;
	while(ptr_fifo_full | (data_fifo_depth>2578)) repeat(1)@(posedge clk);
	#2;
	for(i=0;i<len;i=i+1)begin
		data_fifo_wr=1;
		data_fifo_din=($random)%256;
		repeat(1)@(posedge clk);
		#2;
		end
	data_fifo_wr=0;
	ptr_fifo_din={5'b0,len[10:0]};
	ptr_fifo_wr=1;
	repeat(1)@(posedge clk);
	#2;
	ptr_fifo_wr=0;
	$display ("end to send frame");
	end
endtask

sfifo_w8_d4k u_data_fifo (
  .clk(clk), 				// input clk
  .srst(!rstn), 				// input rst
  .din(data_fifo_din), 		// input [7 : 0] din
  .wr_en(data_fifo_wr), 	// input wr_en
  .rd_en(data_fifo_rd), 	// input rd_en
  .dout(data_fifo_dout), 	// output [7 : 0] dout
  .full(), 					// output full
  .empty(), 				// output empty
  .data_count(data_fifo_depth) 	// output [11 : 0] data_count
);

sfifo_w16_d32 u_ptr_fifo (
  .clk(clk), 				// input clk
  .srst(!rstn), 				// input rst
  .din(ptr_fifo_din), 		// input [15 : 0] din
  .wr_en(ptr_fifo_wr), 		// input wr_en
  .rd_en(ptr_fifo_rd), 		// input rd_en
  .dout(ptr_fifo_dout),  	// output [15 : 0] dout
  .full(ptr_fifo_full), 	    // output full
  .empty(ptr_fifo_empty), 	// output empty
  .data_count() 			// output [4 : 0] data_count
);
endmodule
