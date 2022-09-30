`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/22 20:37:40
// Design Name: 
// Module Name: regtable_ctrl
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


module reg_ctrl(
input               rst_n,
input               clk,

input               spi_req,
output  reg         spi_ack,
input   [6:0]       spi_addr,
input   [15:0]      spi_din,
output  [15:0]      spi_dout,

input               ttehash_req,
output  reg         ttehash_ack,

input               port0_req,
output  reg         port0_ack,
input   [6:0]       port0_addr,
input   [15:0]      port0_din,

input               port1_req,
output  reg         port1_ack,
input   [6:0]       port1_addr,
input   [15:0]      port1_din,

input               port2_req,
output  reg         port2_ack,
input   [6:0]       port2_addr,
input   [15:0]      port2_din,

input               port3_req,
output  reg         port3_ack,
input   [6:0]       port3_addr,
input   [15:0]      port3_din,

output              r_hash_clear,
output              r_hash_update,
output  [127:0]     r_flow_mux,
output  [9:0]       r_hash
    );
parameter DELAY = 2;




reg         wr;

reg [2:0]   sel;
reg [1:0]   state;
always@(posedge clk or  negedge rst_n)begin
    if(~rst_n)begin
        wr <=#DELAY 1'b0;
        spi_ack <=#DELAY 0;
        ttehash_ack <=#DELAY 0;
        port0_ack <=#DELAY 0;
        port1_ack <=#DELAY 0;
        port2_ack <=#DELAY 0;
        port3_ack <=#DELAY 0;
        sel <=#DELAY 0;
        state <=#DELAY 0;
    end
    else begin
        case(state)
        0:begin
            if(spi_req)begin
                wr <=#DELAY 1;
                spi_ack <=#DELAY 1;
                sel <=#DELAY 0;
                state <=#DELAY 1;
            end
            else if(ttehash_req)begin
                wr <=#DELAY 1;
                ttehash_ack <=#DELAY 1;
                sel <=#DELAY 1;
                state <=#DELAY 1;
            end
            else if(port0_req)begin
                wr <=#DELAY 1;
                port0_ack <=#DELAY 1;
                sel <=#DELAY 2;
                state <=#DELAY 1;
            end
            else if(port1_req)begin
                wr <=#DELAY 1;
                port1_ack <=#DELAY 1;
                sel <=#DELAY 3;
                state <=#DELAY 1;
            end
            else if(port2_req)begin
                wr <=#DELAY 1;
                port2_ack <=#DELAY 1;
                sel <=#DELAY 4;
                state <=#DELAY 1;
            end
            else if(port3_req)begin
                wr <=#DELAY 1;
                port3_ack <=#DELAY 1;
                sel <=#DELAY 5;
                state <=#DELAY 1;
            end
        end
        1:begin
            wr <=#DELAY 0;
            spi_ack <=#DELAY 0;
            ttehash_ack <=#DELAY 0;
            port0_ack <=#DELAY 0;
            port1_ack <=#DELAY 0;
            port2_ack <=#DELAY 0;
            port3_ack <=#DELAY 0;
            state <=#DELAY 0;
        end
    endcase
    end
end

wire [6:0]  addr;

wire [15:0] din;

assign  addr=   (sel==0)?spi_addr:
                (sel==1)?7'h02:
                (sel==2)?port0_addr:
                (sel==3)?port1_addr:
                (sel==4)?port2_addr:port3_addr;

assign  din=    (sel==0)?spi_din:
                (sel==1)?16'h0:
                (sel==2)?port0_din:
                (sel==3)?port1_din:
                (sel==4)?port2_din:port3_din;

register_table register_table_inst
(
.clk            (clk),
.rst            (rst_n),
.addr           (addr),
.wr             (wr),
.din            (din),
.addr_r         (),
.dout           (),
.spi_dout       (spi_dout),
.r_hash_clear   (r_hash_clear),
.r_hash_update  (r_hash_update),
.r_flow_mux     (r_flow_mux),
.r_hash         (r_hash)
);

endmodule
