`timescale 1ns / 1ps
module switch_pre(
input					clk,
input					rstn,
input					sof,
input					dv,
input		  	[7:0]	din,
output	reg		[127:0]	i_cell_data_fifo_dout,
output	reg		 		i_cell_data_fifo_wr,
output	reg		[15:0]	i_cell_ptr_fifo_dout,
output	reg				i_cell_ptr_fifo_wr,	
input					i_cell_bp							
    );
reg	  	[7:0]	word_num;	
reg	  	[4:0]	state;
reg		[3:0]	i_cell_portmap;	 			

always@(posedge clk or negedge rstn)
	if(!rstn)
		begin
		word_num<=#2  0;
		state<=#2  0;
		i_cell_data_fifo_dout<=#2  0;
		i_cell_portmap<=#2  0;
		i_cell_data_fifo_wr<=#2  0;
		i_cell_ptr_fifo_dout<=#2  0;
		i_cell_ptr_fifo_wr<=#2  0;	
		end
	else begin
		i_cell_data_fifo_wr<=#2  0;
		i_cell_ptr_fifo_wr<=#2  0;
		case(state)
		0:begin
			word_num<=#2  0;
			if(sof & !i_cell_bp)begin
				i_cell_data_fifo_dout[127:120]<=#2  din;
				i_cell_portmap<=#2  din[3:0];
				state<=#2  1;
				end
			end
		1:begin
			i_cell_data_fifo_dout[119:112]<=#2  din;
			state<=#2  2;
			end
		2:begin
			i_cell_data_fifo_dout[111:104]<=#2  din;
			state<=#2  3;
			end
		3:begin
			i_cell_data_fifo_dout[103:96]<=#2  din;
			state<=#2  4;
			end
		4:begin
			i_cell_data_fifo_dout[95:88]<=#2  din;
			state<=#2  5;
			end
		5:begin
			i_cell_data_fifo_dout[87:80]<=#2  din;
			state<=#2  6;
			end
		6:begin
			i_cell_data_fifo_dout[79:72]<=#2  din;
			state<=#2  7;
			end
		7:begin
			i_cell_data_fifo_dout[71:64]<=#2  din;
			state<=#2  8;
		  end
		8:begin
			i_cell_data_fifo_dout[63:56]<=#2  din;
			state<=#2  9;
			end
		9:begin
			i_cell_data_fifo_dout[55:48]<=#2  din;
			state<=#2  10;
			end
		10:begin
			i_cell_data_fifo_dout[47:40]<=#2  din;
			state<=#2  11;
			end
		11:begin
			i_cell_data_fifo_dout[39:32]<=#2  din;
			state<=#2  12;
			end
		12:begin
			i_cell_data_fifo_dout[31:24]<=#2  din;
			state<=#2  13;
			end
		13:begin
			i_cell_data_fifo_dout[23:16]<=#2  din;
			state<=#2  14;
			end
		14:begin
			i_cell_data_fifo_dout[15:8]<=#2  din;
			state<=#2  15;
		  end
		15:begin
			i_cell_data_fifo_dout[7:0]<=#2  din;
			i_cell_data_fifo_wr<=#2  1;
			word_num<=#2  word_num+1;
			state<=#2  16;
		  end
		16:begin
			if(dv) begin
				i_cell_data_fifo_dout[127:120]<=#2  din;
				state<=#2 1;
				end
			else begin
				i_cell_ptr_fifo_dout<=#2  {4'b0,i_cell_portmap[3:0],2'b0,word_num[7:2]};
				i_cell_ptr_fifo_wr<=#2  1;
				state<=#2 0;
				end
			end
		endcase
		end
endmodule
