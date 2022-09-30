`timescale 1ns / 1ps
module switch_post(
input					clk,
input					rstn,

input					o_cell_data_fifo_wr,
input		  [127:0]	o_cell_data_fifo_din,
input					o_cell_data_first,
input					o_cell_data_last,
output	reg				o_cell_data_fifo_bp,

input					ptr_fifo_rd,
output		  [15:0]	ptr_fifo_dout,
output					ptr_fifo_empty,
input					data_fifo_rd,
output		  [7:0]		data_fifo_dout
);
		
reg				o_cell_data_fifo_rd;
wire  [143:0]	o_cell_data_fifo_dout;
wire			o_cell_data_fifo_empty;
wire  [8:0]		o_cell_data_fifo_depth;

sfifo_ft_w144_d256 u_o_cell_fifo(
  .clk(clk),
  .rst(!rstn), 
  .din({o_cell_data_first,o_cell_data_last,14'b0,o_cell_data_fifo_din[127:0]}), 
  .wr_en(o_cell_data_fifo_wr), 
  .rd_en(o_cell_data_fifo_rd), 
  .dout(o_cell_data_fifo_dout[143:0]), 
  .full(), 
  .empty(o_cell_data_fifo_empty),
  .data_count(o_cell_data_fifo_depth[8:0]) 
);
always @(posedge clk) 
	if(o_cell_data_fifo_depth>240) o_cell_data_fifo_bp<=#2 1;
	else o_cell_data_fifo_bp<=#2 0;

reg	  [15:0]	ptr_fifo_din;
wire			ptr_fifo_full;
wire			data_fifo_wr;
reg   [7:0]		data_fifo_din;
wire  [11:0]	data_fifo_depth;
reg				bp;
always @(posedge clk) 
	bp<=#2 (data_fifo_depth>2578)|ptr_fifo_full;

reg				ptr_fifo_wr;
reg   [4:0]		mstate;
reg	  [11:0]	byte_cnt;			
reg				byte_dv;			
reg   [11:0]	frame_len;
reg   [11:0]	frame_len_with_pad;
		
always@(posedge clk or negedge rstn)
	if(!rstn)
		begin
		mstate<=#2  0;
		byte_cnt<=#2 0;
		byte_dv<=#2 0;
		frame_len<=#2 0;
		frame_len_with_pad<=#2 0;
		o_cell_data_fifo_rd<=#2 0;
		data_fifo_din<=#2 0;
		ptr_fifo_wr<=#2 0;
		ptr_fifo_din<=#2 0;
		end
	else begin
		o_cell_data_fifo_rd<=#2 0;
		ptr_fifo_wr<=#2 0;
		if(byte_dv) byte_cnt<=#2 byte_cnt+1;
		case(mstate)
		0:begin
			byte_dv<=#2 0;
			byte_cnt<=#2 0;
			if(!o_cell_data_fifo_empty & o_cell_data_fifo_dout[143] & !bp) begin
				frame_len<=#2 {o_cell_data_fifo_dout[127:124],o_cell_data_fifo_dout[119:112]};
				frame_len_with_pad<=#2 {o_cell_data_fifo_dout[127:124],o_cell_data_fifo_dout[119:112]};	
				mstate<=#2  1;
				end
			else if(!o_cell_data_fifo_empty & !bp)begin
				mstate <= #2 19;
				end
			end
		1:begin
			if(frame_len_with_pad[5:0]!==6'b0) 
				frame_len_with_pad<=#2 {frame_len_with_pad[11:6],6'b0}+64;
			frame_len<=#2  frame_len-2;		
			byte_dv<=#2 1;
			data_fifo_din<=#2  o_cell_data_fifo_dout[111:104];
			mstate<=#2 5;
			end
		2:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[127:120];
			mstate<=#2 3;
			end
		3:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[119:112];
			mstate<=#2  4;
			end
		4:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[111:104];
			mstate<=#2  5;
		  end 
		5:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[103:96];
			mstate<=#2  6;
			end
		6:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[95:88];
			mstate<=#2  7;
			end
		7:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[87:80];
			mstate<=#2  8;
			end
		8:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[79:72];
			mstate<=#2  9;
			end
		9:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[71:64];
			mstate<=#2  10;
			end
		10:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[63:56];
			mstate<=#2  11;
			end
		11:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[55:48];
			mstate<=#2  12;
			end
		12:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[47:40];
			mstate<=#2  13;
			end
		13:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[39:32];
			mstate<=#2  14;
			end
		14:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[31:24];
			mstate<=#2  15;
			end
		15:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[23:16];
			mstate<=#2  16;
			end
		16:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[15:8];
			o_cell_data_fifo_rd<=#2 1;
			if(frame_len_with_pad>16) begin
				frame_len_with_pad<=#2 frame_len_with_pad-16;
				mstate<=#2  17;
				end
			else mstate<=#2 18;
			end
		17:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[7:0];
			mstate<=#2  2;
			end
		18:begin
			data_fifo_din<=#2  o_cell_data_fifo_dout[7:0];
			ptr_fifo_din<=#2  {4'b0,frame_len[11:0]};
			ptr_fifo_wr<=#2  1;
			mstate<=#2  0;
			end
		19:begin
			o_cell_data_fifo_rd<=#2 1;
			mstate <= #2 0;
			end
		endcase
		end
assign data_fifo_wr=byte_dv & (byte_cnt<frame_len);
			
sfifo_w8_d4k u_data_fifo(
  .clk(clk), 
  .rst(!rstn), 
  .din(data_fifo_din[7:0]), 
  .wr_en(data_fifo_wr), 
  .rd_en(data_fifo_rd), 
  .dout(data_fifo_dout[7:0]), 
  .full(), 
  .empty(),
  .data_count(data_fifo_depth[11:0])
);

sfifo_w16_d32 u_ptr_fifo(
  .clk(clk),
  .rst(!rstn), 
  .din(ptr_fifo_din[15:0]), 
  .wr_en(ptr_fifo_wr), 
  .rd_en(ptr_fifo_rd), 
  .dout(ptr_fifo_dout[15:0]), 
  .full(ptr_fifo_full), 
  .empty(ptr_fifo_empty),
  .data_count()
  );
endmodule
