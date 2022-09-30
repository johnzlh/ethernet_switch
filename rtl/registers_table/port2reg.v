`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/09 03:14:30
// Design Name: 
// Module Name: port2reg
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


module port2reg(
input               clk,
input               rst_n,

input               time_rst,

output  reg [6:0]   port_addr,
output  reg [15:0]  port_din,
output  reg         port_req,
input               port_ack,

output  reg         rx_status_fifo_rd, 
input       [15:0]  rx_status_fifo_dout,
input               rx_status_fifo_empty,

output  reg         tx_status_fifo_rd, 
input       [15:0]  tx_status_fifo_dout,
input               tx_status_fifo_empty
    );


parameter   PORT_RX_ADDR = 7'h10;
parameter   PORT_TX_ADDR = 7'h11;
parameter   PORT_ER_ADDR = 7'h12;
parameter   DELAY = 2;


reg	    [31:0]		 rx_flow;
reg 	[31:0]		 tx_flow;
reg     [15:0]       rx_crc_rt;

reg	    [15:0]		 rx_flow_send;
reg 	[15:0]		 tx_flow_send;
reg     [15:0]       rx_crc_rt_send;


reg [1:0]   rx_state;
always @(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        rx_flow <=#DELAY 0;
        rx_crc_rt <=#DELAY 0;
        rx_state <=#DELAY 0;
    end
    else if(time_rst) rx_state <=#DELAY 3;
    else begin
        rx_status_fifo_rd <=#DELAY 0;
        case(rx_state)
        0: begin
            if(!rx_status_fifo_empty) begin
                rx_status_fifo_rd <=#DELAY 1;
                rx_state <=#DELAY 1;
            end
        end
        1: begin
            rx_state <=#DELAY 2;
        end
        2: begin
            rx_flow <= rx_flow + rx_status_fifo_dout[11:0];
            rx_crc_rt[15:8] <= rx_crc_rt[15:8] + 1;
            rx_crc_rt[7:0] <= rx_crc_rt[7:0] + rx_status_fifo_dout[15];
            rx_state <=#DELAY 0;
        end
        3:begin
            rx_flow <=#DELAY 0;
            rx_crc_rt <=#DELAY 0;
            rx_state <=#DELAY 0;
        end
    endcase
    end
end

reg [1:0]   tx_state;
always @(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        tx_flow <=#DELAY 0;
        tx_state <=#DELAY 0;
    end
    else if(time_rst) tx_state <=#DELAY 3;
    else begin
        tx_status_fifo_rd <=#DELAY 0;
        case(tx_state)
        0: begin
            if(!tx_status_fifo_empty) begin
                tx_status_fifo_rd <=#DELAY 1;
                tx_state <=#DELAY 1;
            end
        end
        1: begin
            tx_state <=#DELAY 2;
        end
        2: begin
            tx_flow <= rx_flow + tx_status_fifo_dout[11:0];
            tx_state <=#DELAY 0;
        end
        3: begin
            tx_flow <=#DELAY 0;
            tx_state <=#DELAY 0;
        end
    endcase
    end
end

always @(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        rx_flow_send <=#DELAY 0;
        tx_flow_send <=#DELAY 0;
        rx_crc_rt_send <=#DELAY 0;
    end
    else begin
        if(time_rst)begin
            rx_flow_send <=#DELAY rx_flow[15:0];
            tx_flow_send <=#DELAY tx_flow[15:0];
            rx_crc_rt_send <=#DELAY rx_crc_rt;
        end
    end
end

reg [3:0]  state;
always @(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        port_addr <=#DELAY 0;
        port_din <=#DELAY 0;
        port_req <=#DELAY 0;
        state <=#DELAY 0;
    end
    else begin
        case(state)
        0: begin
            if(time_rst)
            state <=#DELAY 1;
        end
        1: begin
            port_addr <=#DELAY PORT_RX_ADDR;
            port_din <=#DELAY rx_flow_send;
            port_req <=#DELAY 1;
            state <=#DELAY 2;
        end
        2: begin
            if(port_ack)begin
                port_req <=#DELAY 0;
                state <=#DELAY 3;
            end
        end
        3: begin
            state <=#DELAY 4;
        end
        4: begin
            port_addr <=#DELAY PORT_TX_ADDR;
            port_din <=#DELAY tx_flow_send;
            port_req <=#DELAY 1;
            state <=#DELAY 5;
        end
        5: begin
            if(port_ack)begin
                port_req <=#DELAY 0;
                state <=#DELAY 6;
            end
        end
        6: begin
            state <=#DELAY 7;
        end
        7: begin
            port_addr <=#DELAY PORT_ER_ADDR;
            port_din <=#DELAY rx_crc_rt_send;
            port_req <=#DELAY 1;
            state <=#DELAY 8;
        end
        8: begin
            if(port_ack)begin
                port_req <=#DELAY 0;
                state <=#DELAY 9;
            end
        end
        9: begin
            state <=#DELAY 0;
        end
    endcase
    end
end

endmodule