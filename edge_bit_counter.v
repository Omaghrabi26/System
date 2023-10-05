module edge_bit_counter 

//#(parameter prescale_v = 16)

( input            enable,
  input            RST, CLK,
  input            PAR_EN,
  input      [5:0] Prescale,
 
  output reg [5:0] edge_cnt,
  output reg [3:0] bit_cnt
  
);
reg [3:0] bit_cnt_end;


always@(PAR_EN)
begin
 if(PAR_EN)
 begin
 bit_cnt_end=4'd11;
 end
 else
 begin
 bit_cnt_end=4'd10;
 end
end

always @(posedge CLK or negedge RST)
 begin
	if (!RST) 
	 begin
		edge_cnt<=4'b0;
		bit_cnt<=4'b0;
	 end
	
	else if (enable) 
	 begin

	  if(edge_cnt==(Prescale-5'b1))	
	   begin
	    edge_cnt<=4'b0;

	    if (bit_cnt<bit_cnt_end-1) 
	     	 bit_cnt<=bit_cnt+4'b1;
	   
	    else 
	       bit_cnt<=4'b0;
     end
	   

    else 
     begin
      edge_cnt<=edge_cnt+4'b1;	
     end
     
    end
    
  else 
	 begin
		edge_cnt<=6'b0;
		end
	
end



endmodule