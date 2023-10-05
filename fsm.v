module fsm
//#(parameter data_width = 8)

(

 input		         DATA_VALID,
 input		         PAR_EN,
 input        	  ser_done,
 input        	  CLK,RST,
 output reg       ser_en,
 output reg [1:0] mux_sel,
 output reg       Busy        
);

localparam [2:0] 		IDLE   = 3'b000,
				        Start  = 3'b001,
				        Data   = 3'b010,
				        Parity = 3'b011,
				        Stop   = 3'b100;


reg        [2:0]       c_state,
                       n_state ;

//mux_sel values:
parameter Start_bit_OUT=2'b00, Data_bit_OUT=2'b01,Parity_bit_OUT=2'b10,Stop_bit_OUT=2'b11;

always @(posedge CLK) 
begin
	if (!RST) 
	begin
	  c_state<=IDLE;
    end
	else 
	begin
	  c_state<=n_state;	
	end
end


always @(*)
begin

 
 case(c_state)
  
   IDLE:begin
     Busy=1'b0;
          ser_en=1'b0;
    mux_sel=Stop_bit_OUT;
         if (DATA_VALID)
          n_state=Start;
         else 
          n_state=IDLE;  
        end

   Start:begin
          //output
          Busy=1'b1;
          ser_en=1'b1;
          mux_sel=Start_bit_OUT;
          
          //state
          n_state=Data;
         end
   

   Data:begin
         Busy=1'b1;
         ser_en=1'b1;
         mux_sel=Data_bit_OUT;

   		 if (ser_done)
   		 begin
          mux_sel = Data_bit_OUT;
          if (PAR_EN)
           n_state=Parity;
          else
           n_state=Stop;
         end
         else
           n_state=Data; 
        end

   Parity:begin
   		   Busy=1'b1;
           ser_en=1'b0;
   		   mux_sel=Parity_bit_OUT;

   		   n_state=Stop;
   		  end

   Stop: begin
          Busy=1'b1;
          ser_en=1'b0;
          mux_sel=Stop_bit_OUT;
         // if (DATA_VALID)
          //	n_state=Start;
          //else
          n_state=IDLE;
         end
   default:begin
            n_state=IDLE;
            mux_sel=Start_bit_OUT;
            ser_en=1'b0;
            Busy=1'b0;
           end
  
  endcase 
end

endmodule
