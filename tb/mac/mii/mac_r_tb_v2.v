`timescale 1ns / 1ps

module mac_r_tb_v2;

// Inputs
reg rstn;
reg	clk;
reg rx_clk;
reg rx_dv;
reg [3:0] rx_d;
reg data_fifo_rd;
reg ptr_fifo_rd;

// Outputs
wire [7:0] data_fifo_dout;
wire [15:0] ptr_fifo_dout;
wire ptr_fifo_empty;

always #12.5	rx_clk=~rx_clk;
always #5   	clk=!clk;

reg	[7:0]	mem_send	[2047:0];
integer		m;
initial begin
	m=0;
	for(m=0;m<2_000;m=m+1) mem_send[m]=0;
	m=0;
	end

// Instantiate the Unit Under Test (UUT)
mac_r u_mac_r (
	.rstn(rstn), 
	.clk(clk),
	.rx_clk(rx_clk), 
	.rx_dv(rx_dv), 
	.rx_d(rx_d), 
	.data_fifo_rd(data_fifo_rd), 
	.data_fifo_dout(data_fifo_dout), 
	.ptr_fifo_rd(ptr_fifo_rd), 
	.ptr_fifo_dout(ptr_fifo_dout), 
	.ptr_fifo_empty(ptr_fifo_empty)
);

initial begin
	// Initialize Inputs
	rstn = 0;
	clk=0;
	rx_clk = 0;
	rx_dv = 0;
	rx_d = 0;
	data_fifo_rd = 0;
	ptr_fifo_rd = 0;

	// Wait 100 ns for global reset to finish
	#100;
    rstn=1;
	// Add stimulus here
	#100;
    send_mac_frame(100,48'hf0f1f2f3f4f5,48'he0e1e2e3e4e5,16'h0800,1'b0);
    repeat(22)@(posedge rx_clk);		
    send_mac_frame(100,48'hf0f1f2f3f4f5,48'he0e1e2e3e4e5,16'h0800,1'b1);
    repeat(22)@(posedge rx_clk);
    send_mac_frame(59,48'hf0f1f2f3f4f5,48'he0e1e2e3e4e5,16'h0800,1'b1);
    repeat(22)@(posedge rx_clk);
    send_mac_frame(1515,48'hf0f1f2f3f4f5,48'he0e1e2e3e4e5,16'h0800,1'b1);
end


task send_mac_frame;
input	[10:0]	length;
input	[47:0]	da;
input	[47:0]	sa;
input	[15:0]	len_type;
input			crc_error_insert;
integer 		i;	
reg		[7:0]	mii_din;
reg		[31:0]	fcs;
begin 
	fcs=0;
	rx_d = 0;
	rx_dv = 0;
	repeat(1)@(posedge rx_clk);
	#2;
	repeat(1)@(posedge rx_clk);
	#2;
	rx_dv = 1;
	rx_d=8'h5;
	repeat(15)@(posedge rx_clk);
	#2;
	rx_d=8'hd;	
	repeat(1)@(posedge rx_clk);
	#2;
	for(i=0;i<length;i=i+1)begin
		//emac head
		if		(i==0) 	mii_din=da[47:40];	
		else if	(i==1) 	mii_din=da[39:32];
		else if	(i==2) 	mii_din=da[31:24];
		else if	(i==3) 	mii_din=da[23:16];
		else if	(i==4) 	mii_din=da[15:8] ;
		else if	(i==5) 	mii_din=da[7:0]  ;
		else if	(i==6) 	mii_din=sa[47:40];
		else if	(i==7) 	mii_din=sa[39:32];
		else if	(i==8) 	mii_din=sa[31:24];
		else if	(i==9) 	mii_din=sa[23:16];
		else if	(i==10)	mii_din=sa[15:8] ;
		else if	(i==11)	mii_din=sa[7:0]  ;
		else if (i==12)	mii_din=len_type[15:8];
		else if (i==13)	mii_din=len_type[7:0];
		else mii_din={$random}%256;
		mem_send[i]=mii_din;
		calc_crc(mii_din,fcs);
		//start to send data.
		rx_d=mii_din[3:0];
		repeat(1)@(posedge rx_clk);
		#2;
		rx_d=mii_din[7:4];
		repeat(1)@(posedge rx_clk);
		#2;
		end
	
	if(crc_error_insert)fcs=~fcs;
	
	rx_d=fcs[3:0];
	repeat(1)@(posedge rx_clk);
	#2;
	rx_d=fcs[7:4];
	repeat(1)@(posedge rx_clk);
	#2;
	rx_d=fcs[11:8];
	repeat(1)@(posedge rx_clk);
	#2;
	rx_d=fcs[15:12];
	repeat(1)@(posedge rx_clk);
	#2;
	rx_d=fcs[19:16];
	repeat(1)@(posedge rx_clk);
	#2;
	rx_d=fcs[23:20];
	repeat(1)@(posedge rx_clk);
	#2;
	rx_d=fcs[27:24];
	repeat(1)@(posedge rx_clk);
	#2;
	rx_d=fcs[31:28];
	repeat(1)@(posedge rx_clk);
	#2;
	rx_dv=0;
	repeat(1)@(posedge rx_clk);
	m=m+14;
	end
endtask


task calc_crc;
input	[7:0]  	data;
inout  	[31:0] 	fcs;
reg 	[31:0] 	crc;
reg        	   	crc_feedback;	  
integer    		i;
begin
	crc = ~fcs;
	for (i = 0; i < 8; i = i + 1)
	begin
		crc_feedback = crc[0] ^ data[i];
		crc[0]       = crc[1];
		crc[1]       = crc[2];
		crc[2]       = crc[3];
		crc[3]       = crc[4];
		crc[4]       = crc[5];
		crc[5]       = crc[6]  ^ crc_feedback;
		crc[6]       = crc[7];
		crc[7]       = crc[8];
		crc[8]       = crc[9]  ^ crc_feedback;
		crc[9]       = crc[10] ^ crc_feedback;
		crc[10]      = crc[11];
		crc[11]      = crc[12];
		crc[12]      = crc[13];
		crc[13]      = crc[14];
		crc[14]      = crc[15];
		crc[15]      = crc[16] ^ crc_feedback;
		crc[16]      = crc[17];
		crc[17]      = crc[18];
		crc[18]      = crc[19];
		crc[19]      = crc[20] ^ crc_feedback;
		crc[20]      = crc[21] ^ crc_feedback;
		crc[21]      = crc[22] ^ crc_feedback;
		crc[22]      = crc[23];
		crc[23]      = crc[24] ^ crc_feedback;
		crc[24]      = crc[25] ^ crc_feedback;
		crc[25]      = crc[26];
		crc[26]      = crc[27] ^ crc_feedback;
		crc[27]      = crc[28] ^ crc_feedback;
		crc[28]      = crc[29];
		crc[29]      = crc[30] ^ crc_feedback;
		crc[30]      = crc[31] ^ crc_feedback;
		crc[31]      =           crc_feedback;
	end
	fcs = ~crc;
	end
endtask 
  
endmodule

