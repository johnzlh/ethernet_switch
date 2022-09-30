`timescale 1ns / 1ps
module cam_w48_d64 (
input             	clk,
input              	rstn,
input              	init_req,		
output  reg       	init_ack,		
input              	cam_search,		
input              	cam_wr_req,		
output  reg [5:0]  	cam_wr_addr,	
output  reg       	cam_wr_ack,		
input              	cam_refresh_req,	
output  reg       	cam_refresh_ack,	
input       [5:0]  	cam_refresh_addr,	
input       [47:0] 	cam_content,		
output  reg       	cam_matched,		
output  reg       	cam_mismatched,	
output  reg [5:0]  	cam_match_addr,	
output             	cam_empty,		
input              	aging_req, 		
output  reg       	aging_ack		
);
parameter TTL_TH=10'd300;			

reg     [5:0]   	cam_addr_fifo_din;
reg             	cam_addr_fifo_wr;
reg             	cam_addr_fifo_rd;
wire    [5:0]   	cam_addr_fifo_dout;

reg     [47:0]  	cam [0:63];		 
reg     [10:0]  	valid_ttl [0:63];
integer         	i,j,m;			
reg     [10:0]  	temp;			
                                    
reg     [1:0]   	state;			
reg     [5:0]   	aging_addr;		
always @(posedge clk or negedge rstn)
	if(!rstn) begin
        state= 0;
		cam_addr_fifo_din= 0;
		cam_addr_fifo_wr= 0;
		cam_addr_fifo_rd= 0;
		cam_wr_ack= 0;
		init_ack= 0;
		aging_ack= 0;
		cam_refresh_ack=0;
		aging_addr=0;
		i=0;
        m=0;
        end
    else begin
        case(state)
        0:begin
			cam_addr_fifo_wr=0;
            if(init_req) begin
				i=0;
                state=2;
                end
            else if(cam_wr_req)begin
				cam_wr_ack = 1;
                cam[cam_addr_fifo_dout]=cam_content;
				cam_wr_addr=cam_addr_fifo_dout;
                temp[9:0]=TTL_TH;
                temp[10]=1'b1;
				valid_ttl[cam_addr_fifo_dout]=temp[10:0];
				cam_addr_fifo_rd=1;
                state= 1;
                end
            else if(cam_refresh_req) begin
				cam_refresh_ack=1;
                temp[9:0]=TTL_TH;
                temp[10]=1'b1;
				valid_ttl[cam_refresh_addr]=temp[10:0];
                state= 1;
                end
            else if(aging_req) begin
                temp=valid_ttl[aging_addr];
                if(temp[10])begin
                    if(temp[9:0]>0) begin
                        temp=temp-1;
						valid_ttl[aging_addr]=temp;
                        if(aging_addr<63) aging_addr=aging_addr+1;
                        else begin
							aging_ack=1;
							aging_addr=0;
                            state=1;
                            end
                        end
                    else begin
						valid_ttl[aging_addr]=0;
						cam_addr_fifo_wr=1;
						cam_addr_fifo_din=aging_addr;
                        if(aging_addr<63) aging_addr=aging_addr+1;
                        else begin
							aging_addr=0;
							aging_ack=1;
                            state=1;
                            end
                        end
                    end
               else begin
                   if(aging_addr<63)aging_addr=aging_addr+1;
                   else begin
						aging_ack=1;
						aging_addr=0;
                       	state=1;
                       	end
                    end
                end
            end
        1:begin
			cam_wr_ack=0;
			cam_refresh_ack=0;
			cam_addr_fifo_wr=0;
			cam_addr_fifo_rd=0;
			aging_ack=0;
            state=0;
            end
        2:begin
			cam_addr_fifo_din=i[5:0];
			cam_addr_fifo_wr=1;
            cam[i]=0;
			valid_ttl[i]=0;
            if(i<63) i=i+1;
            else begin
				init_ack=1;
                state=3;
                end
            end
        3:begin
			cam_addr_fifo_wr=0;
			init_ack=0;
            state=0;
            end
		endcase
        end
always @(posedge clk) begin
	cam_matched = 1'b0;
	cam_mismatched = 1'b0;
    if (cam_search) begin
		cam_mismatched = 1'b1;
        for (j=0; j<64; j=j+1)begin
            if((cam_content===cam[j]) && (!cam_matched))begin
				cam_matched = 1'b1;
				cam_mismatched = 1'b0;
				cam_match_addr = j;
                end
            end
        end
    end
sfifo_ft_w6_d64  u_addr_fifo (
  	.clk(clk),                	// input clk
  	.rst(!rstn),              	// input rst
  	.din(cam_addr_fifo_din),  	// input [5 : 0] din
  	.wr_en(cam_addr_fifo_wr), 	// input wr_en
  	.rd_en(cam_addr_fifo_rd), 	// input rd_en
  	.dout(cam_addr_fifo_dout),	// output [5 : 0] dout
  	.full(),                  	// output full
  	.empty(cam_empty),       	// output empty
  	.data_count()             	// output [6 : 0] data_count
	);
endmodule