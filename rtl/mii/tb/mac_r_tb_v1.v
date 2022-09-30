`timescale 1ns / 1ps
module mac_r_tb_v1;
reg rstn;
reg clk;
reg rx_clk;
reg rx_dv;
reg [3:0] rx_d;
reg data_fifo_rd;
reg ptr_fifo_rd;
wire [7:0] data_fifo_dout;
wire [15:0] ptr_fifo_dout;
wire ptr_fifo_empty;

always #20    rx_clk=~rx_clk;
always #5     clk=!clk;
reg [7:0]   mem_send    [2047:0];
integer     m;
initial begin
    m=0;
    for(m=0;m<2_000;m=m+1) mem_send[m]=0;
    m=0;
    end

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
    rstn = 0;
    clk=0;
    rx_clk = 0;
    rx_dv = 0;
    rx_d = 0;
    data_fifo_rd = 0;
    ptr_fifo_rd = 0;

    #100;
    rstn=1;
    #100;
    send_mac_frame(100,48'hf0f1f2f3f4f5,48'he0e1e2e3e4e5,16'h0800,1'b0);
    repeat(22)@(posedge rx_clk);		
    send_mac_frame(100,48'hf0f1f2f3f4f5,48'he0e1e2e3e4e5,16'h0800,1'b1);
    repeat(22)@(posedge rx_clk);
    send_mac_frame(59,48'hf0f1f2f3f4f5,48'he0e1e2e3e4e5,16'h0800,1'b1);
    repeat(22)@(posedge rx_clk);
    send_mac_frame(1515,48'hf0f1f2f3f4f5,48'he0e1e2e3e4e5,16'h0800,1'b1);
end
reg         	load_init;
reg         	calc_en; 
reg         	d_valid;
reg [7:0]  		crc_din;
wire [7:0]  	crc_out;
wire [31:0]		crc_reg;
initial begin
    load_init=0;
    calc_en=0; 
    crc_din=0;
    d_valid=0;
    end
task send_mac_frame;
input   [10:0]  length;		
input   [47:0]  da;			
input   [47:0]  sa;			
input   [15:0]  len_type;	
input          crc_error_insert;
integer         i;  		
reg     [7:0]   mii_din;	
reg     [31:0]  fcs;		
begin 
    fcs=0;
    rx_d = 0;
    rx_dv = 0;
    repeat(1)@(posedge rx_clk);
    #2;
    load_init=1;
    repeat(1)@(posedge rx_clk);
    #2;
    load_init=0;
    rx_dv = 1;
    rx_d=8'h5;
    repeat(15)@(posedge rx_clk);
    #2;
    rx_d=8'hd;  
    repeat(1)@(posedge rx_clk);
    #2;
    for(i=0;i<length;i=i+1)begin
        //emac head
        if    (i==0)  mii_din=da[47:40];  
        else if (i==1)  mii_din=da[39:32];
        else if (i==2)  mii_din=da[31:24];
        else if (i==3)  mii_din=da[23:16];
        else if (i==4)  mii_din=da[15:8] ;
        else if (i==5)  mii_din=da[7:0]  ;
        else if (i==6)  mii_din=sa[47:40];
        else if (i==7)  mii_din=sa[39:32];
        else if (i==8)  mii_din=sa[31:24];
        else if (i==9)  mii_din=sa[23:16];
        else if (i==10) mii_din=sa[15:8] ;
        else if (i==11) mii_din=sa[7:0]  ;
        else if (i==12) mii_din=len_type[15:8];
        else if (i==13) mii_din=len_type[7:0];
        else mii_din={$random}%256;
        mem_send[i]=mii_din;
        //start to send data.
        rx_d=mii_din[3:0];
        calc_en=1; 
        crc_din=mii_din[7:0];
        d_valid=1;
        repeat(1)@(posedge rx_clk);
        #2;
        rx_d=mii_din[7:4];
        calc_en=0; 
        crc_din=mii_din[7:0];
        d_valid=0;
        repeat(1)@(posedge rx_clk);
        #2;
        end
    d_valid=1;
    if(!crc_error_insert) crc_din=crc_out[7:0];
    else crc_din=~crc_out[7:0];
    rx_d=crc_din[3:0];
    repeat(1)@(posedge rx_clk);
    #2;
    d_valid=0;
    rx_d=crc_din[7:4];
    repeat(1)@(posedge rx_clk);
    #2;
    d_valid=1;
    if(!crc_error_insert) crc_din=crc_out[7:0];
    else crc_din=~crc_out[7:0];
    rx_d=crc_din[3:0];
    repeat(1)@(posedge rx_clk);
    #2;
    d_valid=0;
    rx_d=crc_din[7:4];
    repeat(1)@(posedge rx_clk);
    #2;
    d_valid=1;
    if(!crc_error_insert) crc_din=crc_out[7:0];
    else crc_din=~crc_out[7:0];
    rx_d=crc_din[3:0];
    repeat(1)@(posedge rx_clk);
    #2;
    d_valid=0;
    rx_d=crc_din[7:4];
    repeat(1)@(posedge rx_clk);
    #2;
    d_valid=1;
    if(!crc_error_insert) crc_din=crc_out[7:0];
    else crc_din=~crc_out[7:0];
    rx_d=crc_din[3:0];
    repeat(1)@(posedge rx_clk);
    #2;
    d_valid=0;
    rx_d=crc_din[7:4];
    repeat(1)@(posedge rx_clk);
    #2;
    rx_dv=0;
    end
endtask

crc32_8023 u_crc32_8023(
    .clk(rx_clk), 
    .reset(!rstn), 
    .d(crc_din[7:0]), 
    .load_init(load_init),
    .calc(calc_en), 
    .d_valid(d_valid), 
    .crc_reg(crc_reg), 
    .crc(crc_out)
    );
endmodule
