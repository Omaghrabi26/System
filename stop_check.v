module stop_check 
( 
  
  input                     CLK,RST,
  input                     stp_chk_en,
  input                     sampled_bit,
  output  reg               stp_err
  );


  always @(posedge CLK or negedge RST) begin
     if (!RST)
       begin
       stp_err<=0;
       end
     else if (stp_chk_en)
       begin
         stp_err <= sampled_bit ^ 1'b1;                    // 1^1=0      0^1=1,
       end
   end 


   
endmodule
