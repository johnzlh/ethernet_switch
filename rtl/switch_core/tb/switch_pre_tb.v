`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:15:27 02/12/2020
// Design Name:   switch_pre
// Module Name:   F:/design_book/switch_fabric_v2/switch_pre_tb.v
// Project Name:  simple_mac
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: switch_pre
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module switch_pre_tb;

	// Inputs
	reg clk;
	reg rstn;
	reg data_sof;
	reg data_dv;
	reg [7:0] data_in;
	reg i_cell_ack;

	// Outputs
	wire [127:0] i_cell_fifo_dout;
	wire i_cell_fifo_wr;

	wire [15:0]	i_cell_ptr_fifo_dout;
	wire		i_cell_ptr_fifo_wr; 
	
	always #5 clk=~clk;

	// Instantiate the Unit Under Test (UUT)
	switch_pre uut (
		.clk(clk), 
		.rstn(rstn), 
		.sof(data_sof), 
		.dv(data_dv), 
		.din(data_in), 
		.i_cell_data_fifo_dout(i_cell_fifo_dout), 
		.i_cell_data_fifo_wr(i_cell_fifo_wr), 
		.i_cell_ptr_fifo_dout(i_cell_ptr_fifo_dout), 
		.i_cell_ptr_fifo_wr(i_cell_ptr_fifo_wr), 
		.i_cell_bp(1'b0)
		);

	initial begin
		// Initialize Inputs
		clk = 0;
		rstn = 0;
		data_sof = 0;
		data_dv = 0;
		data_in = 0;
		i_cell_ack = 0;

		// Wait 100 ns for global reset to finish
		#500;
        rstn=1;
		#500;
		// Add stimulus here
		send_frame(128,4'b0001);
		#100;
		send_frame(256,4'b0001);
		#100
		send_frame(64,4'b0001);

	end

task send_frame;
input	[11:0]	len;
input	[3:0]	portmap;
integer 		i;
begin
	repeat(1)@(posedge clk);
	#2;
	for(i=0;i<len;i=i+1)begin
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

