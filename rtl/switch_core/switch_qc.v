`timescale 1ns / 1ps
module switch_qc(
input					clk,
input					rstn,

input		  [15:0]	q_din,	
input					q_wr,
output					q_full,

output					ptr_rdy,	
input					ptr_ack,		
output		  [15:0]	ptr_dout	
    );

reg	  [15:0]	ptr_din;
reg				ptr_wr;
reg				q_rd;
wire  [15:0]	q_dout;
wire			q_empty;

sfifo_w16_d32 u_ptr_wr_fifo (
  .clk(clk),
  .rst(!rstn), 
  .din(q_din[15:0]), 
  .wr_en(q_wr), 
  .rd_en(q_rd),
  .dout(q_dout), 
  .full(q_full),
  .empty(q_empty),
  .data_count()
);		

reg	  [1:0]		wr_state;
reg				ptr_wr_ack;
always@(posedge clk or negedge rstn)
	if(!rstn)begin
		ptr_din<=#2  0;
		ptr_wr<=#2  0;
		q_rd<=#2  0;
		wr_state<=#2  0;
		end
	else begin
		case(wr_state)			
		0:begin					
			if(!q_empty)begin
				q_rd<=#2  1;
				wr_state<=#2  1;
				end
		  end
		1:begin
			q_rd<=#2  0;
			wr_state<=#2  2;
		  end
		2:begin
			ptr_din<=#2  q_dout[15:0];		
			ptr_wr<=#2  1;
			wr_state<=#2  3;
			end
		3:begin
			if(ptr_wr_ack)begin	
				ptr_wr<=#2  0;
				wr_state<=#2  0;
				end
			end
		endcase
		end

reg				ptr_rd;
reg	  [15:0]	ptr_fifo_din;
reg				ptr_rd_ack;

reg	  [15:0]	head;
reg	  [15:0]	tail;
reg	  [15:0]	depth_cell;
reg   			depth_flag;
reg	  [15:0]	depth_frame;

reg	  [15:0]	ptr_ram_din;
wire  [15:0]	ptr_ram_dout;
reg				ptr_ram_wr;
reg   [9:0]		ptr_ram_addr;

reg	  [3:0]		mstate;

always@(posedge clk or negedge rstn)
	if(!rstn)	begin
		mstate<=#2  0;
		ptr_ram_wr<=#2  0;
		ptr_wr_ack<=#2  0;
		head <=#2  0;	
		tail <=#2  0;	
		depth_cell <=#2  0;	
		depth_frame<=#2  0;
		ptr_rd_ack<=#2  0;
		ptr_ram_din<=#2  0;
		ptr_ram_addr<=#2  0;
		ptr_fifo_din<=#2  0;
		depth_flag<=#2 0;
		end
	else begin
		ptr_wr_ack<=#2  0;	
		ptr_rd_ack<=#2  0;	
		ptr_ram_wr<=#2  0;	
		case(mstate)					
		0:begin							
			if(ptr_wr)begin
				mstate<=#2  1;
				end
			else if(ptr_rd)
				begin					
				ptr_fifo_din<=#2  head;
				ptr_ram_addr[9:0]<=#2  head[9:0];
				mstate<=#2  3;
				end
		  end
		1:begin
			if(depth_cell[9:0])	begin	
				ptr_ram_wr<=#2  1;
				ptr_ram_addr[9:0]<=#2  tail[9:0];
				ptr_ram_din[15:0]<=#2  ptr_din[15:0];
				tail<=#2  ptr_din;
				end
			else begin
				ptr_ram_wr<=#2  1;			
				ptr_ram_addr[9:0]<=#2  ptr_din[9:0];
				ptr_ram_din[15:0]<=#2  ptr_din[15:0];
				tail<=#2  ptr_din;
				head<=#2  ptr_din;
				end	
			depth_cell<=#2 depth_cell+1;
			if(ptr_din[15])	begin		
				depth_flag<=#2 1;
				depth_frame<=#2 depth_frame+1;
				end
			ptr_wr_ack<=#2  1;				
			mstate<=#2  2;
			end
		2:begin
			ptr_ram_addr<=#2  tail[9:0];
			ptr_ram_din	<=#2  tail[15:0];
			ptr_ram_wr<=#2  1;
			mstate<=#2  0;
		  end
		3:begin
			ptr_rd_ack<=#2  1;				
			mstate<=#2  4;
		  end
//============================================  
//another cycle for ram 
//============================================ 
		4:begin
			mstate<=#2  5;
		  end
		5:begin
			head<=#2  ptr_ram_dout;
			depth_cell<=#2 depth_cell-1;
			if(head[15]) begin
				depth_frame<=#2  depth_frame-1;
				if(depth_frame>1) depth_flag<=#2 1;
				else depth_flag<=#2 0;
				end
			mstate<=#2  0;
		  end
		endcase
		end
		
reg   [2:0]	rd_state;
wire		ptr_full;
wire		ptr_empty;
assign ptr_rdy=!ptr_empty;	

always@(posedge clk or negedge rstn)
	if(!rstn)
		begin
		ptr_rd<=#2  0;	
		rd_state<=#2  0;
		end
	else
		begin
		case(rd_state)					
		0:begin							
			if(depth_flag && !ptr_full)begin
				rd_state<=#2  1;
				ptr_rd<=#2  1;
				end
		  end
		1:begin
			if(ptr_rd_ack)begin
				ptr_rd<=#2  0;
				rd_state<=#2  2;
				end
			end
		2:rd_state<=#2  0;
		endcase
		end

sram_w16_d512 u_ptr_ram (
  .clka(clk), 			
  .wea(ptr_ram_wr),     
  .addra(ptr_ram_addr[8:0]), 
  .dina(ptr_ram_din),   
  .douta(ptr_ram_dout) 
);		

sfifo_ft_w16_d32 u_ptr_fifo0 (
  .clk(clk),
  .rst(!rstn), 					
  .din(ptr_fifo_din[15:0]), 	
  .wr_en(ptr_rd_ack), 	
  .rd_en(ptr_ack), 	
  .dout(ptr_dout[15:0]), 		
  .full(ptr_full), 		
  .empty(ptr_empty),
  .data_count()  
);
endmodule
