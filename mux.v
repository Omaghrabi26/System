module muxm (
input wire [1:0] select,
input parity_bit,
input data,
//input CLK,RST,
output reg tx_out
);
//reg out;

parameter Start_bit_OUT=2'b00, Data_bit_OUT=2'b01,Parity_bit_OUT=2'b10,Stop_bit_OUT=2'b11;
parameter      start_bit=1'B0,     stop_bit=1'B1;
always @ (*)
 begin
  case (select)
    Start_bit_OUT:
      tx_out=start_bit;                    //0
    
     Data_bit_OUT:
      tx_out=data;                    // data

     Parity_bit_OUT:
      tx_out=parity_bit;                     // parity

     Stop_bit_OUT:             
      tx_out=stop_bit;                    // 1
   endcase
  end

/*  
always @(posedge CLK or negedge RST) 
begin
  if (!RST) 
  begin
    tx_out<=1'b1;
    end
  else 
  begin
    tx_out<=out; 
  end
end
*/
 
endmodule
