`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/13 11:20:18
// Design Name: 
// Module Name: register_table
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
// internal bus :Dual port with synchronous write & asynchronous read
// spi bus :    Independent read only port
// 
//////////////////////////////////////////////////////////////////////////////////


module register_table(
input               clk,
input               rst,
input   [6:0]       addr,
input               wr,
input   [15:0]      din,
input   [6:0]       addr_r,
output  reg [15:0]  dout,
output  reg [15:0]  spi_dout,
output              r_hash_clear,
output              r_hash_update,
output  [127:0]     r_flow_mux,
output  [9:0]       r_hash
);


parameter   DEFAULT_REGISTER_WIDTH = 16;
parameter   DEFAULT_REGISTER_RESET_VALUE = 0;

parameter   SPI_POINTER_ADDR = 7'h00;
parameter   TABLE_MODER_ADDR = 7'h01;
parameter   TABLE_CTRL_ADDR = 7'h02;
parameter   TABLE_HASH_ADDR = 7'h03;

parameter   PORT0_RX_ADDR = 7'h10;
parameter   PORT0_TX_ADDR = 7'h11;
parameter   PORT0_ER_ADDR = 7'h12;

parameter   PORT1_RX_ADDR = 7'h13;
parameter   PORT1_TX_ADDR = 7'h14;
parameter   PORT1_ER_ADDR = 7'h15;

parameter   PORT2_RX_ADDR = 7'h16;
parameter   PORT2_TX_ADDR = 7'h17;
parameter   PORT2_ER_ADDR = 7'h18;

parameter   PORT3_RX_ADDR = 7'h19;
parameter   PORT3_TX_ADDR = 7'h1a;
parameter   PORT3_ER_ADDR = 7'h1b;

parameter   TABLE_ST0_ADDR = 7'h30;
parameter   TABLE_ST1_ADDR = 7'h31;
parameter   TABLE_ST2_ADDR = 7'h32;
parameter   TABLE_ST3_ADDR = 7'h33;
parameter   TABLE_ST4_ADDR = 7'h34;
parameter   TABLE_ST5_ADDR = 7'h35;
parameter   TABLE_ST6_ADDR = 7'h36;
parameter   TABLE_ST7_ADDR = 7'h37;

wire SPI_POINTER_SEL = (addr == SPI_POINTER_ADDR);
wire SPI_POINTER_WR = wr & SPI_POINTER_SEL;
wire TABLE_MODER_SEL = (addr == TABLE_MODER_ADDR);
wire TABLE_MODER_WR = wr & TABLE_MODER_SEL;
wire TABLE_CTRL_SEL = (addr == TABLE_CTRL_ADDR);
wire TABLE_CTRL_WR = wr & TABLE_CTRL_SEL;
wire TABLE_HASH_SEL = (addr == TABLE_HASH_ADDR);
wire TABLE_HASH_WR = wr & TABLE_HASH_SEL;

wire PORT0_RX_SEL = (addr == PORT0_RX_ADDR);
wire PORT0_RX_WR = wr & PORT0_RX_SEL;
wire PORT0_TX_SEL = (addr == PORT0_TX_ADDR);
wire PORT0_TX_WR = wr & PORT0_TX_SEL;
wire PORT0_ER_SEL = (addr == PORT0_ER_ADDR);
wire PORT0_ER_WR = wr & PORT0_ER_SEL;

wire PORT1_RX_SEL = (addr == PORT1_RX_ADDR);
wire PORT1_RX_WR = wr & PORT1_RX_SEL;
wire PORT1_TX_SEL = (addr == PORT1_TX_ADDR);
wire PORT1_TX_WR = wr & PORT1_TX_SEL;
wire PORT1_ER_SEL = (addr == PORT1_ER_ADDR);
wire PORT1_ER_WR = wr & PORT1_ER_SEL;

wire PORT2_RX_SEL = (addr == PORT2_RX_ADDR);
wire PORT2_RX_WR = wr & PORT2_RX_SEL;
wire PORT2_TX_SEL = (addr == PORT2_TX_ADDR);
wire PORT2_TX_WR = wr & PORT2_TX_SEL;
wire PORT2_ER_SEL = (addr == PORT2_ER_ADDR);
wire PORT2_ER_WR = wr & PORT2_ER_SEL;

wire PORT3_RX_SEL = (addr == PORT3_RX_ADDR);
wire PORT3_RX_WR = wr & PORT3_RX_SEL;
wire PORT3_TX_SEL = (addr == PORT3_TX_ADDR);
wire PORT3_TX_WR = wr & PORT3_TX_SEL;
wire PORT3_ER_SEL = (addr == PORT3_ER_ADDR);
wire PORT3_ER_WR = wr & PORT3_ER_SEL;

wire TABLE_ST0_SEL = (addr == TABLE_ST0_ADDR);
wire TABLE_ST0_WR = wr & TABLE_ST0_SEL;
wire TABLE_ST1_SEL = (addr == TABLE_ST1_ADDR);
wire TABLE_ST1_WR = wr & TABLE_ST1_SEL;
wire TABLE_ST2_SEL = (addr == TABLE_ST2_ADDR);
wire TABLE_ST2_WR = wr & TABLE_ST2_SEL;
wire TABLE_ST3_SEL = (addr == TABLE_ST3_ADDR);
wire TABLE_ST3_WR = wr & TABLE_ST3_SEL;
wire TABLE_ST4_SEL = (addr == TABLE_ST4_ADDR);
wire TABLE_ST4_WR = wr & TABLE_ST4_SEL;
wire TABLE_ST5_SEL = (addr == TABLE_ST5_ADDR);
wire TABLE_ST5_WR = wr & TABLE_ST5_SEL;
wire TABLE_ST6_SEL = (addr == TABLE_ST6_ADDR);
wire TABLE_ST6_WR = wr & TABLE_ST6_SEL;
wire TABLE_ST7_SEL = (addr == TABLE_ST7_ADDR);
wire TABLE_ST7_WR = wr & TABLE_ST7_SEL;

wire    [DEFAULT_REGISTER_WIDTH-1:0]  SPI_POINTER_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  TABLE_MODER_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  TABLE_CTRL_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  TABLE_HASH_OUT;

wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT0_RX_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT0_TX_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT0_ER_OUT;

wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT1_RX_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT1_TX_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT1_ER_OUT;

wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT2_RX_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT2_TX_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT2_ER_OUT;

wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT3_RX_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT3_TX_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  PORT3_ER_OUT;

wire    [DEFAULT_REGISTER_WIDTH-1:0]  TABLE_ST0_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  TABLE_ST1_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  TABLE_ST2_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  TABLE_ST3_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  TABLE_ST4_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  TABLE_ST5_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  TABLE_ST6_OUT;
wire    [DEFAULT_REGISTER_WIDTH-1:0]  TABLE_ST7_OUT;

wire    [6:0]   SPI_ADDR = SPI_POINTER_OUT[6:0];
assign            r_hash_update = TABLE_CTRL_OUT[0];
assign            r_hash_clear = TABLE_CTRL_OUT[1];

assign            r_flow_mux = {TABLE_ST0_OUT,TABLE_ST1_OUT,TABLE_ST2_OUT,TABLE_ST3_OUT,TABLE_ST4_OUT,TABLE_ST5_OUT,TABLE_ST6_OUT,TABLE_ST7_OUT};
assign            r_hash = TABLE_HASH_OUT[9:0];
//Registers
register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
SPI_POINTER
(
.clk            (clk),
.reset          (rst),
.wr             (SPI_POINTER_WR),
.din            (din),
.dout           (SPI_POINTER_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
TABLE_MODER
(
.clk            (clk),
.reset          (rst),
.wr             (TABLE_MODER_WR),
.din            (din),
.dout           (TABLE_MODER_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
TABLE_CTRL
(
.clk            (clk),
.reset          (rst),
.wr             (TABLE_CTRL_WR),
.din            (din),
.dout           (TABLE_CTRL_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
TABLE_HASH
(
.clk            (clk),
.reset          (rst),
.wr             (TABLE_HASH_WR),
.din            (din),
.dout           (TABLE_HASH_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT0_RX
(
.clk            (clk),
.reset          (rst),
.wr             (PORT0_RX_WR),
.din            (din),
.dout           (PORT0_RX_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT0_TX
(
.clk            (clk),
.reset          (rst),
.wr             (PORT0_TX_WR),
.din            (din),
.dout           (PORT0_TX_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT0_ER
(
.clk            (clk),
.reset          (rst),
.wr             (PORT0_ER_WR),
.din            (din),
.dout           (PORT0_ER_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT1_RX
(
.clk            (clk),
.reset          (rst),
.wr             (PORT1_RX_WR),
.din            (din),
.dout           (PORT1_RX_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT1_TX
(
.clk            (clk),
.reset          (rst),
.wr             (PORT1_TX_WR),
.din            (din),
.dout           (PORT1_TX_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT1_ER
(
.clk            (clk),
.reset          (rst),
.wr             (PORT1_ER_WR),
.din            (din),
.dout           (PORT1_ER_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT2_RX
(
.clk            (clk),
.reset          (rst),
.wr             (PORT2_RX_WR),
.din            (din),
.dout           (PORT2_RX_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT2_TX
(
.clk            (clk),
.reset          (rst),
.wr             (PORT2_TX_WR),
.din            (din),
.dout           (PORT2_TX_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT2_ER
(
.clk            (clk),
.reset          (rst),
.wr             (PORT2_ER_WR),
.din            (din),
.dout           (PORT2_ER_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT3_RX
(
.clk            (clk),
.reset          (rst),
.wr             (PORT3_RX_WR),
.din            (din),
.dout           (PORT3_RX_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT3_TX
(
.clk            (clk),
.reset          (rst),
.wr             (PORT3_TX_WR),
.din            (din),
.dout           (PORT3_TX_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
PORT3_ER
(
.clk            (clk),
.reset          (rst),
.wr             (PORT3_ER_WR),
.din            (din),
.dout           (PORT3_ER_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
TABLE_ST0
(
.clk            (clk),
.reset          (rst),
.wr             (TABLE_ST0_WR),
.din            (din),
.dout           (TABLE_ST0_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
TABLE_ST1
(
.clk            (clk),
.reset          (rst),
.wr             (TABLE_ST1_WR),
.din            (din),
.dout           (TABLE_ST1_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
TABLE_ST2
(
.clk            (clk),
.reset          (rst),
.wr             (TABLE_ST2_WR),
.din            (din),
.dout           (TABLE_ST2_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
TABLE_ST3
(
.clk            (clk),
.reset          (rst),
.wr             (TABLE_ST3_WR),
.din            (din),
.dout           (TABLE_ST3_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
TABLE_ST4
(
.clk            (clk),
.reset          (rst),
.wr             (TABLE_ST4_WR),
.din            (din),
.dout           (TABLE_ST4_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
TABLE_ST5
(
.clk            (clk),
.reset          (rst),
.wr             (TABLE_ST5_WR),
.din            (din),
.dout           (TABLE_ST5_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
TABLE_ST6
(
.clk            (clk),
.reset          (rst),
.wr             (TABLE_ST6_WR),
.din            (din),
.dout           (TABLE_ST6_OUT)
);

register    #(
.WIDTH          (DEFAULT_REGISTER_WIDTH),
.RESET_VALUE    (DEFAULT_REGISTER_RESET_VALUE)
)
TABLE_ST7
(
.clk            (clk),
.reset          (rst),
.wr             (TABLE_ST7_WR),
.din            (din),
.dout           (TABLE_ST7_OUT)
);

always@(*)begin
    if(~rst)begin
        dout <= 16'h0;
    end
    else begin
        case(addr_r)
        SPI_POINTER_ADDR :      dout<=SPI_POINTER_OUT;
        TABLE_MODER_ADDR :      dout<=TABLE_MODER_OUT;
        TABLE_CTRL_ADDR :       dout<=TABLE_CTRL_OUT;
        TABLE_HASH_ADDR :       dout<=TABLE_HASH_OUT;
        PORT0_RX_ADDR :         dout<=PORT0_RX_OUT;
        PORT0_TX_ADDR :         dout<=PORT0_TX_OUT;
        PORT0_ER_ADDR :         dout<=PORT0_ER_OUT;
        PORT1_RX_ADDR :         dout<=PORT1_RX_OUT;
        PORT1_TX_ADDR :         dout<=PORT1_TX_OUT;
        PORT1_ER_ADDR :         dout<=PORT1_ER_OUT;
        PORT2_RX_ADDR :         dout<=PORT2_RX_OUT;
        PORT2_TX_ADDR :         dout<=PORT2_TX_OUT;
        PORT2_ER_ADDR :         dout<=PORT2_ER_OUT;
        PORT3_RX_ADDR :         dout<=PORT3_RX_OUT;
        PORT3_TX_ADDR :         dout<=PORT3_TX_OUT;
        PORT3_ER_ADDR :         dout<=PORT3_ER_OUT;
        TABLE_ST0_ADDR :        dout<=TABLE_ST0_OUT;
        TABLE_ST1_ADDR :        dout<=TABLE_ST1_OUT;
        TABLE_ST2_ADDR :        dout<=TABLE_ST2_OUT;
        TABLE_ST3_ADDR :        dout<=TABLE_ST3_OUT;
        TABLE_ST4_ADDR :        dout<=TABLE_ST4_OUT;
        TABLE_ST5_ADDR :        dout<=TABLE_ST5_OUT;
        TABLE_ST6_ADDR :        dout<=TABLE_ST6_OUT;
        TABLE_ST7_ADDR :        dout<=TABLE_ST7_OUT;
        default:                dout<=16'h0;
    endcase
    end
end

always@(*)begin
    if(~rst)begin
        spi_dout <= 16'h0;
    end
    else begin
        case(SPI_ADDR)
            SPI_POINTER_ADDR :      spi_dout<=SPI_POINTER_OUT;
            TABLE_MODER_ADDR :      spi_dout<=TABLE_MODER_OUT;
            TABLE_CTRL_ADDR :       spi_dout<=TABLE_CTRL_OUT;
            TABLE_HASH_ADDR :       spi_dout<=TABLE_HASH_OUT;
            PORT0_RX_ADDR :         spi_dout<=PORT0_RX_OUT;
            PORT0_TX_ADDR :         spi_dout<=PORT0_TX_OUT;
            PORT0_ER_ADDR :         spi_dout<=PORT0_ER_OUT;
            PORT1_RX_ADDR :         spi_dout<=PORT1_RX_OUT;
            PORT1_TX_ADDR :         spi_dout<=PORT1_TX_OUT;
            PORT1_ER_ADDR :         spi_dout<=PORT1_ER_OUT;
            PORT2_RX_ADDR :         spi_dout<=PORT2_RX_OUT;
            PORT2_TX_ADDR :         spi_dout<=PORT2_TX_OUT;
            PORT2_ER_ADDR :         spi_dout<=PORT2_ER_OUT;
            PORT3_RX_ADDR :         spi_dout<=PORT3_RX_OUT;
            PORT3_TX_ADDR :         spi_dout<=PORT3_TX_OUT;
            PORT3_ER_ADDR :         spi_dout<=PORT3_ER_OUT;
            TABLE_ST0_ADDR :        spi_dout<=TABLE_ST0_OUT;
            TABLE_ST1_ADDR :        spi_dout<=TABLE_ST1_OUT;
            TABLE_ST2_ADDR :        spi_dout<=TABLE_ST2_OUT;
            TABLE_ST3_ADDR :        spi_dout<=TABLE_ST3_OUT;
            TABLE_ST4_ADDR :        spi_dout<=TABLE_ST4_OUT;
            TABLE_ST5_ADDR :        spi_dout<=TABLE_ST5_OUT;
            TABLE_ST6_ADDR :        spi_dout<=TABLE_ST6_OUT;
            TABLE_ST7_ADDR :        spi_dout<=TABLE_ST7_OUT;
            default:                spi_dout<=16'h0;
        endcase
    end
end

endmodule
