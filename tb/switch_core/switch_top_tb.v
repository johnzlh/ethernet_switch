`timescale 1ns / 1ps

module switch_top_tb;
// Inputs
reg clk;
reg rstn;
reg data_sof;
reg data_dv;
reg [7:0] data_in;
reg ptr_fifo_rd0;
reg ptr_fifo_rd1;
reg ptr_fifo_rd2;
reg ptr_fifo_rd3;
reg data_fifo_rd0;
reg data_fifo_rd1;
reg data_fifo_rd2;
reg data_fifo_rd3;

// Outputs
wire [7:0] data_fifo_dout0;
wire [7:0] data_fifo_dout1;
wire [7:0] data_fifo_dout2;
wire [7:0] data_fifo_dout3;
wire [15:0] ptr_fifo_dout0;
wire [15:0] ptr_fifo_dout1;
wire [15:0] ptr_fifo_dout2;
wire [15:0] ptr_fifo_dout3;
wire ptr_fifo_empty0;
wire ptr_fifo_empty1;
wire ptr_fifo_empty2;
wire ptr_fifo_empty3;

always #5 clk=~clk;

// Instantiate the Unit Under Test (UUT)
switch_top uut (
	.clk(clk), 
	.rstn(rstn), 
	.sof(data_sof), 
	.dv(data_dv), 
	.din(data_in), 
	
	.ptr_fifo_rd0(ptr_fifo_rd0), 
	.ptr_fifo_rd1(ptr_fifo_rd1), 
	.ptr_fifo_rd2(ptr_fifo_rd2), 
	.ptr_fifo_rd3(ptr_fifo_rd3), 
	.data_fifo_rd0(data_fifo_rd0), 
	.data_fifo_rd1(data_fifo_rd1), 
	.data_fifo_rd2(data_fifo_rd2), 
	.data_fifo_rd3(data_fifo_rd3), 
	.data_fifo_dout0(data_fifo_dout0), 
	.data_fifo_dout1(data_fifo_dout1), 
	.data_fifo_dout2(data_fifo_dout2), 
	.data_fifo_dout3(data_fifo_dout3), 
	.ptr_fifo_dout0(ptr_fifo_dout0), 
	.ptr_fifo_dout1(ptr_fifo_dout1), 
	.ptr_fifo_dout2(ptr_fifo_dout2), 
	.ptr_fifo_dout3(ptr_fifo_dout3), 
	.ptr_fifo_empty0(ptr_fifo_empty0), 
	.ptr_fifo_empty1(ptr_fifo_empty1), 
	.ptr_fifo_empty2(ptr_fifo_empty2), 
	.ptr_fifo_empty3(ptr_fifo_empty3)
);

initial begin
	// Initialize Inputs
	clk = 0;
	rstn = 0;
	data_sof = 0;
	data_dv = 0;
	data_in = 0;
	ptr_fifo_rd0 = 0;
	ptr_fifo_rd1 = 0;
	ptr_fifo_rd2 = 0;
	ptr_fifo_rd3 = 0;
	data_fifo_rd0 = 0;
	data_fifo_rd1 = 0;
	data_fifo_rd2 = 0;
	data_fifo_rd3 = 0;

	// Wait 100 ns for global reset to finish
	#100;
    rstn=1;
	#10_000;
	// Add stimulus here
	send_frame(126,4'b1111);
	#100;
	send_frame(129,4'b1111);
	
	// Add stimulus here
	
end

task send_frame;
input	[11:0]	len;
input	[3:0]	portmap;
integer 		i;
reg		[11:0]	len_with_pad;
begin
	len_with_pad=len;
	if(len[5:0])begin
		len_with_pad=len_with_pad+64;
		len_with_pad={len_with_pad[11:6],6'b0};
		end
	repeat(1)@(posedge clk);
	#2;
	for(i=0;i<len_with_pad;i=i+1)begin
		if(i==0) begin
			data_sof=1;
			data_dv=1;
			data_in={len[11:8],portmap[3:0]};
			end
		else if(i==1) begin
			data_sof=0;
			data_dv=1;
			data_in=len[7:0];
			end
		else begin
			data_in=i[7:0];
			end
		repeat(1)@(posedge clk);
		#2;
		end
	data_dv=0;
	data_in=0;
	end
endtask

endmodule

