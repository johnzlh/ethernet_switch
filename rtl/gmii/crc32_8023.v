module crc32_8023(
input    			clk,
input    			reset,
input	[7:0]		d,
input    			load_init,
input    			calc,
input    			d_valid,
output	reg	[31:0]  crc_reg,
output	reg [7:0]	crc
    );
wire [2:0]   ctl;
wire [31:0]  next_crc;
wire [31:0]  i;
assign  i=crc_reg;
always @(posedge clk or posedge reset)
    if(reset)  crc_reg<=32'hffffffff;
    else begin
        case(ctl) // {load_init, calc, d_valid}
        3'b000,
        3'b010:  begin   crc_reg<=crc_reg; 	crc<=crc;	end
        3'b001:  begin	
            crc_reg<={crc_reg[23:0], 8'hff};	
            crc<=~{crc_reg[16], crc_reg[17], crc_reg[18], crc_reg[19], 
                crc_reg[20], crc_reg[21], crc_reg[22], crc_reg[23]};
            end // [16:23];
        3'b011:  begin	
            crc_reg<=next_crc[31:0];		
            crc<=~{next_crc[24], next_crc[25], next_crc[26], next_crc[27], 
                next_crc[28], next_crc[29], next_crc[30], next_crc[31]};	
            end // [24:31];
        3'b100, 
        3'b110:  begin	
            crc_reg<=32'hffffffff;		
            crc<=crc;				
            end
        3'b101:  begin	
            crc_reg<=32'hffffffff;			
            crc<=~{crc_reg[16], crc_reg[17], crc_reg[18], crc_reg[19], 
                crc_reg[20], crc_reg[21], crc_reg[22], crc_reg[23]};	
            end // [16:23];
        3'b111: begin	
            crc_reg<=32'hffffffff;			
            crc<=~{next_crc[24], next_crc[25], next_crc[26], next_crc[27], 
                next_crc[28], next_crc[29], next_crc[30], next_crc[31]};
            end // [24:31];
        endcase
        end
assign next_crc[0]=d[7]^i[24]^d[1]^i[30];
assign next_crc[1]=d[6]^d[0]^d[7]^d[1]^i[24]^i[25]^i[30]^i[31];
assign next_crc[2]=d[5]^d[6]^d[0]^d[7]^d[1]^i[24]^i[25]^i[26]^i[30]^i[31];
assign next_crc[3]=d[4]^d[5]^d[6]^d[0]^i[25]^i[26]^i[27]^i[31];
assign next_crc[4]=d[3]^d[4]^d[5]^d[7]^d[1]^i[24]^i[26]^i[27]^i[28]^i[30];
assign next_crc[5]=d[0]^d[1]^d[2]^d[3]^d[4]^d[6]^d[7]^i[24]^i[25]^i[27]^i[28]^i[29]
    ^i[30]^i[31];
assign next_crc[6]=d[0]^d[1]^d[2]^d[3]^d[5]^d[6]^i[25]^i[26]^i[28]^i[29]^i[30]^i[31];
assign next_crc[7]=d[0]^d[2]^d[4]^d[5]^d[7]^i[24]^i[26]^i[27]^i[29]^i[31];
assign next_crc[8]=d[3]^d[4]^d[6]^d[7]^i[24]^i[25]^i[27]^i[28]^i[0];
assign next_crc[9]=d[2]^d[3]^d[5]^d[6]^i[1]^i[25]^i[26]^i[28]^i[29];
assign next_crc[10]=d[2]^d[4]^d[5]^d[7]^i[2]^i[24]^i[26]^i[27]^i[29];
assign next_crc[11]=i[3]^d[3]^i[28]^d[4]^i[27]^d[6]^i[25]^d[7]^i[24];
assign next_crc[12]=d[1]^d[2]^d[3]^d[5]^d[6]^d[7]^i[4]^i[24]^i[25]^i[26]^i[28]^i[29]
    ^i[30];
assign next_crc[13]=d[0]^d[1]^d[2]^d[4]^d[5]^d[6]^i[5]^i[25]^i[26]^i[27]^i[29]^i[30]
    ^i[31];
assign next_crc[14]=d[0]^d[1]^d[3]^d[4]^d[5]^i[6]^i[26]^i[27]^i[28]^i[30]^i[31];
assign next_crc[15]=d[0]^d[2]^d[3]^d[4]^i[7]^i[27]^i[28]^i[29]^i[31];
assign next_crc[16]=d[2]^d[3]^d[7]^i[8]^i[24]^i[28]^i[29];
assign next_crc[17]=d[1]^d[2]^d[6]^i[9]^i[25]^i[29]^i[30];
assign next_crc[18]=d[0]^d[1]^d[5]^i[10]^i[26]^i[30]^i[31];
assign next_crc[19]=d[0]^d[4]^i[11]^i[27]^i[31];
assign next_crc[20]=d[3]^i[12]^i[28];
assign next_crc[21]=d[2]^i[13]^i[29];
assign next_crc[22]=d[7]^i[14]^i[24];
assign next_crc[23]=d[1]^d[6]^d[7]^i[15]^i[24]^i[25]^i[30];
assign next_crc[24]=d[0]^d[5]^d[6]^i[16]^i[25]^i[26]^i[31];
assign next_crc[25]=d[4]^d[5]^i[17]^i[26]^i[27];
assign next_crc[26]=d[1]^d[3]^d[4]^d[7]^i[18]^i[28]^i[27]^i[24]^i[30];
assign next_crc[27]=d[0]^d[2]^d[3]^d[6]^i[19]^i[29]^i[28]^i[25]^i[31];
assign next_crc[28]=d[1]^d[2]^d[5]^i[20]^i[30]^i[29]^i[26];
assign next_crc[29]=d[0]^d[1]^d[4]^i[21]^i[31]^i[30]^i[27];
assign next_crc[30]=d[0]^d[3]^i[22]^i[31]^i[28];
assign next_crc[31]=d[2]^i[23]^i[29];
assign ctl={load_init, calc, d_valid};		
endmodule
