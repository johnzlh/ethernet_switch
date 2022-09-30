`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/19 21:28:41
// Design Name: 
// Module Name: register_table_tb
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




module register_table_tb;

// register_table Parameters
parameter PERIOD                        = 5   ;
parameter DEFAULT_REGISTER_WIDTH        = 16   ;
parameter DEFAULT_REGISTER_RESET_VALUE  = 0    ;
parameter SPI_POINTER_ADDR              = 7'h00;
parameter TABLE_MODER_ADDR              = 7'h01;
parameter TABLE_CTRL_ADDR               = 7'h02;
parameter TABLE_HASH_ADDR               = 7'h03;
parameter PORT0_RX_ADDR                 = 7'h10;
parameter PORT0_TX_ADDR                 = 7'h11;
parameter PORT0_ER_ADDR                 = 7'h12;
parameter PORT1_RX_ADDR                 = 7'h13;
parameter PORT1_TX_ADDR                 = 7'h14;
parameter PORT1_ER_ADDR                 = 7'h15;
parameter PORT2_RX_ADDR                 = 7'h16;
parameter PORT2_TX_ADDR                 = 7'h17;
parameter PORT2_ER_ADDR                 = 7'h18;
parameter PORT3_RX_ADDR                 = 7'h19;
parameter PORT3_TX_ADDR                 = 7'h1a;
parameter PORT3_ER_ADDR                 = 7'h1b;
parameter TABLE_ST0_ADDR                = 7'h30;
parameter TABLE_ST1_ADDR                = 7'h31;
parameter TABLE_ST2_ADDR                = 7'h32;
parameter TABLE_ST3_ADDR                = 7'h33;
parameter TABLE_ST4_ADDR                = 7'h34;
parameter TABLE_ST5_ADDR                = 7'h35;
parameter TABLE_ST6_ADDR                = 7'h36;
parameter TABLE_ST7_ADDR                = 7'h37;

// register_table Inputs
reg   clk                                  = 0 ;
reg   rst                                  = 0 ;
reg   [6:0]  addr                          = 0 ;
reg   wr                                   = 0 ;
reg   [15:0]  din                          = 0 ;
reg   [6:0]  addr_r                        = 0 ;

// register_table Outputs
wire  [15:0]  dout                         ;
wire  [15:0]  spi_dout                     ;
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
    #(PERIOD*10) rst  =  1;
end

initial
begin
    #(PERIOD*20);
    addr = PORT0_RX_ADDR;
    din = 16'h00f0;
    wr = 1;
    #(PERIOD*1);
    wr = 0;
    #(PERIOD*1);
    addr = PORT1_RX_ADDR;
    din = 16'h00f1;
    wr = 1;
    #(PERIOD*1);
    wr = 0;
    #(PERIOD*1);
    addr = PORT2_RX_ADDR;
    din = 16'h00f2;
    wr = 1;
    #(PERIOD*1);
    wr = 0;
    #(PERIOD*1);
    addr = PORT3_RX_ADDR;
    din = 16'h00f3;
    wr = 1;
    #(PERIOD*1);
    wr = 0;
    #(PERIOD*1);
    addr = SPI_POINTER_ADDR;
    din = PORT0_RX_ADDR;
    wr = 1;
    #(PERIOD*1);
    wr = 0;
    #(PERIOD*1);
    addr = SPI_POINTER_ADDR;
    din = PORT1_RX_ADDR;
    wr = 1;
    #(PERIOD*1);
    wr = 0;
    #(PERIOD*1);
    addr = SPI_POINTER_ADDR;
    din = PORT2_RX_ADDR;
    wr = 1;
    #(PERIOD*1);
    wr = 0;
    #(PERIOD*1);
    addr = SPI_POINTER_ADDR;
    din = PORT3_RX_ADDR;
    wr = 1;
    #(PERIOD*1);
    wr = 0;
    #(PERIOD*1);
    addr_r = SPI_POINTER_ADDR;
    #(PERIOD*5);
    addr_r = PORT0_RX_ADDR;
    #(PERIOD*5);
    addr_r = PORT1_RX_ADDR;
    #(PERIOD*5);
    addr_r = PORT2_RX_ADDR;
    #(PERIOD*5);
    addr_r = PORT3_RX_ADDR;
    #(PERIOD*5);
end

register_table #(
    .DEFAULT_REGISTER_WIDTH       ( DEFAULT_REGISTER_WIDTH       ),
    .DEFAULT_REGISTER_RESET_VALUE ( DEFAULT_REGISTER_RESET_VALUE ),
    .SPI_POINTER_ADDR             ( SPI_POINTER_ADDR             ),
    .TABLE_MODER_ADDR             ( TABLE_MODER_ADDR             ),
    .TABLE_CTRL_ADDR              ( TABLE_CTRL_ADDR              ),
    .TABLE_HASH_ADDR              ( TABLE_HASH_ADDR              ),
    .PORT0_RX_ADDR                ( PORT0_RX_ADDR                ),
    .PORT0_TX_ADDR                ( PORT0_TX_ADDR                ),
    .PORT0_ER_ADDR                ( PORT0_ER_ADDR                ),
    .PORT1_RX_ADDR                ( PORT1_RX_ADDR                ),
    .PORT1_TX_ADDR                ( PORT1_TX_ADDR                ),
    .PORT1_ER_ADDR                ( PORT1_ER_ADDR                ),
    .PORT2_RX_ADDR                ( PORT2_RX_ADDR                ),
    .PORT2_TX_ADDR                ( PORT2_TX_ADDR                ),
    .PORT2_ER_ADDR                ( PORT2_ER_ADDR                ),
    .PORT3_RX_ADDR                ( PORT3_RX_ADDR                ),
    .PORT3_TX_ADDR                ( PORT3_TX_ADDR                ),
    .PORT3_ER_ADDR                ( PORT3_ER_ADDR                ),
    .TABLE_ST0_ADDR               ( TABLE_ST0_ADDR               ),
    .TABLE_ST1_ADDR               ( TABLE_ST1_ADDR               ),
    .TABLE_ST2_ADDR               ( TABLE_ST2_ADDR               ),
    .TABLE_ST3_ADDR               ( TABLE_ST3_ADDR               ),
    .TABLE_ST4_ADDR               ( TABLE_ST4_ADDR               ),
    .TABLE_ST5_ADDR               ( TABLE_ST5_ADDR               ),
    .TABLE_ST6_ADDR               ( TABLE_ST6_ADDR               ),
    .TABLE_ST7_ADDR               ( TABLE_ST7_ADDR               ))
 u_register_table (
    .clk                     ( clk                    ),
    .rst                     ( rst                    ),
    .addr                    ( addr           [6:0]   ),
    .wr                      ( wr                     ),
    .din                     ( din            [15:0]  ),
    .addr_r                  ( addr_r         [6:0]   ),

    .dout                    ( dout           [15:0]  ),
    .spi_dout                ( spi_dout       [15:0]  ),
    .r_hash_clear            ( r_hash_clear           ),
    .r_hash_update           ( r_hash_update          ),
    .r_flow_mux              ( r_flow_mux     [127:0] ),
    .r_hash                  ( r_hash         [9:0]   )
);



endmodule