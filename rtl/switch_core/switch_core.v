`timescale 1ns / 1ps
module switch_core(
input					clk,
input					rstn,

input		  [127:0]	i_cell_data_fifo_din,				
input		 			i_cell_data_fifo_wr,					
input		  [15:0]	i_cell_ptr_fifo_din,				
input		 			i_cell_ptr_fifo_wr,					
output	reg				i_cell_bp,

output	reg				o_cell_fifo_wr,
output	reg  [3:0]		o_cell_fifo_sel,
output	     [127:0]	o_cell_fifo_din,
output					o_cell_first,
output					o_cell_last,
input		 [3:0]		o_cell_bp	
    );
reg 	[3:0]	qc_portmap;

wire 	[127:0]	sram_din_a;				
wire 	[127:0]	sram_dout_b;			
wire 	[11:0]	sram_addr_a;			
wire 	[11:0]	sram_addr_b;			
wire			sram_wr_a;				
		
reg  			i_cell_data_fifo_rd;	
wire [127:0]	i_cell_data_fifo_dout;	
wire [8:0]		i_cell_data_fifo_depth;	

reg				i_cell_ptr_fifo_rd;
wire [15:0]		i_cell_ptr_fifo_dout;
wire			i_cell_ptr_fifo_full;
wire			i_cell_ptr_fifo_empty;
reg	 [5:0]		cell_number;
reg				i_cell_last;
reg				i_cell_first;
			
reg  [15:0]		FQ_din;		
reg				FQ_wr;
reg				FQ_rd;
reg  [9:0]		FQ_dout;	

reg	 [1:0]		sram_cnt_a;	
reg	 [1:0]		sram_cnt_b;
reg				sram_rd;	
//============================================  
//user code generte a pipeline of sram_rd.   
//============================================ 
reg				sram_rd_dv;
 


reg  [3:0]		wr_state;		
reg  [3:0]		qc_wr_ptr_wr_en;
wire			qc_ptr_full0;
wire			qc_ptr_full1;
wire			qc_ptr_full2;
wire			qc_ptr_full3;
reg				qc_ptr_full;
wire [9:0]		ptr_dout_s;		
reg  [15:0]		qc_wr_ptr_din;	
		
wire 			FQ_empty;
wire[11:0]		MC_ram_addra;	
wire [3:0]		MC_ram_dina;	
reg	 			MC_ram_wra;		
reg				MC_ram_wrb;		
reg  [3:0]		MC_ram_dinb;	
wire [3:0]		MC_ram_doutb;	
wire            FQ_act;


//============================================  
//队列控制器反压指示器，任意队列溢出都会使指示器置1
//============================================  
always@(posedge clk)
	qc_ptr_full<=#2 ({	qc_ptr_full3,qc_ptr_full2,qc_ptr_full1,
					qc_ptr_full0}==4'b0)?0:1;


sfifo_ft_w128_d256 u_i_cell_fifo(
  .clk(clk), 
  .rst(!rstn), 
  .din(i_cell_data_fifo_din[127:0]), 
  .wr_en(i_cell_data_fifo_wr), 
  .rd_en(i_cell_data_fifo_rd), 
  .dout(i_cell_data_fifo_dout[127:0]), 
  .full(), 
  .empty(),
  .data_count(i_cell_data_fifo_depth[8:0])
);
always @(posedge clk) 
	i_cell_bp<=#2 (i_cell_data_fifo_depth[8:0]>161) | i_cell_ptr_fifo_full;

sfifo_ft_w16_d32 u_ptr_fifo (
  .clk(clk), 					// input clk
  .rst(!rstn), 					// input rst
  .din(i_cell_ptr_fifo_din), 	// input [15 : 0] din
  .wr_en(i_cell_ptr_fifo_wr), 	// input wr_en
  .rd_en(i_cell_ptr_fifo_rd), 	// input rd_en
  .dout(i_cell_ptr_fifo_dout), 	// output [15 : 0] dout
  .full(i_cell_ptr_fifo_full), 	// output full
  .empty(i_cell_ptr_fifo_empty),// output empty
  .data_count() 				// output [5 : 0] data_count
);

always@(posedge clk or negedge rstn)
	if(!rstn)
		begin
		wr_state<=#2  0;
		FQ_rd<=#2  0;
		MC_ram_wra<=#2  0;
		sram_cnt_a<=#2  0;
		i_cell_data_fifo_rd<=#2  0;
		i_cell_ptr_fifo_rd<=#2 0;
		qc_wr_ptr_wr_en<=#2  0;
		qc_wr_ptr_din<=#2  0;
		FQ_dout<=#2  0;
		qc_portmap<=#2 0;
		cell_number<=#2 0;
		i_cell_last<=#2 0;
		i_cell_first<=#2 0;
		end
	else
		begin
		MC_ram_wra<=#2  0;
		FQ_rd<=#2  0;
		qc_wr_ptr_wr_en<=#2  0;
		i_cell_ptr_fifo_rd<=#2  0;
		case(wr_state)
		0:begin
			sram_cnt_a<=#2  0;
			i_cell_last<=#2 0;
			i_cell_first<=#2 0;
			if(!i_cell_ptr_fifo_empty & !qc_ptr_full & !FQ_empty & FQ_act)begin
				i_cell_data_fifo_rd<=#2  1;
				i_cell_ptr_fifo_rd<=#2  1;
				qc_portmap<=#2 i_cell_ptr_fifo_dout[11:8];
				FQ_rd<=#2  1;
				FQ_dout<=#2  ptr_dout_s;
				cell_number[5:0]<=#2 i_cell_ptr_fifo_dout[5:0];
				i_cell_first<=#2  1;
				if(i_cell_ptr_fifo_dout[5:0]==6'b1) i_cell_last<=#2 1;
				wr_state<=#2 1;
				end
			end
		1:begin			
			cell_number<=#2 cell_number-1;
			sram_cnt_a<=#2 1;
			qc_wr_ptr_din<=#2  {i_cell_last,i_cell_first,4'b0,FQ_dout};
			if(qc_portmap[0])qc_wr_ptr_wr_en[0]<=#2  1;
			if(qc_portmap[1])qc_wr_ptr_wr_en[1]<=#2  1;
			if(qc_portmap[2])qc_wr_ptr_wr_en[2]<=#2  1;
			if(qc_portmap[3])qc_wr_ptr_wr_en[3]<=#2  1;
			MC_ram_wra<=#2  1;
			wr_state<=#2  2;
		  end
		2:begin
			sram_cnt_a<=#2  2;
			wr_state<=#2  3;
		  end
		3:begin
			sram_cnt_a<=#2  3;
			wr_state<=#2  4;
		  end
		4:begin
			i_cell_first<=#2  0;
			if(cell_number) begin
				if(!FQ_empty)begin
					FQ_rd		<=#2  1;
					FQ_dout		<=#2  ptr_dout_s;
					sram_cnt_a	<=#2  0;	
					wr_state	<=#2  1;
					if(cell_number==1) i_cell_last<=#2 1;
					else i_cell_last<=#2 0;
					end
				end
			else begin
				i_cell_data_fifo_rd<=#2 0;
				wr_state	<=#2 0;
				end
			end
		default:wr_state<=#2  0;
		endcase
		end

assign  sram_wr_a=i_cell_data_fifo_rd;
assign	sram_addr_a={FQ_dout[9:0],sram_cnt_a[1:0]};
assign	sram_din_a=i_cell_data_fifo_dout[127:0];		

assign MC_ram_addra= {2'b0,FQ_dout[9:0]};
assign MC_ram_dina = qc_portmap[0]+qc_portmap[1]+qc_portmap[2]+qc_portmap[3];

reg  [3:0]		rd_state;
wire [15:0]		qc_rd_ptr_dout0,qc_rd_ptr_dout1,
                qc_rd_ptr_dout2,qc_rd_ptr_dout3;
reg  [1:0]		RR;
reg  [3:0]		ptr_ack;
wire [3:0]		ptr_rd_req_pre;

wire			ptr_rdy0,ptr_rdy1,ptr_rdy2,ptr_rdy3;		
wire			ptr_ack0,ptr_ack1,ptr_ack2,ptr_ack3;

assign	ptr_rd_req_pre={ptr_rdy3,ptr_rdy2,ptr_rdy1,ptr_rdy0} & (~o_cell_bp);
assign	{ptr_ack3,ptr_ack2,ptr_ack1,ptr_ack0}=ptr_ack;
assign	sram_addr_b={FQ_din[9:0],sram_cnt_b[1:0]};
assign	o_cell_last=FQ_din[15];
assign	o_cell_first=FQ_din[14];
assign	o_cell_fifo_din[127:0]= sram_dout_b[127:0];

always@(posedge clk or negedge rstn)
	if(!rstn)begin
		rd_state<=#2  0;
		FQ_wr<=#2  0;
		FQ_din<=#2  0;
		MC_ram_wrb<=#2  0;
		MC_ram_dinb<=#2  0;
		RR<=#2  0;
		ptr_ack<=#2  0;
		
		sram_rd<=#2  0;
		sram_rd_dv<=#2  0;
		sram_cnt_b<=#2  0;
		o_cell_fifo_wr<=#2  0;
		o_cell_fifo_sel<=#2  0;
		end
	else begin
		FQ_wr<=#2  0;
		MC_ram_wrb<=#2  0;
		sram_rd_dv <= #2 sram_rd;
		o_cell_fifo_wr<=#2 sram_rd_dv;
		case(rd_state)
		0:begin
			sram_rd<=#2  0;
			sram_cnt_b<=#2  0;
			if(ptr_rd_req_pre)	rd_state<=#2  1;	
			end
		1:begin
			rd_state<=#2  2;
			sram_rd<=#2  1;
			RR<=#2 RR+2'b01;
			case(RR)						
			0:begin							
				casex(ptr_rd_req_pre[3:0])  
				4'bxxx1:begin FQ_din<=#2  qc_rd_ptr_dout0; o_cell_fifo_sel<=#2  4'b0001; ptr_ack<=#2  4'b0001; end
				4'bxx10:begin FQ_din<=#2  qc_rd_ptr_dout1; o_cell_fifo_sel<=#2  4'b0010; ptr_ack<=#2  4'b0010; end
				4'bx100:begin FQ_din<=#2  qc_rd_ptr_dout2; o_cell_fifo_sel<=#2  4'b0100; ptr_ack<=#2  4'b0100; end
				4'b1000:begin FQ_din<=#2  qc_rd_ptr_dout3; o_cell_fifo_sel<=#2  4'b1000; ptr_ack<=#2  4'b1000; end
				endcase
			end
			1:begin
				casex({ptr_rd_req_pre[0],ptr_rd_req_pre[3:1]})
				4'bxxx1:begin FQ_din<=#2  qc_rd_ptr_dout1; o_cell_fifo_sel<=#2  4'b0010; ptr_ack<=#2  4'b0010; end
				4'bxx10:begin FQ_din<=#2  qc_rd_ptr_dout2; o_cell_fifo_sel<=#2  4'b0100; ptr_ack<=#2  4'b0100; end
				4'bx100:begin FQ_din<=#2  qc_rd_ptr_dout3; o_cell_fifo_sel<=#2  4'b1000; ptr_ack<=#2  4'b1000; end
				4'b1000:begin FQ_din<=#2  qc_rd_ptr_dout0; o_cell_fifo_sel<=#2  4'b0001; ptr_ack<=#2  4'b0001; end
				endcase
			end
			2:begin
				casex({ptr_rd_req_pre[1:0],ptr_rd_req_pre[3:2]})
				4'bxxx1:begin FQ_din<=#2  qc_rd_ptr_dout2; o_cell_fifo_sel<=#2  4'b0100; ptr_ack<=#2  4'b0100; end
				4'bxx10:begin FQ_din<=#2  qc_rd_ptr_dout3; o_cell_fifo_sel<=#2  4'b1000; ptr_ack<=#2  4'b1000; end
				4'bx100:begin FQ_din<=#2  qc_rd_ptr_dout0; o_cell_fifo_sel<=#2  4'b0001; ptr_ack<=#2  4'b0001; end
				4'b1000:begin FQ_din<=#2  qc_rd_ptr_dout1; o_cell_fifo_sel<=#2  4'b0010; ptr_ack<=#2  4'b0010; end
				endcase
			end
			3:begin
				casex({ptr_rd_req_pre[2:0],ptr_rd_req_pre[3]})
				4'bxxx1:begin FQ_din<=#2  qc_rd_ptr_dout3; o_cell_fifo_sel<=#2  4'b1000; ptr_ack<=#2  4'b1000; end
				4'bxx10:begin FQ_din<=#2  qc_rd_ptr_dout0; o_cell_fifo_sel<=#2  4'b0001; ptr_ack<=#2  4'b0001; end
				4'bx100:begin FQ_din<=#2  qc_rd_ptr_dout1; o_cell_fifo_sel<=#2  4'b0010; ptr_ack<=#2  4'b0010; end
				4'b1000:begin FQ_din<=#2  qc_rd_ptr_dout2; o_cell_fifo_sel<=#2  4'b0100; ptr_ack<=#2  4'b0100; end
				endcase
				end
			endcase
			end
		2:begin
			ptr_ack<=#2  0;
			sram_cnt_b<=#2  sram_cnt_b+1;
			rd_state<=#2  3;
		  end
		3:begin
			sram_cnt_b<=#2  sram_cnt_b+1;
//============================================  
//another cycle for ram 
//============================================ 
			rd_state<=#2  4;
		  end
		4:begin
			sram_cnt_b<=#2  sram_cnt_b+1;
			MC_ram_wrb<=#2  1;
			if(MC_ram_doutb==1)	
				begin
				MC_ram_dinb<=#2  0;
				FQ_wr<=#2  1;
				end
			else
				MC_ram_dinb<=#2  MC_ram_doutb-1;
			rd_state<=#2  5;
		  end
		5:begin
			sram_rd<=#2  0;
			rd_state<=#2  0;
		  end
		default:rd_state<=#2  0;
		endcase
		end

multi_user_fq u_fq (
	.clk(clk), 
	.rstn(rstn), 
	.ptr_din({6'b0,FQ_din[9:0]}), 
	.FQ_wr(FQ_wr), 
	.FQ_rd(FQ_rd), 
	.ptr_dout_s(ptr_dout_s), 
	.ptr_fifo_empty(FQ_empty),
	.FQ_act(FQ_act)
);

dpsram_w4_d512 u_MC_dpram (
  .clka(clk), 				
  .wea(MC_ram_wra), 		
  .addra(MC_ram_addra[8:0]), 	
  .dina(MC_ram_dina), 		
  .douta(), 				
  .clkb(clk), 				
  .web(MC_ram_wrb), 		
  .addrb(FQ_din[8:0]), 	
  .dinb(MC_ram_dinb), 		
  .doutb(MC_ram_doutb) 		
);

switch_qc qc0(
	.clk(clk), 
	.rstn(rstn), 
	.q_din(qc_wr_ptr_din), 
	.q_wr(qc_wr_ptr_wr_en[0]), 
	.q_full(qc_ptr_full0), 
	.ptr_rdy(ptr_rdy0),
	.ptr_ack(ptr_ack0),
	.ptr_dout(qc_rd_ptr_dout0)
);

switch_qc qc1(
	.clk(clk), 
	.rstn(rstn), 
	
	.q_din(qc_wr_ptr_din), 
	.q_wr(qc_wr_ptr_wr_en[1]), 
	.q_full(qc_ptr_full1), 
	
	.ptr_rdy(ptr_rdy1),
	.ptr_ack(ptr_ack1),
	.ptr_dout(qc_rd_ptr_dout1)
);

switch_qc qc2(
	.clk(clk), 
	.rstn(rstn), 
	
	.q_din(qc_wr_ptr_din), 
	.q_wr(qc_wr_ptr_wr_en[2]), 
	.q_full(qc_ptr_full2), 
	
	.ptr_rdy(ptr_rdy2),
	.ptr_ack(ptr_ack2),
	.ptr_dout(qc_rd_ptr_dout2)
);

switch_qc qc3(
	.clk(clk), 
	.rstn(rstn), 
	
	.q_din(qc_wr_ptr_din), 
	.q_wr(qc_wr_ptr_wr_en[3]), 
	.q_full(qc_ptr_full3), 
	
	.ptr_rdy(ptr_rdy3),
	.ptr_ack(ptr_ack3),
	.ptr_dout(qc_rd_ptr_dout3)
);

dpsram_w128_d2k u_data_ram (
  .clka(clk), 			
  .wea(sram_wr_a), 		
  .addra(sram_addr_a[10:0]),	
  .dina(sram_din_a), 	
  .douta(), 			
  .clkb(clk), 		
  .web(1'b0), 			
  .addrb(sram_addr_b[10:0]), 	
  .dinb(128'b0), 		
  .doutb(sram_dout_b) 	
);

endmodule
