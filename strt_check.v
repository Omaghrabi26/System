module strt_check 
( 
  
  input                     CLK,RST,
  input                     strt_chk_en,
  input                     sampled_bit,
  output  reg               strt_glitch 
  );
 always @(posedge CLK or negedge RST) begin
     if (!RST)
       begin
       strt_glitch<=0;
       end
     else if (strt_chk_en)
       begin
         strt_glitch <= sampled_bit ^ 1'b0;                    // 1^0=0      1^1=1,
       end
   end 

endmodule


