module parity (
input wire data_valid, clk, rst, busy,
input wire [7:0] P_data,
input wire P_type,
output reg P_bit
);

always @ (posedge clk , negedge rst)
 begin
     if (!rst)
   begin
     P_bit <= 0;
   end

     else if(data_valid && !busy)
      begin 
       if(P_type)
        begin
         if(!(^P_data))
             P_bit <= 1 ;
         else
             P_bit <= 0 ;
        end
        
       else
        begin
         if(!(^P_data))
             P_bit <= 0 ;
         else
             P_bit <= 1 ;
        end
      end 
 end
   
endmodule
