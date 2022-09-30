`timescale 1ns / 1ps
module top_switch(
input              sys_clk_p,                       //system clock positive
input              sys_clk_n,                       //system clock negative 
input              rstn,                            //reset ,low active
output    [1:0]    led,
//spi_slave
input              mosi,
input              csb,
input              sck,
output             miso,
//mac0 interface
input    [7:0]     GMII_RXD_0,
input              GMII_RX_DV_0,
input              GMII_RX_CLK_0,
input              GMII_RX_ER_0,
output   [7:0]     GMII_TXD_0,
output             GMII_TX_EN_0,
input              MII_TX_CLK_0,
output             GMII_TX_CLK_0,
output             GMII_TX_ER_0,
output             phy_rstn_0,
output             MDC_0,                       //phy emdio clock
inout              MDIO_0,                      //phy emdio data      
//mac1 interface
input    [7:0]     GMII_RXD_1,
input              GMII_RX_DV_1,
input              GMII_RX_CLK_1,
input              GMII_RX_ER_1,
output   [7:0]     GMII_TXD_1,
output             GMII_TX_EN_1,
input              MII_TX_CLK_1,
output             GMII_TX_CLK_1,
output             GMII_TX_ER_1,
output             phy_rstn_1,
output             MDC_1,                       //phy emdio clock
inout              MDIO_1,                      //phy emdio data     
//mac2 interface
input    [7:0]     GMII_RXD_2,
input              GMII_RX_DV_2,
input              GMII_RX_CLK_2,
input              GMII_RX_ER_2,
output   [7:0]     GMII_TXD_2,
output             GMII_TX_EN_2,
input              MII_TX_CLK_2,
output             GMII_TX_CLK_2,
output             GMII_TX_ER_2,
output             phy_rstn_2,
output             MDC_2,                       //phy emdio clock
inout              MDIO_2,                      //phy emdio data       
//mac3 interface
input    [7:0]     GMII_RXD_3,
input              GMII_RX_DV_3,
input              GMII_RX_CLK_3,
input              GMII_RX_ER_3,
output   [7:0]     GMII_TXD_3,
output             GMII_TX_EN_3,
input              MII_TX_CLK_3,
output             GMII_TX_CLK_3,
output             GMII_TX_ER_3,
output             phy_rstn_3,
output             MDC_3,                       //phy emdio clock
inout              MDIO_3                       //phy emdio data     
);

wire    [1:0]       led_r0;
wire    [1:0]       led_r1;
wire    [1:0]       led_r2;
wire    [1:0]       led_r3;

wire    [3:0]       link;

assign led = led_r0&led_r1&led_r2&led_r3;
//interface of interface mux and  switch_pos
wire	    	     emac0_tx_data_fifo_rd;
wire    [7:0]        emac0_tx_data_fifo_dout;
wire                 emac0_tx_ptr_fifo_rd;
wire    [15:0]       emac0_tx_ptr_fifo_dout;
wire                 emac0_tx_ptr_fifo_empty;
                     
wire                 emac0_rx_data_fifo_rd;
wire    [7:0]        emac0_rx_data_fifo_dout;
wire                 emac0_rx_ptr_fifo_rd;
wire    [15:0]       emac0_rx_ptr_fifo_dout;
wire                 emac0_rx_ptr_fifo_empty;

wire	    	     emac0_tx_tte_fifo_rd;
wire    [7:0]        emac0_tx_tte_fifo_dout;
wire                 emac0_tx_tteptr_fifo_rd;
wire    [15:0]       emac0_tx_tteptr_fifo_dout;
wire                 emac0_tx_tteptr_fifo_empty;
                     
wire                 emac0_rx_tte_fifo_rd;
wire    [7:0]        emac0_rx_tte_fifo_dout;
wire                 emac0_rx_tteptr_fifo_rd;
wire    [15:0]       emac0_rx_tteptr_fifo_dout;
wire                 emac0_rx_tteptr_fifo_empty;

wire	    	     emac1_tx_data_fifo_rd;
wire    [7:0]        emac1_tx_data_fifo_dout;
wire                 emac1_tx_ptr_fifo_rd;
wire    [15:0]       emac1_tx_ptr_fifo_dout;
wire                 emac1_tx_ptr_fifo_empty;
                     
wire                 emac1_rx_data_fifo_rd;
wire    [7:0]        emac1_rx_data_fifo_dout;
wire                 emac1_rx_ptr_fifo_rd;
wire    [15:0]       emac1_rx_ptr_fifo_dout;
wire                 emac1_rx_ptr_fifo_empty;

wire	    	     emac1_tx_tte_fifo_rd;
wire    [7:0]        emac1_tx_tte_fifo_dout;
wire                 emac1_tx_tteptr_fifo_rd;
wire    [15:0]       emac1_tx_tteptr_fifo_dout;
wire                 emac1_tx_tteptr_fifo_empty;
                     
wire                 emac1_rx_tte_fifo_rd;
wire    [7:0]        emac1_rx_tte_fifo_dout;
wire                 emac1_rx_tteptr_fifo_rd;
wire    [15:0]       emac1_rx_tteptr_fifo_dout;
wire                 emac1_rx_tteptr_fifo_empty;

wire	    	     emac2_tx_data_fifo_rd;
wire    [7:0]        emac2_tx_data_fifo_dout;
wire                 emac2_tx_ptr_fifo_rd;
wire    [15:0]       emac2_tx_ptr_fifo_dout;
wire                 emac2_tx_ptr_fifo_empty;
                     
wire                 emac2_rx_data_fifo_rd;
wire    [7:0]        emac2_rx_data_fifo_dout;
wire                 emac2_rx_ptr_fifo_rd;
wire    [15:0]       emac2_rx_ptr_fifo_dout;
wire                 emac2_rx_ptr_fifo_empty;

wire	    	     emac2_tx_tte_fifo_rd;
wire    [7:0]        emac2_tx_tte_fifo_dout;
wire                 emac2_tx_tteptr_fifo_rd;
wire    [15:0]       emac2_tx_tteptr_fifo_dout;
wire                 emac2_tx_tteptr_fifo_empty;
                     
wire                 emac2_rx_tte_fifo_rd;
wire    [7:0]        emac2_rx_tte_fifo_dout;
wire                 emac2_rx_tteptr_fifo_rd;
wire    [15:0]       emac2_rx_tteptr_fifo_dout;
wire                 emac2_rx_tteptr_fifo_empty;

wire	    	     emac3_tx_data_fifo_rd;
wire    [7:0]        emac3_tx_data_fifo_dout;
wire                 emac3_tx_ptr_fifo_rd;
wire    [15:0]       emac3_tx_ptr_fifo_dout;
wire                 emac3_tx_ptr_fifo_empty;
                     
wire                 emac3_rx_data_fifo_rd;
wire    [7:0]        emac3_rx_data_fifo_dout;
wire                 emac3_rx_ptr_fifo_rd;
wire    [15:0]       emac3_rx_ptr_fifo_dout;
wire                 emac3_rx_ptr_fifo_empty;

wire	    	     emac3_tx_tte_fifo_rd;
wire    [7:0]        emac3_tx_tte_fifo_dout;
wire                 emac3_tx_tteptr_fifo_rd;
wire    [15:0]       emac3_tx_tteptr_fifo_dout;
wire                 emac3_tx_tteptr_fifo_empty;
                     
wire                 emac3_rx_tte_fifo_rd;
wire    [7:0]        emac3_rx_tte_fifo_dout;
wire                 emac3_rx_tteptr_fifo_rd;
wire    [15:0]       emac3_rx_tteptr_fifo_dout;
wire                 emac3_rx_tteptr_fifo_empty;

wire                 clk;


wire	[6:0]	port0_addr;
wire	[15:0]	port0_din;
wire			port0_req;
wire			port0_ack;

wire	[6:0]	port1_addr;
wire	[15:0]	port1_din;
wire			port1_req;
wire			port1_ack;

wire	[6:0]	port2_addr;
wire	[15:0]	port2_din;
wire			port2_req;
wire			port2_ack;

wire	[6:0]	port3_addr;
wire	[15:0]	port3_din;
wire			port3_req;
wire			port3_ack;


wire    [31:0]  counter_ns;

counter counter_inst(
.clk                    (clk),
.rst_n                  (rstn),
.counter_ns             (counter_ns)
);

mac_top_ob#(
.PORT_RX_ADDR	(7'h10),
.PORT_TX_ADDR	(7'h11),
.PORT_ER_ADDR	(7'h12),
.INIT			(0	  )		
)
u_mac_top_0
(
    .clk(clk),
    .rstn(rstn),

    .GMII_RXD(GMII_RXD_0),
    .GMII_RX_DV(GMII_RX_DV_0),
    .GMII_RX_CLK(GMII_RX_CLK_0),
    .GMII_RX_ER(GMII_RX_ER_0),

    .GMII_TXD(GMII_TXD_0),
    .GMII_TX_EN(GMII_TX_EN_0),
    .MII_TX_CLK(MII_TX_CLK_0),
    .GMII_TX_CLK(GMII_TX_CLK_0),
    .GMII_TX_ER(GMII_TX_ER_0),

    .MDC(MDC_0),
    .MDIO(MDIO_0),

    .led(led_r0),
    .link(link[0]),
                     
    .rx_data_fifo_rd(emac0_rx_data_fifo_rd),
    .rx_data_fifo_dout(emac0_rx_data_fifo_dout),
    .rx_ptr_fifo_rd(emac0_rx_ptr_fifo_rd),
    .rx_ptr_fifo_dout(emac0_rx_ptr_fifo_dout),
    .rx_ptr_fifo_empty(emac0_rx_ptr_fifo_empty),
                     
    .tx_data_fifo_rd(emac0_tx_data_fifo_rd),
    .tx_data_fifo_dout(emac0_tx_data_fifo_dout),
    .tx_ptr_fifo_rd(emac0_tx_ptr_fifo_rd),
    .tx_ptr_fifo_dout(emac0_tx_ptr_fifo_dout),
    .tx_ptr_fifo_empty(emac0_tx_ptr_fifo_empty),

    .rx_tte_fifo_rd(emac0_rx_tte_fifo_rd),
    .rx_tte_fifo_dout(emac0_rx_tte_fifo_dout),
    .rx_tteptr_fifo_rd(emac0_rx_tteptr_fifo_rd),
    .rx_tteptr_fifo_dout(emac0_rx_tteptr_fifo_dout),
    .rx_tteptr_fifo_empty(emac0_rx_tteptr_fifo_empty),
                     
    .tx_tte_fifo_rd(emac0_tx_tte_fifo_rd),
    .tx_tte_fifo_dout(emac0_tx_tte_fifo_dout),
    .tx_tteptr_fifo_rd(emac0_tx_tteptr_fifo_rd),
    .tx_tteptr_fifo_dout(emac0_tx_tteptr_fifo_dout),
    .tx_tteptr_fifo_empty(emac0_tx_tteptr_fifo_empty),

	.port_addr(port0_addr),
	.port_din(port0_din),
	.port_req(port0_req),
	.port_ack(port0_ack),
	.counter_ns(counter_ns)
    );

mac_top_ob#(
.PORT_RX_ADDR	(7'h13),
.PORT_TX_ADDR	(7'h14),
.PORT_ER_ADDR	(7'h15),
.INIT			(1	  )
)
u_mac_top_1(
    .clk(clk),
    .rstn(rstn),

    .GMII_RXD(GMII_RXD_1),
    .GMII_RX_DV(GMII_RX_DV_1),
    .GMII_RX_CLK(GMII_RX_CLK_1),
    .GMII_RX_ER(GMII_RX_ER_1),

    .GMII_TXD(GMII_TXD_1),
    .GMII_TX_EN(GMII_TX_EN_1),
    .MII_TX_CLK(MII_TX_CLK_1),
    .GMII_TX_CLK(GMII_TX_CLK_1),
    .GMII_TX_ER(GMII_TX_ER_1),

    .MDC(MDC_1),
    .MDIO(MDIO_1),

    .led(led_r1),
    .link(link[1]),
                     
    .rx_data_fifo_rd(emac1_rx_data_fifo_rd),
    .rx_data_fifo_dout(emac1_rx_data_fifo_dout),
    .rx_ptr_fifo_rd(emac1_rx_ptr_fifo_rd),
    .rx_ptr_fifo_dout(emac1_rx_ptr_fifo_dout),
    .rx_ptr_fifo_empty(emac1_rx_ptr_fifo_empty),
                     
    .tx_data_fifo_rd(emac1_tx_data_fifo_rd),
    .tx_data_fifo_dout(emac1_tx_data_fifo_dout),
    .tx_ptr_fifo_rd(emac1_tx_ptr_fifo_rd),
    .tx_ptr_fifo_dout(emac1_tx_ptr_fifo_dout),
    .tx_ptr_fifo_empty(emac1_tx_ptr_fifo_empty),

    .rx_tte_fifo_rd(emac1_rx_tte_fifo_rd),
    .rx_tte_fifo_dout(emac1_rx_tte_fifo_dout),
    .rx_tteptr_fifo_rd(emac1_rx_tteptr_fifo_rd),
    .rx_tteptr_fifo_dout(emac1_rx_tteptr_fifo_dout),
    .rx_tteptr_fifo_empty(emac1_rx_tteptr_fifo_empty),
                     
    .tx_tte_fifo_rd(emac1_tx_tte_fifo_rd),
    .tx_tte_fifo_dout(emac1_tx_tte_fifo_dout),
    .tx_tteptr_fifo_rd(emac1_tx_tteptr_fifo_rd),
    .tx_tteptr_fifo_dout(emac1_tx_tteptr_fifo_dout),
    .tx_tteptr_fifo_empty(emac1_tx_tteptr_fifo_empty),

	.port_addr(port1_addr),
	.port_din(port1_din),
	.port_req(port1_req),
	.port_ack(port1_ack),
	.counter_ns(counter_ns)
    );
    
mac_top#(
.PORT_RX_ADDR	(7'h16),
.PORT_TX_ADDR	(7'h17),
.PORT_ER_ADDR	(7'h18),
.INIT			(2	  )
)
u_mac_top_2(
    .clk(clk),
    .rstn(rstn),

    .GMII_RXD(GMII_RXD_2),
    .GMII_RX_DV(GMII_RX_DV_2),
    .GMII_RX_CLK(GMII_RX_CLK_2),
    .GMII_RX_ER(GMII_RX_ER_2),

    .GMII_TXD(GMII_TXD_2),
    .GMII_TX_EN(GMII_TX_EN_2),
    .MII_TX_CLK(MII_TX_CLK_2),
    .GMII_TX_CLK(GMII_TX_CLK_2),
    .GMII_TX_ER(GMII_TX_ER_2),

    .MDC(MDC_2),
    .MDIO(MDIO_2),

    .led(led_r2),
    .link(link[2]),
                     
    .rx_data_fifo_rd(emac2_rx_data_fifo_rd),
    .rx_data_fifo_dout(emac2_rx_data_fifo_dout),
    .rx_ptr_fifo_rd(emac2_rx_ptr_fifo_rd),
    .rx_ptr_fifo_dout(emac2_rx_ptr_fifo_dout),
    .rx_ptr_fifo_empty(emac2_rx_ptr_fifo_empty),
                     
    .tx_data_fifo_rd(emac2_tx_data_fifo_rd),
    .tx_data_fifo_dout(emac2_tx_data_fifo_dout),
    .tx_ptr_fifo_rd(emac2_tx_ptr_fifo_rd),
    .tx_ptr_fifo_dout(emac2_tx_ptr_fifo_dout),
    .tx_ptr_fifo_empty(emac2_tx_ptr_fifo_empty),

    .rx_tte_fifo_rd(emac2_rx_tte_fifo_rd),
    .rx_tte_fifo_dout(emac2_rx_tte_fifo_dout),
    .rx_tteptr_fifo_rd(emac2_rx_tteptr_fifo_rd),
    .rx_tteptr_fifo_dout(emac2_rx_tteptr_fifo_dout),
    .rx_tteptr_fifo_empty(emac2_rx_tteptr_fifo_empty),
                     
    .tx_tte_fifo_rd(emac2_tx_tte_fifo_rd),
    .tx_tte_fifo_dout(emac2_tx_tte_fifo_dout),
    .tx_tteptr_fifo_rd(emac2_tx_tteptr_fifo_rd),
    .tx_tteptr_fifo_dout(emac2_tx_tteptr_fifo_dout),
    .tx_tteptr_fifo_empty(emac2_tx_tteptr_fifo_empty),

	.port_addr(port2_addr),
	.port_din(port2_din),
	.port_req(port2_req),
	.port_ack(port2_ack),
	.counter_ns(counter_ns)
    );
    
mac_top#(
.PORT_RX_ADDR	(7'h19),
.PORT_TX_ADDR	(7'h1a),
.PORT_ER_ADDR	(7'h1b),
.INIT			(3	  )
)
u_mac_top_3(
    .clk(clk),
    .rstn(rstn),

    .GMII_RXD(GMII_RXD_3),
    .GMII_RX_DV(GMII_RX_DV_3),
    .GMII_RX_CLK(GMII_RX_CLK_3),
    .GMII_RX_ER(GMII_RX_ER_3),

    .GMII_TXD(GMII_TXD_3),
    .GMII_TX_EN(GMII_TX_EN_3),
    .MII_TX_CLK(MII_TX_CLK_3),
    .GMII_TX_CLK(GMII_TX_CLK_3),
    .GMII_TX_ER(GMII_TX_ER_3),

    .MDC(MDC_3),
    .MDIO(MDIO_3),

    .led(led_r3),
    .link(link[3]),
                     
    .rx_data_fifo_rd(emac3_rx_data_fifo_rd),
    .rx_data_fifo_dout(emac3_rx_data_fifo_dout),
    .rx_ptr_fifo_rd(emac3_rx_ptr_fifo_rd),
    .rx_ptr_fifo_dout(emac3_rx_ptr_fifo_dout),
    .rx_ptr_fifo_empty(emac3_rx_ptr_fifo_empty),
                     
    .tx_data_fifo_rd(emac3_tx_data_fifo_rd),
    .tx_data_fifo_dout(emac3_tx_data_fifo_dout),
    .tx_ptr_fifo_rd(emac3_tx_ptr_fifo_rd),
    .tx_ptr_fifo_dout(emac3_tx_ptr_fifo_dout),
    .tx_ptr_fifo_empty(emac3_tx_ptr_fifo_empty),

    .rx_tte_fifo_rd(emac3_rx_tte_fifo_rd),
    .rx_tte_fifo_dout(emac3_rx_tte_fifo_dout),
    .rx_tteptr_fifo_rd(emac3_rx_tteptr_fifo_rd),
    .rx_tteptr_fifo_dout(emac3_rx_tteptr_fifo_dout),
    .rx_tteptr_fifo_empty(emac3_rx_tteptr_fifo_empty),
                     
    .tx_tte_fifo_rd(emac3_tx_tte_fifo_rd),
    .tx_tte_fifo_dout(emac3_tx_tte_fifo_dout),
    .tx_tteptr_fifo_rd(emac3_tx_tteptr_fifo_rd),
    .tx_tteptr_fifo_dout(emac3_tx_tteptr_fifo_dout),
    .tx_tteptr_fifo_empty(emac3_tx_tteptr_fifo_empty),

	.port_addr(port3_addr),
	.port_din(port3_din),
	.port_req(port3_req),
	.port_ack(port3_ack),
	.counter_ns(counter_ns)
    );
        

wire               sfifo_rd;
wire     [7:0]     sfifo_dout;
wire               ptr_sfifo_rd;
wire     [15:0]    ptr_sfifo_dout;
wire               ptr_sfifo_empty;
interface_mux u_interface_mux(
    .clk(clk),
	.rstn(rstn),
    .rx_data_fifo_dout0(emac0_rx_data_fifo_dout),
	.rx_data_fifo_rd0(emac0_rx_data_fifo_rd),
	.rx_ptr_fifo_dout0(emac0_rx_ptr_fifo_dout),
	.rx_ptr_fifo_rd0(emac0_rx_ptr_fifo_rd),
	.rx_ptr_fifo_empty0(emac0_rx_ptr_fifo_empty),
										 
	.rx_data_fifo_dout1(emac1_rx_data_fifo_dout),
	.rx_data_fifo_rd1(emac1_rx_data_fifo_rd),
	.rx_ptr_fifo_dout1(emac1_rx_ptr_fifo_dout),
	.rx_ptr_fifo_rd1(emac1_rx_ptr_fifo_rd),
	.rx_ptr_fifo_empty1(emac1_rx_ptr_fifo_empty),
										 
	.rx_data_fifo_dout2(emac2_rx_data_fifo_dout),
	.rx_data_fifo_rd2(emac2_rx_data_fifo_rd),
	.rx_ptr_fifo_dout2(emac2_rx_ptr_fifo_dout),
	.rx_ptr_fifo_rd2(emac2_rx_ptr_fifo_rd),
	.rx_ptr_fifo_empty2(emac2_rx_ptr_fifo_empty),
										 
	.rx_data_fifo_dout3(emac3_rx_data_fifo_dout),
	.rx_data_fifo_rd3(emac3_rx_data_fifo_rd),
	.rx_ptr_fifo_dout3(emac3_rx_ptr_fifo_dout),
	.rx_ptr_fifo_rd3(emac3_rx_ptr_fifo_rd),
	.rx_ptr_fifo_empty3(emac3_rx_ptr_fifo_empty),
										 
	.sfifo_rd(sfifo_rd),
	.sfifo_dout(sfifo_dout),
	.ptr_sfifo_rd(ptr_sfifo_rd),
	.ptr_sfifo_dout(ptr_sfifo_dout),
	.ptr_sfifo_empty(ptr_sfifo_empty)
    );

wire               tte_sfifo_rd;
wire     [7:0]     tte_sfifo_dout;
wire               tteptr_sfifo_rd;
wire     [15:0]    tteptr_sfifo_dout;
wire               tteptr_sfifo_empty;
interface_mux u_tteinterface_mux(
    .clk(clk),
	.rstn(rstn),
    .rx_data_fifo_dout0(emac0_rx_tte_fifo_dout),
	.rx_data_fifo_rd0(emac0_rx_tte_fifo_rd),
	.rx_ptr_fifo_dout0(emac0_rx_tteptr_fifo_dout),
	.rx_ptr_fifo_rd0(emac0_rx_tteptr_fifo_rd),
	.rx_ptr_fifo_empty0(emac0_rx_tteptr_fifo_empty),
										 
	.rx_data_fifo_dout1(emac1_rx_tte_fifo_dout),
	.rx_data_fifo_rd1(emac1_rx_tte_fifo_rd),
	.rx_ptr_fifo_dout1(emac1_rx_tteptr_fifo_dout),
	.rx_ptr_fifo_rd1(emac1_rx_tteptr_fifo_rd),
	.rx_ptr_fifo_empty1(emac1_rx_tteptr_fifo_empty),
										 
	.rx_data_fifo_dout2(emac2_rx_tte_fifo_dout),
	.rx_data_fifo_rd2(emac2_rx_tte_fifo_rd),
	.rx_ptr_fifo_dout2(emac2_rx_tteptr_fifo_dout),
	.rx_ptr_fifo_rd2(emac2_rx_tteptr_fifo_rd),
	.rx_ptr_fifo_empty2(emac2_rx_tteptr_fifo_empty),
										 
	.rx_data_fifo_dout3(emac3_rx_tte_fifo_dout),
	.rx_data_fifo_rd3(emac3_rx_tte_fifo_rd),
	.rx_ptr_fifo_dout3(emac3_rx_tteptr_fifo_dout),
	.rx_ptr_fifo_rd3(emac3_rx_tteptr_fifo_rd),
	.rx_ptr_fifo_empty3(emac3_rx_tteptr_fifo_empty),
										 
	.sfifo_rd(tte_sfifo_rd),
	.sfifo_dout(tte_sfifo_dout),
	.ptr_sfifo_rd(tteptr_sfifo_rd),
	.ptr_sfifo_dout(tteptr_sfifo_dout),
	.ptr_sfifo_empty(tteptr_sfifo_empty)
    );
                               
wire         sof;
wire         dv;
wire  [7:0]  data;
wire         se_source;
wire  [47:0] se_mac;
wire  [15:0] source_portmap;
wire         se_req;
wire         se_ack;
wire  [15:0] se_result;   
wire  [9:0]  se_hash;
wire         se_nak;
wire         aging_req;
wire         aging_ack;

wire         bp0;
wire  		 bp1;
wire		 bp2;
wire         bp3;

frame_process u_frame_process(
    .clk(clk),
	.rstn(rstn),
	.sfifo_dout(sfifo_dout),
	.sfifo_rd(sfifo_rd),
	.ptr_sfifo_rd(ptr_sfifo_rd),
	.ptr_sfifo_empty(ptr_sfifo_empty),
	.ptr_sfifo_dout(ptr_sfifo_dout),
										 
    .sof(sof),
	.dv(dv),
	.data(data),
										 
	.se_mac(se_mac),
	.se_req(se_req),
	.se_ack(se_ack),
	.source_portmap(source_portmap),
	.se_result(se_result),
	.se_nak(se_nak),
	.se_source(se_source),
	.se_hash(se_hash),
    .link(link),
										 
	.bp0(bp0),
	.bp1(bp1),
	.bp2(bp2),
	.bp3(bp3)
							   	                             
    );
hash_2_bucket u_hash(
    .clk(clk),
	.rstn(rstn),
	.se_req(se_req),
	.se_ack(se_ack),
	.se_hash(se_hash),
	.se_portmap(source_portmap),
	.se_source(se_source),
	.se_result(se_result),
	.se_nak(se_nak),
	.se_mac(se_mac),
	.aging_req(),
	.aging_ack()
    );

switch_top switch(
	.clk(clk),
	.rstn(rstn),
	
	.sof(sof),
	.dv(dv),
	.din(data),
	
	.ptr_fifo_rd0(emac0_tx_ptr_fifo_rd),
	.ptr_fifo_rd1(emac1_tx_ptr_fifo_rd),
	.ptr_fifo_rd2(emac2_tx_ptr_fifo_rd),
	.ptr_fifo_rd3(emac3_tx_ptr_fifo_rd),
	.data_fifo_rd0(emac0_tx_data_fifo_rd),
	.data_fifo_rd1(emac1_tx_data_fifo_rd),
	.data_fifo_rd2(emac2_tx_data_fifo_rd),
	.data_fifo_rd3(emac3_tx_data_fifo_rd),
	.data_fifo_dout0(emac0_tx_data_fifo_dout),
	.data_fifo_dout1(emac1_tx_data_fifo_dout),
	.data_fifo_dout2(emac2_tx_data_fifo_dout),
	.data_fifo_dout3(emac3_tx_data_fifo_dout),
	.ptr_fifo_dout0(emac0_tx_ptr_fifo_dout),
	.ptr_fifo_dout1(emac1_tx_ptr_fifo_dout),
	.ptr_fifo_dout2(emac2_tx_ptr_fifo_dout),
	.ptr_fifo_dout3(emac3_tx_ptr_fifo_dout),
	.ptr_fifo_empty0(emac0_tx_ptr_fifo_empty),
	.ptr_fifo_empty1(emac1_tx_ptr_fifo_empty),
	.ptr_fifo_empty2(emac2_tx_ptr_fifo_empty),
	.ptr_fifo_empty3(emac3_tx_ptr_fifo_empty)
	);

wire         tte_sof;
wire         tte_dv;
wire  [7:0]  tte_data;
wire  [47:0] tte_se_dmac;
wire  [47:0] tte_se_smac;
wire         tte_se_req;
wire         tte_se_ack;
wire  [15:0] tte_se_result;   
wire  [9:0]  tte_se_hash;
wire         tte_se_nak;

wire         tte_bp0;
wire  		 tte_bp1;
wire		 tte_bp2;
wire         tte_bp3;

tteframe_process u_tteframe_process(
    .clk(clk),
	.rstn(rstn),
	.sfifo_dout(tte_sfifo_dout),
	.sfifo_rd(tte_sfifo_rd),
	.ptr_sfifo_rd(tteptr_sfifo_rd),
	.ptr_sfifo_empty(tteptr_sfifo_empty),
	.ptr_sfifo_dout(tteptr_sfifo_dout),
										 
    .sof(tte_sof),
	.dv(tte_dv),
	.data(tte_data),
										 
	.se_dmac(tte_se_dmac),
	.se_smac(tte_se_smac),
	.se_req(tte_se_req),
	.se_ack(tte_se_ack),
	.se_result(tte_se_result),
	.se_nak(tte_se_nak),
	.se_hash(tte_se_hash),
    .link(link),
										 
	.bp0(tte_bp0),
	.bp1(tte_bp1),
	.bp2(tte_bp2),
	.bp3(tte_bp3)
							   	                             
    );

wire	hash_clear;
wire	hash_update;
wire	[9:0]	hash;
wire	[119:0]	flow;
wire	reg_rst;

hash_tte_bucket u_ttehash(
    .clk(clk),
	.rstn(rstn),
	.se_req(tte_se_req),
	.se_ack(tte_se_ack),
	.se_hash(tte_se_hash),
	.se_result(tte_se_result),
	.se_nak(tte_se_nak),
	.se_dmac(tte_se_dmac),
	.se_smac(tte_se_smac),
	.hash_clear(hash_clear),
	.hash_update(hash_update),
	.hash(hash),
	.flow(flow),
	.reg_rst(reg_rst)
    );

wire	[127:0]	flow_mux;
wire	[9:0]	hash_mux;
wire	r_hash_clear;
wire	r_hash_update;
wire	ttehash_req;
wire	ttehash_ack;

bus2ttehash	bus2ttehashinst(
    .clk(clk),
	.rstn(rstn),
	.flow_mux(flow_mux[119:0]),
	.hash_mux(hash_mux),
	.flow(flow),
	.hash(hash),
	.hash_clear(hash_clear),
	.hash_update(hash_update),
	.r_hash_clear(r_hash_clear),
	.r_hash_update(r_hash_update),
	.reg_rst(reg_rst),
	.ttehash_req(ttehash_req),
	.ttehash_ack(ttehash_ack)
);




wire    spi_req;
wire    spi_ack;
wire    [6:0]   spi_addr;
wire    [15:0]  spi_din;
wire    [15:0]  spi_dout;


reg_ctrl	reg_ctrl_inst(
    .clk(clk),
	.rst_n(rstn),

	.spi_req(spi_req),
	.spi_ack(spi_ack),
	.spi_addr(spi_addr),
	.spi_din(spi_din),
	.spi_dout(spi_dout),

	.ttehash_req(ttehash_req),
	.ttehash_ack(ttehash_ack),

	.port0_req(port0_req),
	.port0_ack(port0_ack),
	.port0_addr(port0_addr),
	.port0_din(port0_din),

	.port1_req(port1_req),
	.port1_ack(port1_ack),
	.port1_addr(port1_addr),
	.port1_din(port1_din),

	.port2_req(port2_req),
	.port2_ack(port2_ack),
	.port2_addr(port2_addr),
	.port2_din(port2_din),

	.port3_req(port3_req),
	.port3_ack(port3_ack),
	.port3_addr(port3_addr),
	.port3_din(port3_din),

	.r_hash_clear(r_hash_clear),
	.r_hash_update(r_hash_update),
	.r_flow_mux(flow_mux),
	.r_hash(hash_mux)
);

spi_process    spi_process_inst
(
.clk        (clk),
.rst_n      (rstn),
.csb        (csb),
.mosi       (mosi),
.sck        (sck),
.miso       (miso),
.reg_dout   (spi_dout),
.spi_req    (spi_req),
.spi_ack    (spi_ack),
.spi_addr   (spi_addr),
.reg_din    (spi_din)
);

switch_top tteswitch(
	.clk(clk),
	.rstn(rstn),
	
	.sof(tte_sof),
	.dv(tte_dv),
	.din(tte_data),
	
	.ptr_fifo_rd0(emac0_tx_tteptr_fifo_rd),
	.ptr_fifo_rd1(emac1_tx_tteptr_fifo_rd),
	.ptr_fifo_rd2(emac2_tx_tteptr_fifo_rd),
	.ptr_fifo_rd3(emac3_tx_tteptr_fifo_rd),
	.data_fifo_rd0(emac0_tx_tte_fifo_rd),
	.data_fifo_rd1(emac1_tx_tte_fifo_rd),
	.data_fifo_rd2(emac2_tx_tte_fifo_rd),
	.data_fifo_rd3(emac3_tx_tte_fifo_rd),
	.data_fifo_dout0(emac0_tx_tte_fifo_dout),
	.data_fifo_dout1(emac1_tx_tte_fifo_dout),
	.data_fifo_dout2(emac2_tx_tte_fifo_dout),
	.data_fifo_dout3(emac3_tx_tte_fifo_dout),
	.ptr_fifo_dout0(emac0_tx_tteptr_fifo_dout),
	.ptr_fifo_dout1(emac1_tx_tteptr_fifo_dout),
	.ptr_fifo_dout2(emac2_tx_tteptr_fifo_dout),
	.ptr_fifo_dout3(emac3_tx_tteptr_fifo_dout),
	.ptr_fifo_empty0(emac0_tx_tteptr_fifo_empty),
	.ptr_fifo_empty1(emac1_tx_tteptr_fifo_empty),
	.ptr_fifo_empty2(emac2_tx_tteptr_fifo_empty),
	.ptr_fifo_empty3(emac3_tx_tteptr_fifo_empty)
	);

/*************************************************************************
generate single end clock
**************************************************************************/
IBUFDS sys_clk_ibufgds
(
.O                              (clk                     ),
.I                              (sys_clk_p               ),
.IB                             (sys_clk_n               )
);

assign  phy_rstn_0=1'b1;
assign  phy_rstn_1=1'b1;
assign  phy_rstn_2=1'b1;
assign  phy_rstn_3=1'b1;
endmodule
