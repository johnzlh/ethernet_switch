`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/14 19:37:44
// Design Name: 
// Module Name: mac_t_gmii_tb
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


module mac_t_gmii_tb;
// Inputs
reg rstn;
reg clk;
reg tx_clk;
reg gtx_clk;
reg [1:0] speed;//ethernet speed 00:10M 01:100M 10:1000M
reg	status_fifo_rd;
reg	[31:0]	counter_ns;
// Outputs
wire gtx_dv;
wire [7:0] gm_tx_d;
wire [15:0] status_fifo_dout;
wire status_fifo_empty;	
wire [63:0] counter_ns_tx_delay;
wire [63:0] counter_ns_gtx_delay;

always #2.5 clk=~clk;
always #20 tx_clk=~tx_clk;
always #4  gtx_clk=~gtx_clk;
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

reg		[7:0]	tdata_fifo_din;
reg				tdata_fifo_wr;
wire			tdata_fifo_rd;
wire 	[7:0] 	tdata_fifo_dout;
wire	[11:0]	tdata_fifo_depth;

reg		[15:0]  tptr_fifo_din;
reg				tptr_fifo_wr;
wire			tptr_fifo_rd;
wire	[15:0]	tptr_fifo_dout;
wire			tptr_fifo_full;
wire			tptr_fifo_empty;


mac_t_gmii u_mac_t_gmii (
	.rstn(rstn), 
	.clk(clk), 
	.tx_clk(tx_clk), 
	.gtx_clk(gtx_clk),
	.gtx_dv(gtx_dv), 
	.gm_tx_d(gm_tx_d), 
	.speed(speed),
	.data_fifo_rd(data_fifo_rd), 
	.data_fifo_din(data_fifo_dout), 
	.ptr_fifo_rd(ptr_fifo_rd), 
	.ptr_fifo_din(ptr_fifo_dout), 
	.ptr_fifo_empty(ptr_fifo_empty),
	.tdata_fifo_rd(tdata_fifo_rd),
	.tdata_fifo_din(tdata_fifo_dout),
	.tptr_fifo_rd(tptr_fifo_rd),
	.tptr_fifo_din(tptr_fifo_dout),
	.tptr_fifo_empty(tptr_fifo_empty),
	.status_fifo_rd(status_fifo_rd),
	.status_fifo_dout(status_fifo_dout),
	.status_fifo_empty(status_fifo_empty),
	.counter_ns(counter_ns),
	.counter_ns_tx_delay(counter_ns_tx_delay),
	.counter_ns_gtx_delay(counter_ns_gtx_delay)
);

initial begin
	// Initialize Inputs
	rstn = 0;
	clk = 0;
	tx_clk = 0;
	gtx_clk = 0;

	data_fifo_din=0;
	data_fifo_wr=0;
	ptr_fifo_din=0;
	ptr_fifo_wr=0;
	tdata_fifo_din=0;
	tdata_fifo_wr=0;
	tptr_fifo_din=0;
	tptr_fifo_wr=0;
	status_fifo_rd = 0;
	speed[1:0] = 2'b01;//ethernet speed 00:10M 01:100M 10:1000M

	// Wait 100 ns for global reset to finish
	#100;
    rstn=1;
	// Add stimulus here
	#1000;
	// send_frame(1514);
	// send_frame(100);
	send_frame(58);
	send_frame(60);
	send_frame(60);
	send_frame(60);
	send_frame(1514);
	send_frame(100);
	send_tteframe(300);
	// send_tteframe(58);
	
end

reg	[31:0]	counter;
initial	begin
	counter_ns = 0;
	counter = 0;
end

always @(posedge clk)    
begin                                  
    counter <=#2 counter+1;
end


always @(*)    
begin                  
	counter_ns = (counter<<2)+counter; // counter_ns=counter*5
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

task send_tteframe;
input	[10:0]	len;
integer			i;
begin
	$display ("start to send tteframe");
	repeat(1)@(posedge clk);
	#2;
	while(tptr_fifo_full | (tdata_fifo_depth>2578)) repeat(1)@(posedge clk);
	#2;
	for(i=0;i<len;i=i+1)begin
		tdata_fifo_wr=1;
		tdata_fifo_din=($random)%256;
		repeat(1)@(posedge clk);
		#2;
		end
	tdata_fifo_wr=0;
	tptr_fifo_din={5'b0,len[10:0]};
	tptr_fifo_wr=1;
	repeat(1)@(posedge clk);
	#2;
	tptr_fifo_wr=0;
	$display ("end to send tteframe");
	end
endtask

sfifo_w8_d4k u_data_fifo (
  .clk(clk), 				// input clk
  .rst(!rstn), 				// input rst
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
  .rst(!rstn), 				// input rst
  .din(ptr_fifo_din), 		// input [15 : 0] din
  .wr_en(ptr_fifo_wr), 		// input wr_en
  .rd_en(ptr_fifo_rd), 		// input rd_en
  .dout(ptr_fifo_dout),  	// output [15 : 0] dout
  .full(ptr_fifo_full), 	    // output full
  .empty(ptr_fifo_empty), 	// output empty
  .data_count() 			// output [4 : 0] data_count
);

sfifo_w8_d4k u_tte_fifo (
  .clk(clk), 				// input clk
  .rst(!rstn), 				// input rst
  .din(tdata_fifo_din), 		// input [7 : 0] din
  .wr_en(tdata_fifo_wr), 	// input wr_en
  .rd_en(tdata_fifo_rd), 	// input rd_en
  .dout(tdata_fifo_dout), 	// output [7 : 0] dout
  .full(), 					// output full
  .empty(), 				// output empty
  .data_count(tdata_fifo_depth) 	// output [11 : 0] data_count
);

sfifo_w16_d32 u_tteptr_fifo (
  .clk(clk), 				// input clk
  .rst(!rstn), 				// input rst
  .din(tptr_fifo_din), 		// input [15 : 0] din
  .wr_en(tptr_fifo_wr), 		// input wr_en
  .rd_en(tptr_fifo_rd), 		// input rd_en
  .dout(tptr_fifo_dout),  	// output [15 : 0] dout
  .full(tptr_fifo_full), 	    // output full
  .empty(tptr_fifo_empty), 	// output empty
  .data_count() 			// output [4 : 0] data_count
);
endmodule
