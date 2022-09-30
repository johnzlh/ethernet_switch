`timescale 1ns / 1ps
module switch_post_top(
input					clk,
input					rstn,

input	 				o_cell_fifo_wr,
input	     [3:0]		o_cell_fifo_sel,
input	     [127:0]	o_cell_fifo_din,
input					o_cell_first,
input					o_cell_last,
output	 	 [3:0]		o_cell_bp,

input					data_fifo_rd0,
output	      [7:0]		data_fifo_dout0,
input					ptr_fifo_rd0,
output	      [15:0]	ptr_fifo_dout0,
output					ptr_fifo_empty0,

input					data_fifo_rd1,
output	      [7:0]		data_fifo_dout1,
input					ptr_fifo_rd1,					
output	      [15:0]	ptr_fifo_dout1,
output					ptr_fifo_empty1,

input					data_fifo_rd2,
output	      [7:0]		data_fifo_dout2,
input					ptr_fifo_rd2,					
output	      [15:0]	ptr_fifo_dout2,
output					ptr_fifo_empty2,

input					data_fifo_rd3,
output	      [7:0]		data_fifo_dout3,
input					ptr_fifo_rd3,
output	      [15:0]	ptr_fifo_dout3,
output					ptr_fifo_empty3	
    );

wire	o_cell_data_fifo_bp_0;
wire	o_cell_data_fifo_bp_1;
wire	o_cell_data_fifo_bp_2;
wire	o_cell_data_fifo_bp_3;
assign  o_cell_bp={	o_cell_data_fifo_bp_3,	o_cell_data_fifo_bp_2,
					o_cell_data_fifo_bp_1,	o_cell_data_fifo_bp_0};

switch_post post0(
	.clk(clk),
	.rstn(rstn),
	
	.o_cell_data_fifo_wr(o_cell_fifo_wr && o_cell_fifo_sel[0]),
	.o_cell_data_fifo_din(o_cell_fifo_din),
	.o_cell_data_first(o_cell_first),
	.o_cell_data_last(o_cell_last),
	.o_cell_data_fifo_bp(o_cell_data_fifo_bp_0),
	
	.ptr_fifo_rd(ptr_fifo_rd0),
	.ptr_fifo_dout(ptr_fifo_dout0),
	.ptr_fifo_empty(ptr_fifo_empty0),
	.data_fifo_rd(data_fifo_rd0),
	.data_fifo_dout(data_fifo_dout0)
	);

	
switch_post post1(
	.clk(clk),
	.rstn(rstn),
	
	.o_cell_data_fifo_wr(o_cell_fifo_wr && o_cell_fifo_sel[1]),
	.o_cell_data_fifo_din(o_cell_fifo_din),
	.o_cell_data_first(o_cell_first),
	.o_cell_data_last(o_cell_last),
	.o_cell_data_fifo_bp(o_cell_data_fifo_bp_1),
	
	.ptr_fifo_rd(ptr_fifo_rd1),
	.ptr_fifo_dout(ptr_fifo_dout1),
	.ptr_fifo_empty(ptr_fifo_empty1),
	.data_fifo_rd(data_fifo_rd1),
	.data_fifo_dout(data_fifo_dout1)
	);
	
switch_post post2(
	.clk(clk),
	.rstn(rstn),
	
	.o_cell_data_fifo_wr(o_cell_fifo_wr && o_cell_fifo_sel[2]),
	.o_cell_data_fifo_din(o_cell_fifo_din),
	.o_cell_data_first(o_cell_first),
	.o_cell_data_last(o_cell_last),
	.o_cell_data_fifo_bp(o_cell_data_fifo_bp_2),
	
	.ptr_fifo_rd(ptr_fifo_rd2),
	.ptr_fifo_dout(ptr_fifo_dout2),
	.ptr_fifo_empty(ptr_fifo_empty2),
	.data_fifo_rd(data_fifo_rd2),
	.data_fifo_dout(data_fifo_dout2)
	);
	
switch_post post3(
	.clk(clk),
	.rstn(rstn),
	
	.o_cell_data_fifo_wr(o_cell_fifo_wr && o_cell_fifo_sel[3]),
	.o_cell_data_fifo_din(o_cell_fifo_din),
	.o_cell_data_first(o_cell_first),
	.o_cell_data_last(o_cell_last),
	.o_cell_data_fifo_bp(o_cell_data_fifo_bp_3),
	
	.ptr_fifo_rd(ptr_fifo_rd3),
	.ptr_fifo_dout(ptr_fifo_dout3),
	.ptr_fifo_empty(ptr_fifo_empty3),
	.data_fifo_rd(data_fifo_rd3),
	.data_fifo_dout(data_fifo_dout3)
	);

endmodule
