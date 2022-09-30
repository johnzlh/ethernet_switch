`timescale 1ns / 1ps
module qm(
input          clk,
input          rstn,
input	[3:0]  port_id,        
input          sof,
input          dv,
input   [7:0]  data,
output         bp,
        
input           data_fifo_rd,
output   [7:0]  data_fifo_dout,
input           ptr_fifo_rd,
output   [15:0] ptr_fifo_dout,
output          ptr_fifo_empty
);
reg             data_fifo_wr;
reg    [7:0]    data_fifo_din;
reg    [7:0]    data_fifo_din_0;
reg             ptr_fifo_wr;
reg    [15:0]   ptr_fifo_din;
reg    [2:0]    state;
reg    [11:0]   cnt;
reg    [11:0]   length;
wire   [11:0]   data_depth;
wire            ptr_fifo_full;

always@(posedge clk or negedge rstn)begin
    if(!rstn)begin
        data_fifo_wr<=#2 0;
        data_fifo_din<=#2 0;
        ptr_fifo_wr<=#2 0;
        ptr_fifo_din<=#2 0;
        state<=#2 0;
        cnt<=#2 0;
        end
    else begin
        data_fifo_din<=#2 data;
        case(state)
        0:begin
            if(sof)begin
                if(port_id[3:0]& data[3:0])begin 
                    data_fifo_wr<=#2 0; 
                    state<=#2 1;
					length[11:8]<=#2 data[7:4];
                    end
                else state<=#2 0;
                end  
            end        
		1:begin
 		    length[7:0]<=#2 data[7:0];
			cnt<=#2 2;		
			state<=#2 2;
		    end
        2:begin
			if(cnt>=length)data_fifo_wr<=#2 0;
			else data_fifo_wr<=#2 1;
			if(!dv)begin 
				state<=#2 3;
				data_fifo_wr<=#2 0;
				cnt<=#2 0;
				end
			else cnt<=#2 cnt+1;    
			end
        3:begin
				ptr_fifo_wr<=#2 1;
				ptr_fifo_din<=#2 {4'b0,length[11:0]}-2;
				state<=#2 4;
				end
        4:begin
				ptr_fifo_wr<=#2 0;
				state<=#2 0;
				end
        endcase
        end     
    end
assign  bp=(data_depth>2578)?1:ptr_fifo_full;
sfifo_w8_d4k   qm_data_fifo(
    .clk(clk),
    .rst(!rstn),
	.din(data_fifo_din),
	.wr_en(data_fifo_wr),
	.rd_en(data_fifo_rd),
	.dout(data_fifo_dout),
	.full(), 				
	.empty(), 				
	.data_count(data_depth) 
);
sfifo_w16_d32   qm_ptr_fifo(
    .clk(clk),
    .rst(!rstn),
	.din(ptr_fifo_din),
	.wr_en(ptr_fifo_wr),
	.rd_en(ptr_fifo_rd),
	.dout(ptr_fifo_dout),
	.empty(ptr_fifo_empty), 
	.full(ptr_fifo_full),
	.data_count() 			
    );
endmodule
