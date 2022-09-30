`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/22 15:57:45
// Design Name: 
// Module Name: spi_process
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
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_process(
input                           rst_n,                        //reset ,low active
input                           clk,
//spi_slave
input                           mosi,
input                           csb,
input                           sck,
output                          miso,
//internal_bus
input       [15:0]              reg_dout,
output  reg                     spi_req,
input                           spi_ack,
output  reg [6:0]               spi_addr,
output  reg [15:0]              reg_din
    );

parameter DELAY = 2;

wire    rec_flag;
wire    [7:0]   rec_data;
reg     [7:0]   send_data;
reg     rec_flag_reg0;
reg     rec_flag_reg1;

reg             spi_we;
reg     [2:0]   spi_state;


always@(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        rec_flag_reg0 <=#DELAY 1'b0;
        rec_flag_reg1 <=#DELAY 1'b0;
    end
    else begin
        rec_flag_reg0 <=#DELAY rec_flag;
        rec_flag_reg1 <=#DELAY rec_flag_reg0;
    end
end

wire    rec_flag_dv;
assign  rec_flag_dv = rec_flag_reg0 & !rec_flag_reg1;

wire    sfd;
assign  sfd = (rec_data==8'hd5);

spi_slave    spi_slave_inst
(
.clk        (clk),
.nrst       (rst_n),
.ncs        (csb),
.mosi       (mosi),
.sck        (sck),
.miso       (miso),
.send_data  (send_data),
.rec_flag   (rec_flag),
.rec_data   (rec_data)
);

always@(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        spi_state <=#DELAY 3'b0;
        spi_we  <=#DELAY 1'b0;
        spi_req <=#DELAY 1'b0;
        spi_addr <=#DELAY 7'b0;
        reg_din <=#DELAY 16'b0;
        send_data <=#DELAY 8'hd5;
    end
    else begin
        case(spi_state)
        3'b000: begin
            if(rec_flag_dv & sfd)
                spi_state <=#DELAY 3'b001;
                send_data <=#DELAY 8'hd5;
        end
        3'b001: begin
            if(rec_flag_dv & sfd)begin
                spi_state <=#DELAY 3'b010;
                send_data <=#DELAY 8'h00;
                end
            else if(rec_flag_dv & !sfd)
                spi_state <=#DELAY 3'b000;
        end
        3'b010: begin
            if(rec_flag_dv)begin
                spi_we  <=#DELAY rec_data[7];
                spi_addr <=#DELAY rec_data[6:0];
                send_data <=#DELAY reg_dout[15:8];
                spi_state <=#DELAY 3'b011;
            end
        end
        3'b011: begin
            if(rec_flag_dv)begin
                reg_din[15:8]  <=#DELAY rec_data;
                send_data <=#DELAY reg_dout[7:0];
                spi_state <=#DELAY 3'b100;
            end
        end
        3'b100: begin
            if(rec_flag_dv)begin
                spi_req  <=#DELAY spi_we;
                reg_din[7:0]  <=#DELAY rec_data;
                send_data <=#DELAY 8'hd5;
                spi_state <=#DELAY 3'b110;
            end
        end
        3'b110: begin
            if(spi_ack | !spi_req)begin
                spi_req  <=#DELAY 0;
                spi_state <=#DELAY 3'b000;
            end
        end
    endcase
    end
end

endmodule
