module data_sampling 
//#(parameter prescale = 16)
(   input       CLK,RST,
	input       RX_IN,
    input [5:0] Prescale,
	input [5:0] edge_cnt,
	input       data_samp_en,
	output reg  sampled_bit
	);
wire [3:0] half_freq;
assign half_freq = Prescale>>1;

//reg sampled_bit_1;
//reg sampled_bit_2;
//reg sampled_bit_3;
reg  [2:0] Sampled_Bits;                  //sample 1--->bit0       sample 2--->bit1    sample 3--->bit2
 
always @(posedge CLK or negedge RST)
 begin
	if (!RST)
	 begin
	  Sampled_Bits<=0;
	 end
	else if (data_samp_en) 
	 begin
		if (edge_cnt== (half_freq-1))                                       // (half_freq-1)
		Sampled_Bits[0]<=RX_IN;
		else if (edge_cnt== (half_freq))
		Sampled_Bits[1]<=RX_IN;
		else if (edge_cnt== (half_freq+1))
		Sampled_Bits[2]<=RX_IN;	
	 end
	else
		Sampled_Bits<=0;
end


/*always @(posedge CLK or posedge RST)
 begin
	if (RST)
	 begin
	  sampled_bit<=0;
	 end
	else if (data_samp_en) 
	 if ((Sampled_Bits=3'b000)||(Sampled_Bits=3'b001)||(Sampled_Bits=3'b010)||(Sampled_Bits=3'b100)
	 begin
	 sampled_bit=0;
	 end
	 else
	 sampled_bit=1;

	 */

always @(posedge CLK or negedge RST)
 begin
	if (!RST)
	 begin
	  sampled_bit<=0;
	 end
	else if (data_samp_en) 
	begin
	 case(Sampled_Bits)
	  3'b000:sampled_bit<=0;
	  3'b001:sampled_bit<=0;
	  3'b010:sampled_bit<=0;
	  3'b011:sampled_bit<=1;
	  3'b100:sampled_bit<=0;
	  3'b101:sampled_bit<=1;
	  3'b110:sampled_bit<=1;
	  3'b111:sampled_bit<=1;
	 endcase
	 end
	else
	 sampled_bit<=0;	

end

endmodule 
