`timescale 1ns / 1ps
module frame_process(
input                	clk,
input                   rstn,
output  reg             sfifo_rd,
input        [7:0]      sfifo_dout,
output  reg             ptr_sfifo_rd,
input        [15:0]     ptr_sfifo_dout,
input                   ptr_sfifo_empty,

output  reg  [47:0]     se_mac,
output  reg  [15:0]     source_portmap,
output  reg  [9:0]      se_hash,
output  reg             se_source,
output  reg             se_req,
input                   se_ack,
input                   se_nak,
input        [15:0]     se_result,
input        [3:0]      link,                    

input                   bp0,
input                   bp1,
input                   bp2,
input                   bp3,
output  reg             sof,
output  reg             dv,
output  reg  [7:0]      data    
);
reg     [47:0]     source_mac;
reg     [47:0]     desti_mac;
reg     [15:0]     length_type; 
reg     [5:0]      state;
reg     [10:0]     cnt;
reg     [3:0]      egress_portmap;
reg     [11:0]     length;
reg     [5:0]      pad_cnt;
reg				   broadcast;
always@(posedge clk or negedge rstn)begin
    if(!rstn)begin
        sfifo_rd<=#2 0;
        ptr_sfifo_rd<=#2 0;
        se_mac<=#2 0;
        se_hash<=#2 0;
        se_req<=#2 0;
        source_portmap<=#2 0;
        sof<=#2 0;
        dv<=#2 0;
        data<=#2 0;
        state<=#2 0;
        cnt<=#2 0;
		se_source<=#2 0;
		broadcast<=#2 0;
        end
    else  begin
        case(state)
        0:begin
            dv<=#2 0;
            if(!ptr_sfifo_empty)begin
                ptr_sfifo_rd<=#2 1;   	
                state<=#2 1;         	
                end
            end
        1:begin
            ptr_sfifo_rd<=#2 0;
            sfifo_rd<=#2 1;	
            state<=#2 2;
            end
        2:begin
            cnt<=#2 ptr_sfifo_dout[10:0];						
            length<=#2 {1'b0,ptr_sfifo_dout[10:0]};				
            source_portmap<=#2 {12'b0,ptr_sfifo_dout[14:11]};	
            state<=#2 3;
            end
        3:begin
			length<=#2 length+2;	
			desti_mac[47:40]<=#2 sfifo_dout[7:0];
            state<=#2 4;
            end
        4:begin
			pad_cnt<=#2 ~length[5:0];	
			desti_mac[39:32]<=#2 sfifo_dout[7:0];
            state<=#2 5;
            end
        5:begin
            desti_mac[31:24]<=#2 sfifo_dout[7:0];
            state<=#2 6;
            end
        6:begin
            desti_mac[23:16]<=#2 sfifo_dout[7:0];
            state<=#2 7;
            end
        7:begin
            desti_mac[15:8]<=#2 sfifo_dout[7:0];
            state<=#2 8;
            end
        8:begin
            desti_mac[7:0]<=#2 sfifo_dout[7:0];
            state<=#2 9;
            end
        9:begin
            source_mac[47:40]<=#2 sfifo_dout[7:0];
            state<=#2 10;
            end
        10:begin
            source_mac[39:32]<=#2 sfifo_dout[7:0];
            state<=#2 11;
            end
        11:begin
            source_mac[31:24]<=#2 sfifo_dout[7:0];
            state<=#2 12;
            end
        12:begin
            source_mac[23:16]<=#2 sfifo_dout[7:0];
            state<=#2 13;
            end
        13:begin
            source_mac[15:8]<=#2 sfifo_dout[7:0];
            state<=#2 14;
            end
        14:begin
            source_mac[7:0]<=#2 sfifo_dout[7:0];
            state<=#2 15;
            end
        15:begin
            length_type[15:8]<=#2 sfifo_dout[7:0];
            sfifo_rd<=#2 0;
            state<=#2 16;
            end
        16:begin
            length_type[7:0]<=#2 sfifo_dout[7:0];
            cnt<=#2 cnt-14;
			if(desti_mac==48'hff_ff_ff_ff_ff_ff) broadcast<=#2 1;
			else broadcast<=#2 0;
            state<=#2 19;
            end
        19:begin
            se_source<=#2 1;
            se_mac<=#2 source_mac;
            se_hash<=#2 source_mac[9:0];
            se_req<=#2 1;
            state<=#2 20;
            end
        20:begin
            if(se_ack|se_nak)begin
                se_source<=#2 0;
                se_hash<=#2 desti_mac[9:0];
                se_mac<=#2 desti_mac;
                state<=#2 21;
                end
            end
        21:begin
            if(se_ack)begin
                se_req<=#2 0;
                state<=#2 22;
                egress_portmap<=#2 se_result[3:0]&link;
                end
            if(se_nak | broadcast)begin
                se_req<=#2 0;
                state<=#2 22;
                egress_portmap<=#2 ((source_portmap==15'd1)?4'b1110:
                                (source_portmap==15'd2)?4'b1101:
                                (source_portmap==15'd4)?4'b1011:4'b0111)&link;
                end
            end
        22:begin
            data<=#2 {length[11:8],egress_portmap[3:0]};  
            dv<=#2 1;
            sof<=#2 1;  
            state<=#2 23;
            end
        23:begin
            data<=#2 length[7:0];
            state<=#2 24;
            sof<=#2 0;
            end
        24:begin
            data<=#2 desti_mac[47:40];
            state<=#2 25;
            end
        25:begin
            data<=#2 desti_mac[39:32];
            state<=#2 26;
            end
        26:begin
            data<=#2 desti_mac[31:24];
            state<=#2 27;
            end
        27:begin
            data<=#2 desti_mac[23:16];
            state<=#2 28;
            end
        28:begin
            data<=#2 desti_mac[15:8];
            state<=#2 29; 
            end
        29:begin
            data<=#2 desti_mac[7:0];
            state<=#2 30;
            end
        30:begin
            data<=#2 source_mac[47:40];
            state<=#2 31;
            end
        31:begin
            data<=#2 source_mac[39:32];
            state<=#2 32;
            end 
        32:begin
            data<=#2 source_mac[31:24];
            state<=#2 33;
            end
        33:begin
            data<=#2 source_mac[23:16];
            state<=#2 34;
            end
        34:begin
            data<=#2 source_mac[15:8];
            state<=#2 35;
            end
        35:begin
            data<=#2 source_mac[7:0];
            state<=#2 36;
            end
        36:begin
            data<=#2 length_type[15:8];
            state<=#2 37;
            sfifo_rd<=#2 1;
            end
        37:begin
            data<=#2 length_type[7:0];
            cnt<=#2 cnt-1;
            state<=#2 38;
            end
        38:begin
            data<=#2 sfifo_dout;
            if(cnt>1) cnt<=#2 cnt-1;
            else begin
                cnt<=#2 0;
                sfifo_rd<=#2 0;
                state<=#2 39;
                end
            end
        39: begin
            data<=#2 sfifo_dout;
			state<=#2 40;
			end
		40:begin
            data<=#2 0;
            if(pad_cnt==6'd63)begin
				dv<=#2 0;
				state<=#2 0;
				end
			else begin
                data<=#2 0;
				state<=#2 41;
                end
            end
		41:begin
			if(pad_cnt>0) begin
				data<=#2 data+1;
				pad_cnt<=#2 pad_cnt-1;
				end
			else begin
				dv<=#2 0;
				state<=#2 0;
				end
			end
        endcase
        end
    end

endmodule
