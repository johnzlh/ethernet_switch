`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/20 10:39:04
// Design Name: 
// Module Name: spi_slave_v2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//  CPOL = 0;
//  CPHA = 0;
//  MSB;
//  8bits;
//  CS(NSS) is low active;
//  rec_flag is the one bit receive flag, the duration of the clock cycle is determined by the value of rec_flag_width 
//  Cs is used to reset spi in order to deal with communication misalignment.
//  Cs is low active and maybe not be reliable(There are signal glitches.). 
//  This slave inst determines whether to reset by sampling multiple clock cycles.
//////////////////////////////////////////////////////////////////////////////////


module spi_slave(
    input               clk,
    input               nrst,
    input               ncs,
    input               mosi,
    input               sck,
    output  reg         miso,
    input   [7:0]       send_data,
    output  reg         rec_flag,
    output  reg [7:0]   rec_data
    );
parameter DELAY = 2;

reg [2:0]   ncs_reg;
always @ (posedge clk or negedge nrst)
begin
    if(~nrst)
    begin
        ncs_reg <=#DELAY 3'b000;
    end
    else
    begin
        ncs_reg <=#DELAY {ncs_reg[1:0], ncs};
    end
end

wire    ncs_high = (ncs_reg == 3'b111);

reg[2:0] sck_edge;
always @ (posedge clk or negedge nrst)
begin
    if(~nrst)
    begin
        sck_edge <=#DELAY 3'b000;
    end
    else
    begin
        sck_edge <=#DELAY {sck_edge[1:0], sck};
    end
end
wire sck_riseedge, sck_falledge;
	assign sck_riseedge = (sck_edge[2:1] == 2'b01);  //检测到SCK由0变成1，则认为发现上跳沿
	assign sck_falledge = (sck_edge[2:1] == 2'b10);  //检测到SCK由1变成0，则认为发现下跳沿

reg[7:0] byte_received;
reg[2:0] bit_received_cnt;
reg[1:0] rec_status;  //SPI接收部分状态机
reg[2:0] rec_flag_width;  //SPI接收完成标志位脉冲宽度寄存器
always @ (posedge clk or negedge nrst)  //每次sck都会接收数据，spi的顶端模块状态机决定是否取用
begin
    if(~nrst)
    begin
        byte_received <=#DELAY 8'h00;
        bit_received_cnt <=#DELAY 3'h0;
        rec_flag <=#DELAY 1'b0;
        rec_data <=#DELAY 8'h00;
        rec_status <=#DELAY 2'b00;
        rec_flag_width <=#DELAY 3'b000;
    end
    else
    begin
        case (rec_status)
        2'b00:  begin
            if(sck_riseedge) begin
                byte_received <=#DELAY {byte_received[6:0], mosi};
                bit_received_cnt <=#DELAY bit_received_cnt+1;
                rec_status<= #DELAY 2'b01;     
            end
        end
        2'b01:  begin
            if(ncs_high) begin
                rec_status<= #DELAY 2'b11;     
            end
            else if(sck_riseedge)
            begin
                byte_received <=#DELAY {byte_received[6:0], mosi};
                if(bit_received_cnt > 3'h6)
                begin
                    rec_status <=#DELAY 2'b10;
                end
                else
                begin
                    bit_received_cnt <=#DELAY bit_received_cnt+1;
                end
            end
        end
        2'b10:  begin
            rec_data <=#DELAY byte_received;
            rec_flag <=#DELAY 1'b1;
            if(rec_flag_width==3'b100) begin
                rec_flag_width <=#DELAY 3'b000;
                rec_status <=#DELAY 2'b11;
            end
            else begin
                rec_flag_width <=#DELAY rec_flag_width+1;
            end
        end
        2'b11:  begin
            byte_received <=#DELAY 0;
            bit_received_cnt <=#DELAY 3'b000;
            rec_flag <=#DELAY 1'b0;
            rec_status <=#DELAY 2'b00;
        end
        endcase
    end
end


reg[7:0] byte_send;  //发送移位寄存器
reg[2:0] bit_sended_cnt;  //SPI发送位计数器
reg[1:0] send_status;  //SPI发送部分状态机
always @ (posedge clk or negedge nrst)
begin
    if(~nrst)
    begin
        byte_send <=#DELAY 8'h00;
        bit_sended_cnt <=#DELAY 3'b000;
        miso <=#DELAY 1'b0;
        send_status <=#DELAY 2'b00;
    end
    else
    begin
        case (send_status)
        2'b00:  begin
            byte_send <=#DELAY {send_data[6:0],1'b0};//锁存发送数据
            miso <=#DELAY send_data[7];
            if(sck_riseedge)
                send_status <=#DELAY 2'b01;  //2'b01;
            end
        2'b01:  begin  //根据sck下降沿改变数据
                if(ncs_high) begin
                    send_status<= #DELAY 2'b10;     
                end 
                else if(sck_falledge)   ///---------------------------------------这里多移了一位
                begin
                    if(bit_sended_cnt > 3'b110)
                    begin
                        send_status <=#DELAY 2'b10;
                    end
                    else
                    begin
                        bit_sended_cnt <=#DELAY bit_sended_cnt+1;
                        miso <=#DELAY byte_send[7];
                        byte_send <=#DELAY {byte_send[6:0], 1'b0};
                    end
                end
            end
        2'b10:  begin  //数据发送完毕
            miso <=#DELAY 1'b0;
            bit_sended_cnt <=#DELAY 3'b000;
            send_status <=#DELAY 2'b00;
            end
        2'b11:  begin  //数据发送完毕
            miso <=#DELAY 1'b0;
            bit_sended_cnt <=#DELAY 3'b000;
            send_status <=#DELAY 2'b00;
            end
        endcase
    end
end

endmodule
