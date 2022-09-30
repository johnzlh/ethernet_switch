`timescale 1ns/1ns
module crc_test();
    reg clk, reset;
    reg [7:0]d;
    reg load_init;
    reg calc;
    reg data_valid;
    wire [31:0]crc_reg;
    wire [7:0] crc;
initial 
    begin
        clk=0;
        reset=0;
        load_init=0;
        calc=0;
        data_valid=0;
        d=0;
    end
always  begin  #10 clk=1;#10 clk=0; end
always 
    begin
        crc_reset;
        crc_cal;
    end
task crc_reset;
    begin
        reset=1;
        repeat(2)@(posedge clk);
        #5;
        reset=0;
        repeat(2)@(posedge clk);
    end
endtask

task crc_cal;
    begin
        repeat(5) @(posedge clk);
        #5;  load_init=1;  repeat(1)@(posedge clk);
        #5; load_init=0; data_valid=1; calc=1; d=8'haa;
        repeat(1)@(posedge clk);
        #5;data_valid=1; calc=1; d=8'hbb; repeat(1)@(posedge clk);		
        #5; data_valid=1; calc=1; d=8'hcc; repeat(1)@(posedge clk);		
        #5; data_valid=1; calc=1; d=8'hdd; repeat(1)@(posedge clk);
        #5; data_valid=1; calc=0; d=8'haa;
        repeat(1)@(posedge clk);			
        #5; data_valid=1; calc=0; d=8'hbb;
        repeat(1)@(posedge clk);	
        #5; data_valid=1; calc=0; d=8'hcc;
        repeat(1)@(posedge clk);	
        #5; data_valid=1; calc=0; d=8'hdd;
        repeat(1)@(posedge clk);
        #5; data_valid=0;
        repeat(10)@(posedge clk);	
    end	
endtask	

crc32_8023 my_crc_test(.clk(clk), .reset(reset), .d(d), .load_init(load_init),
    .calc(calc), .d_valid(data_valid), .crc_reg(crc_reg), .crc(crc));
endmodule
