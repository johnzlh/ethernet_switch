`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/13 19:22:45
// Design Name: 
// Module Name: reg_ctrl_tb
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


module reg_ctrl_tb;
// reg_ctrl Parameters
parameter PERIOD = 5;
parameter DELAY  = 2;

// reg_ctrl Inputs
reg   rst_n                                = 0 ;
reg   clk                                  = 0 ;
reg   spi_req                              = 0 ;
reg   [6:0]  spi_addr                      = 0 ;
reg   [15:0]  spi_din                      = 0 ;
reg   ttehash_req                          = 0 ;
reg   port0_req                            = 0 ;
reg   [6:0]  port0_addr                    = 0 ;
reg   [15:0]  port0_din                    = 0 ;
reg   port1_req                            = 0 ;
reg   [6:0]  port1_addr                    = 0 ;
reg   [15:0]  port1_din                    = 0 ;
reg   port2_req                            = 0 ;
reg   [6:0]  port2_addr                    = 0 ;
reg   [15:0]  port2_din                    = 0 ;
reg   port3_req                            = 0 ;
reg   [6:0]  port3_addr                    = 0 ;
reg   [15:0]  port3_din                    = 0 ;

// reg_ctrl Outputs
wire  spi_ack                              ;
wire  [15:0]  spi_dout                     ;
wire  ttehash_ack                          ;
wire  port0_ack                            ;
wire  port1_ack                            ;
wire  port2_ack                            ;
wire  port3_ack                            ;
wire  r_hash_clear                         ;
wire  r_hash_update                        ;
wire  [127:0]  r_flow_mux                  ;
wire  [9:0]  r_hash                        ;


initial
begin
    forever #2.5  clk=~clk;
end

initial
begin
    #(PERIOD*10) rst_n  =  1;
end

initial
begin
    #2.5;
    #(PERIOD*20);
    port0_req = 1;
    port0_addr = 7'h10;
    port0_din = 16'h0010;
    port1_req = 1;
    port1_addr = 7'h13;
    port1_din = 16'h0011;
    #(PERIOD*1);
    if(port0_ack == 1) port0_req = 0;
    if(port1_ack == 1) port1_req = 0;
    #(PERIOD*1);
    if(port0_ack == 1) port0_req = 0;
    if(port1_ack == 1) port1_req = 0;
    #(PERIOD*1);
    if(port0_ack == 1) port0_req = 0;
    if(port1_ack == 1) port1_req = 0;
    #(PERIOD*1);
    if(port0_ack == 1) port0_req = 0;
    if(port1_ack == 1) port1_req = 0;
    #(PERIOD*1);
    if(port0_ack == 1) port0_req = 0;
    if(port1_ack == 1) port1_req = 0;
    #(PERIOD*1);
    if(port0_ack == 1) port0_req = 0;
    if(port1_ack == 1) port1_req = 0;
    #(PERIOD*1);
    if(port0_ack == 1) port0_req = 0;
    if(port1_ack == 1) port1_req = 0;
    #(PERIOD*1);
    if(port0_ack == 1) port0_req = 0;
    if(port1_ack == 1) port1_req = 0;
    #(PERIOD*1);
    if(port0_ack == 1) port0_req = 0;
    if(port1_ack == 1) port1_req = 0;
    #(PERIOD*1);
    if(port0_ack == 1) port0_req = 0;
    if(port1_ack == 1) port1_req = 0;
    #(PERIOD*1);
    if(port0_ack == 1) port0_req = 0;
    if(port1_ack == 1) port1_req = 0;
end


initial
begin
    #2.5;
    #(PERIOD*20);
    spi_req = 1;
    spi_addr = 7'h02;
    spi_din = 16'h0055;
    #(PERIOD*1);
    if(spi_ack == 1) spi_req = 0;
    #(PERIOD*1);
    if(spi_ack == 1) spi_req = 0;
    #(PERIOD*1);
    if(spi_ack == 1) spi_req = 0;
    #(PERIOD*6);
    spi_req = 1;
    spi_addr = 7'h00;
    spi_din = 7'h10;
    #(PERIOD*1);
    if(spi_ack == 1) spi_req = 0;
    #(PERIOD*1);
    if(spi_ack == 1) spi_req = 0;
end


initial
begin
    #2.5;
    #(PERIOD*20);
    ttehash_req = 1;
    #(PERIOD*1);
    if(ttehash_ack == 1) ttehash_req = 0;
    #(PERIOD*1);
    if(ttehash_ack == 1) ttehash_req = 0;
    #(PERIOD*1);
    if(ttehash_ack == 1) ttehash_req = 0;
    #(PERIOD*1);
    if(ttehash_ack == 1) ttehash_req = 0;
    #(PERIOD*1);
    if(ttehash_ack == 1) ttehash_req = 0;
    #(PERIOD*1);
    if(ttehash_ack == 1) ttehash_req = 0;
end

reg_ctrl #(
    .DELAY ( DELAY ))
 u_reg_ctrl (
    .rst_n                   ( rst_n                  ),
    .clk                     ( clk                    ),
    .spi_req                 ( spi_req                ),
    .spi_addr                ( spi_addr       [6:0]   ),
    .spi_din                 ( spi_din        [15:0]  ),
    .ttehash_req             ( ttehash_req            ),
    .port0_req               ( port0_req              ),
    .port0_addr              ( port0_addr     [6:0]   ),
    .port0_din               ( port0_din      [15:0]  ),
    .port1_req               ( port1_req              ),
    .port1_addr              ( port1_addr     [6:0]   ),
    .port1_din               ( port1_din      [15:0]  ),
    .port2_req               ( port2_req              ),
    .port2_addr              ( port2_addr     [6:0]   ),
    .port2_din               ( port2_din      [15:0]  ),
    .port3_req               ( port3_req              ),
    .port3_addr              ( port3_addr     [6:0]   ),
    .port3_din               ( port3_din      [15:0]  ),

    .spi_ack                 ( spi_ack                ),
    .spi_dout                ( spi_dout       [15:0]  ),
    .ttehash_ack             ( ttehash_ack            ),
    .port0_ack               ( port0_ack              ),
    .port1_ack               ( port1_ack              ),
    .port2_ack               ( port2_ack              ),
    .port3_ack               ( port3_ack              ),
    .r_hash_clear            ( r_hash_clear           ),
    .r_hash_update           ( r_hash_update          ),
    .r_flow_mux              ( r_flow_mux     [127:0] ),
    .r_hash                  ( r_hash         [9:0]   )
);



endmodule
