`timescale 1ns / 1ps
module mac_top_test(
input				rstn,
input				clk,
input				rx_clk,
input				rx_dv,
input		[3:0]	    rx_d,
input				tx_clk,
output				tx_dv,
output		[3:0]  	tx_d
    );
wire				rx_data_fifo_rd;
wire		[7:0]	rx_data_fifo_din;
wire				rx_ptr_fifo_rd; 
wire		[15:0]	rx_ptr_fifo_din;
wire				rx_ptr_fifo_empty;
wire				tx_data_fifo_rd;
wire		[7:0]  	tx_data_fifo_dout;
wire				tx_ptr_fifo_rd; 
wire		[15:0]	tx_ptr_fifo_dout;
wire				tx_ptr_fifo_empty;	
mac_r u_mac_r (
	.rstn			(rstn), 
	.clk			(clk),
	.rx_clk		(rx_clk), 
	.rx_dv		(rx_dv), 
	.rx_d		(rx_d), 
	.data_fifo_rd	(rx_data_fifo_rd), 
	.data_fifo_dout(rx_data_fifo_din), 
	.ptr_fifo_rd	(rx_ptr_fifo_rd), 
	.ptr_fifo_dout	(rx_ptr_fifo_din), 
	.ptr_fifo_empty(rx_ptr_fifo_empty)
);
mac_loopback u_mac_loopback (
	.clk(clk), 
	.rstn(rstn), 
	.rx_data_fifo_rd	(rx_data_fifo_rd), 
	.rx_data_fifo_din	(rx_data_fifo_din), 
	.rx_ptr_fifo_rd		(rx_ptr_fifo_rd), 
	.rx_ptr_fifo_din	(rx_ptr_fifo_din), 
	.rx_ptr_fifo_empty	(rx_ptr_fifo_empty), 
	.tx_data_fifo_rd	(tx_data_fifo_rd), 
	.tx_data_fifo_dout	(tx_data_fifo_dout), 
	.tx_ptr_fifo_rd		(tx_ptr_fifo_rd), 
	.tx_ptr_fifo_dout	(tx_ptr_fifo_dout), 
	.tx_ptr_fifo_empty	(tx_ptr_fifo_empty)
);
mac_t u_mac_t (
	.rstn(rstn), 
	.clk(clk), 
	.tx_clk(tx_clk), 
	.tx_dv(tx_dv), 
	.tx_d(tx_d), 
	.data_fifo_rd		(tx_data_fifo_rd), 
	.data_fifo_din		(tx_data_fifo_dout), 
	.ptr_fifo_rd		(tx_ptr_fifo_rd), 
	.ptr_fifo_din		(tx_ptr_fifo_dout), 
	.ptr_fifo_empty	(tx_ptr_fifo_empty)
);
endmodule
