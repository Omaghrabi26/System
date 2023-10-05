module deserializer 
#(parameter data_width = 8)
 ( 
  input                     CLK,RST,
  input                     sampled_bit,
  input                     deser_en,
  input       [3:0]         bit_cnt,
  output reg  [data_width-1:0]	P_DATA
  
);

always @(posedge CLK or negedge RST) 
begin
    if (!RST) 
        P_DATA <= 'b0;
    else if (deser_en)
        P_DATA [bit_cnt-1] <=sampled_bit ;           //{sampled_bit, P_DATA[7:1]};
end


endmodule
