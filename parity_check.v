module parity_check
#(parameter data_width = 8)
 (
  input  [data_width-1:0]	P_DATA,
  input                     CLK,RST,
  input                     PAR_TYP,
  input                     par_chk_en,
  input                     sampled_bit,
  output  reg               par_err 
  );


//reg   PARITY_CHECK;
reg par_bit;

always@(*)
 
begin
 // PARITY_CHECK = ^P_DATA; 
	if (!PAR_TYP)                 // even ones==>zero  , // odd ones==>one
	  begin
	   par_bit <= ^P_DATA;         
      end
	
	else if (PAR_TYP)             
	  begin
       par_bit <= ~(^P_DATA);
      end
end

always @(posedge CLK or negedge RST) 
begin
	if (!RST) 
	 begin
	 par_err<=0;	
	 end
	else if (par_chk_en)
	 begin
	  if (sampled_bit == par_bit) 
	  par_err<=0;
	  else
	  par_err<=1;
	 end	
	
end


endmodule
