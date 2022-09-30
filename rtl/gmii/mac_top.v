`timescale 1ns / 1ps

module mac_top(
    input              clk,
	input              rstn,

    input     [7:0]    GMII_RXD,
    input              GMII_RX_DV,
    input              GMII_RX_CLK,
    input              GMII_RX_ER,
                 
    output    [7:0]    GMII_TXD,
    output             GMII_TX_EN,
    input              MII_TX_CLK,
    output             GMII_TX_CLK, 
    output             GMII_TX_ER,

    output             MDC,                       //phy emdio clock
    inout              MDIO,                      //phy emdio data   

    output    [1:0]    led,
    output             link,
                  
    output             tx_data_fifo_rd,
    input     [7:0]    tx_data_fifo_dout,
    output             tx_ptr_fifo_rd,
    input     [15:0]   tx_ptr_fifo_dout,
    input              tx_ptr_fifo_empty,
                  
    input             rx_data_fifo_rd,
    output    [7:0]   rx_data_fifo_dout,
    input             rx_ptr_fifo_rd,
	output    [15:0]  rx_ptr_fifo_dout,
    output            rx_ptr_fifo_empty,

    output             tx_tte_fifo_rd,
    input     [7:0]    tx_tte_fifo_dout,
    output             tx_tteptr_fifo_rd,
    input     [15:0]   tx_tteptr_fifo_dout,
    input              tx_tteptr_fifo_empty,
                  
    input             rx_tte_fifo_rd,
    output    [7:0]   rx_tte_fifo_dout,
    input             rx_tteptr_fifo_rd,
	output    [15:0]  rx_tteptr_fifo_dout,
    output            rx_tteptr_fifo_empty,

    output    [6:0]   port_addr,
    output    [15:0]  port_din,
    output            port_req,
    input             port_ack,

    input     [31:0]  counter_ns
    );

parameter   PORT_RX_ADDR = 7'h10;
parameter   PORT_TX_ADDR = 7'h11;
parameter   PORT_ER_ADDR = 7'h12;
parameter   INIT = 0;

wire            time_rst;

wire    [1:0]   speed;        

wire            rx_status_fifo_rd;
wire    [15:0]  rx_status_fifo_dout;
wire            rx_status_fifo_empty;

wire            tx_status_fifo_rd;
wire    [15:0]  tx_status_fifo_dout;
wire            tx_status_fifo_empty;

wire    [63:0]  counter_ns_tx_delay;
wire    [63:0]  counter_ns_gtx_delay;

mac_r_gmii u_mac_r_gmii(
    .clk(clk),
    .rstn(rstn),
    .rx_clk(GMII_RX_CLK),
    .rx_dv(GMII_RX_DV),
    .gm_rx_d(GMII_RXD),
    .gtx_clk(GMII_TX_CLK),
    .speed(speed),
    .data_fifo_rd(rx_data_fifo_rd),
    .data_fifo_dout(rx_data_fifo_dout),
    .ptr_fifo_rd(rx_ptr_fifo_rd),
    .ptr_fifo_dout(rx_ptr_fifo_dout),
    .ptr_fifo_empty(rx_ptr_fifo_empty),
    .tte_fifo_rd(rx_tte_fifo_rd),
    .tte_fifo_dout(rx_tte_fifo_dout),
    .tteptr_fifo_rd(rx_tteptr_fifo_rd),
    .tteptr_fifo_dout(rx_tteptr_fifo_dout),
    .tteptr_fifo_empty(rx_tteptr_fifo_empty),
    .status_fifo_rd(rx_status_fifo_rd),
    .status_fifo_dout(rx_status_fifo_dout),
    .status_fifo_empty(rx_status_fifo_empty),
    .counter_ns(counter_ns),
    .counter_ns_tx_delay(counter_ns_tx_delay),
    .counter_ns_gtx_delay(counter_ns_gtx_delay)
    );
mac_t_gmii u_mac_t_gmii(
    .clk(clk),
    .rstn(rstn),
    .tx_clk(MII_TX_CLK),
    .gtx_clk(GMII_TX_CLK),
    .gtx_dv(GMII_TX_EN),
    .gm_tx_d(GMII_TXD),
    .speed(speed),
    .data_fifo_rd(tx_data_fifo_rd),
    .data_fifo_din(tx_data_fifo_dout),
    .ptr_fifo_rd(tx_ptr_fifo_rd),
    .ptr_fifo_din(tx_ptr_fifo_dout),
    .ptr_fifo_empty(tx_ptr_fifo_empty),
    .tdata_fifo_rd(tx_tte_fifo_rd),
    .tdata_fifo_din(tx_tte_fifo_dout),
    .tptr_fifo_rd(tx_tteptr_fifo_rd),
    .tptr_fifo_din(tx_tteptr_fifo_dout),
    .tptr_fifo_empty(tx_tteptr_fifo_empty),
    .status_fifo_rd(tx_status_fifo_rd),
    .status_fifo_dout(tx_status_fifo_dout),
    .status_fifo_empty(tx_status_fifo_empty),
    .counter_ns(counter_ns),
    .counter_ns_tx_delay(counter_ns_tx_delay),
    .counter_ns_gtx_delay(counter_ns_gtx_delay)
    );

smi_config  #(
.REF_CLK                 (200                   ),        
.MDC_CLK                 (500                   )
)
smi_config_inst
(
.clk                    (clk                    ),
.rst_n                  (rstn                   ),         
.mdc                    (MDC                    ),
.mdio                   (MDIO                   ),
.link                   (link                   ),
.speed                  (speed                  ),
.led                    (led                    )    
);  

timer#(
.REF_CLK                (200 ),
.TIME                   (10  ),
.INIT                   (INIT)
)
timer_port_inst
(
.clk                    (clk),
.rst_n                  (rstn),
.time_rst               (time_rst)
);

port2reg    #(
.PORT_RX_ADDR           (PORT_RX_ADDR),
.PORT_TX_ADDR           (PORT_TX_ADDR),
.PORT_ER_ADDR           (PORT_ER_ADDR)    
)
port2reg_inst
(
.clk                    (clk),
.rst_n                  (rstn),
.time_rst               (time_rst),
.port_addr              (port_addr),
.port_din               (port_din),
.port_req               (port_req),
.port_ack               (port_ack),
.rx_status_fifo_rd      (rx_status_fifo_rd),
.rx_status_fifo_dout    (rx_status_fifo_dout),
.rx_status_fifo_empty   (rx_status_fifo_empty),
.tx_status_fifo_rd      (tx_status_fifo_rd),
.tx_status_fifo_dout    (tx_status_fifo_dout),
.tx_status_fifo_empty   (tx_status_fifo_empty)
);
endmodule
