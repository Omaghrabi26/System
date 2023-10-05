module PULSE_GEN (
  input CLK,
  input RST,
  input sig,
  output reg pulse
  );
  
  reg Q;
  
  always @ (posedge CLK , negedge RST)
   begin
     if (!RST)
       pulse <= 0;
     else
      begin
        Q <= sig;
        pulse <= sig & !Q;
      end
    end
    
  endmodule
