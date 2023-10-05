module serializer (
  input wire [7:0] P_data,
  input wire clk,
  input wire rst,
  input wire ser_en,
  input wire busy,
  output reg ser_dn,
  output reg S_data
  );
  
reg [7:0] int;  
reg [3:0] count;
reg count_max;
  

always @ (*)
 begin
   if (count == 8)
    count_max = 1;
   else
    count_max = 0;
  end

  
always @ (posedge clk , negedge rst)
 begin 
   
  if (!rst)
   begin
     S_data <= 0;
     ser_dn <= 0;
     count <= 0;
     int <= 0;
   end
   
  else if (ser_en && (!count_max) && busy)
   begin
    {int[6:0],S_data} <= int ;
    count <= count + 1 ;
    if (count == 7)
    ser_dn <= 1;
   end

 else if (!busy)
    int <= P_data;
      
  else
   begin
    count <= 0;
    ser_dn <= 0; 
   end
 end
   
endmodule   
