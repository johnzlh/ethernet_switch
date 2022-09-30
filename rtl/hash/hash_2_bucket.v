`timescale 1ns / 1ps
//====================================================================
//entry structure:
//[15:0]:portmap
//[63:16]:mac
//[73:64]:age counter
//[79]:item valid
//=====================================================================
module hash_2_bucket(
input               clk,
input               rstn,
//port se signals.
input               se_source,
input       [47:0]  se_mac,
input       [15:0]  se_portmap,
input       [9:0]   se_hash,        
input               se_req,
output  reg         se_ack,
output  reg         se_nak,
output  reg [15:0]  se_result,
input               aging_req,  
output  reg         aging_ack   
);
parameter   LIVE_TH=10'd150;

//======================================
//              main state.
//======================================
reg     [3:0]   state;
reg             clear_op;
reg             hit0;
reg             hit1;
//======================================
//              one cycle for state1.
//======================================
reg             count;

wire            item_valid0;
wire            item_valid1;
wire    [9:0]   live_time0;
wire    [9:0]   live_time1;
wire            not_outlive_0;
wire            not_outlive_1;
reg             ram_wr_0;
reg     [9:0]   ram_addr_0;     //input [11 : 0] addra
reg     [79:0]  ram_din_0;      //input [95 : 0] dina
wire    [79:0]  ram_dout_0;     //output [95 : 0] douta
reg     [79:0]  ram_dout_0_reg; //output [95 : 0] douta
reg             ram_wr_1;
reg     [9:0]   ram_addr_1;     //input [11 : 0] addra
reg     [79:0]  ram_din_1;      //input [95 : 0] dina
wire    [79:0]  ram_dout_1;     //output [95 : 0] douta
reg     [79:0]  ram_dout_1_reg; //output [95 : 0] douta
reg     [9:0]   aging_addr;
reg     [47:0]  hit_mac;
always @(posedge clk or negedge rstn)
    if(!rstn)begin
        state<=#2 0;
		clear_op<=#2 1;
        ram_wr_0<=#2 0;
        ram_addr_0<=#2 0; 
        ram_din_0<=#2 0;    
        ram_wr_1<=#2 0;
        ram_addr_1<=#2 0; 
        ram_din_1<=#2 0;    
        se_ack<=#2 0;
        se_nak<=#2 0;
        se_result<=#2 0;
        aging_ack<=#2 0;
        aging_addr<=#2 0;
        hit_mac<=#2 0;
        count<=#2 0;
        end
    else begin
        ram_dout_0_reg<=#2 ram_dout_0;  
        ram_dout_1_reg<=#2 ram_dout_1;  
        ram_wr_0<=#2 0;
        ram_wr_1<=#2 0;
        se_ack<=#2 0;
        se_nak<=#2 0;
        aging_ack<=#2 0;
        case(state)
        0:begin
            if(clear_op) begin
                ram_addr_0<=#2 0;
                ram_addr_1<=#2 0;
                ram_wr_0<=#2 1;
                ram_wr_1<=#2 1;
                ram_din_0<=#2 0;
                ram_din_1<=#2 0;
                state<=#2 15;
                end
            else if(se_req) begin
                ram_addr_0<=#2 se_hash;
                ram_addr_1<=#2 se_hash;
                hit_mac   <=#2 se_mac;
                count     <=#2 0;
                state   <=#2 1;
                end
            else if(aging_req) begin
                if(aging_addr<10'h3ff) aging_addr<=#2 aging_addr+1;
                else begin
                    aging_addr<=#2 0;
                    aging_ack<=#2 1;
                    end
                ram_addr_0<=#2 aging_addr;
                ram_addr_1<=#2 aging_addr;
                state<=#2 8;
                end
            end
        //===============================================
        //check if there is an entry can match current 
        //source mac address. 
        //(1)if macthed, refresh live time.
        //(2)if not macthed, add new entry.
        //===============================================
        1:begin
            count <=#2 1;
            if(count) state<=#2 2;
            end
        2:begin
            if(se_source) state<=#2 3;
            else state<=#2 6;
            end
        3:begin
            //=====================================================
            //if no entry is matched(still valid), should add new 
            //entry.
            //=====================================================
            if({hit1,hit0}==2'b00) state<=#2 4;
            //=====================================================
            //if an entry is existed and old entry should be refreshed.
            //=====================================================
            else state<=#2 5;
            end
        4:begin
            state<=#2 14;
            case({item_valid1,item_valid0})
            2'b11: se_nak<=#2 1;
            2'b00,2'b10: begin
                se_nak<=#2 0;
                se_ack<=#2 1;
                ram_din_0<=#2 { 1'b1,5'b0,
                                LIVE_TH,
                                se_mac[47:0],
                                se_portmap[15:0]};
                ram_wr_0<=#2 1;
                end
            2'b01:begin
                se_nak<=#2 0;
                se_ack<=#2 1;
                ram_din_1<=#2 { 1'b1,5'b0,
                                LIVE_TH,
                                se_mac[47:0],
                                se_portmap[15:0]};
                ram_wr_1<=#2 1;
                end
            endcase
            end
        5:begin
            state<=#2 14;
            case({hit1,hit0})
            2'b01: begin
                se_nak<=#2 0;
                se_ack<=#2 1;
                ram_din_0<=#2 { 1'b1,5'b0,
                                LIVE_TH,
                                se_mac[47:0],
                                se_portmap[15:0]};
                ram_wr_0<=#2 1;
                end
            2'b10:begin
                se_nak<=#2 0;
                se_ack<=#2 1;
                ram_din_1<=#2 { 1'b1,5'b0,
                                LIVE_TH,
                                se_mac[47:0],
                                se_portmap[15:0]};
                ram_wr_1<=#2 1;
                end
            endcase
            end
        6:begin
            state<=#2 14;
            case({hit1,hit0})
            2'b00: begin
                se_ack<=#2 0;
                se_nak<=#2 1;
                end
            2'b01: begin
                se_nak<=#2 0;
                se_ack<=#2 1;
                se_result<=#2 ram_dout_0_reg[15:0];
                end
            2'b10:begin
                se_nak<=#2 0;
                se_ack<=#2 1;
                se_result<=#2 ram_dout_1_reg[15:0];             
                end
        //=============================
        //code for 2'b11
        //=============================
            2'b11:begin
                se_nak<=#2 0;
                se_ack<=#2 1;
                se_result<=#2 ram_dout_0_reg[15:0];             
                end
            endcase
            end
        //=============================
        //normal aging op.
        //=============================
        8:state<=#2 9;
        9:state<=#2 10;
        10:begin
            state<=#2 14;
            if(not_outlive_0)begin
                ram_din_0[79]<=#2 1'b1;
                ram_din_0[78:74]<=#2 5'b0;
                ram_din_0[73:64]<=#2 live_time0-10'd1;
                ram_din_0[63:0]<=#2  ram_dout_0_reg[63:0];
                ram_wr_0<=#2 1;
                end
            else begin
                ram_din_0[79:0]<=#2 80'b0;
                ram_wr_0<=#2 1;
                end
            if(not_outlive_1)begin
                ram_din_1[79]<=#2 1'b1;
                ram_din_1[78:74]<=#2 5'b0;
                ram_din_1[73:64]<=#2 live_time1-10'd1;
                ram_din_1[63:0]<=#2  ram_dout_1_reg[63:0];
                ram_wr_1<=#2 1;
                end
            else begin
                ram_din_1[79:0]<=#2 80'b0;
                ram_wr_1<=#2 1;
                end
            end 
        14:begin
            state<=#2 0;
            end
        15:begin
            if(ram_addr_0<10'h3ff) begin
				ram_addr_0<=#2 ram_addr_0+1;
                ram_wr_0<=#2 1;
				end
            else ram_addr_0<=#2 0;
            if(ram_addr_1<10'h3ff) begin
				ram_addr_1<=#2 ram_addr_1+1;
                ram_wr_1<=#2 1;
				end
            else begin
                ram_addr_1<=#2 0;
                ram_wr_0<=#2 0;
                ram_wr_1<=#2 0;
                clear_op<=#2 0;
                state<=#2 0;
                end
            end
        endcase
        end

always @(*)begin
    hit0=(hit_mac==ram_dout_0_reg[63:16])& ram_dout_0_reg[79];          
    hit1=(hit_mac==ram_dout_1_reg[63:16])& ram_dout_1_reg[79];          
    end
assign item_valid0=ram_dout_0_reg[79];
assign item_valid1=ram_dout_1_reg[79];
assign live_time0=ram_dout_0_reg[73:64];
assign live_time1=ram_dout_1_reg[73:64];
assign not_outlive_0=(live_time0>0)?1:0;
assign not_outlive_1=(live_time1>0)?1:0;
sram_w80_d1k u_sram_0 (
  .clka(clk),           // input clka
  .wea(ram_wr_0),       // input [0 : 0] wea
  .addra(ram_addr_0),   // input [9 : 0] addra
  .dina(ram_din_0),     // input [79 : 0] dina
  .douta(ram_dout_0)    // output [79 : 0] douta
);
sram_w80_d1k u_sram_1 (
  .clka(clk),           // input clka
  .wea(ram_wr_1),       // input [0 : 0] wea
  .addra(ram_addr_1),   // input [9 : 0] addra
  .dina(ram_din_1),     // input [79 : 0] dina
  .douta(ram_dout_1)    // output [79 : 0] douta
);

endmodule
