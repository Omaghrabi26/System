module FSM_RX
//#(parameter Prescale_v = 16)
( 
	input  wire       RX_IN,
	input  wire       PAR_EN,
	input  wire [5:0] edge_cnt,
	input  wire [3:0] bit_cnt,
	input  wire       stp_err,
	input  wire       strt_glitch,
	input  wire       par_err,
	input  wire       CLK,RST,
	input       [5:0] Prescale,
	output reg        data_samp_en,
	
	output reg        enable,
	
	output reg        par_chk_en,
	output reg        strt_chk_en,
	output reg        stp_chk_en,
 
	output reg        deser_en,
	output reg        data_valid
	);


localparam [2:0] 		IDLE   = 3'b000,
						Start  = 3'b001,
						Data   = 3'b010,
						Parity = 3'b011,
						Stop   = 3'b100,
						error  = 3'b101,  
						DONE   = 3'b110;

reg        [2:0]       c_state,
                       n_state ;
reg data_valid_c;

always @(posedge CLK or negedge RST) 
begin
	if (!RST) 
	begin
	  c_state<=IDLE;
    end
	else 
	begin
	  c_state<=n_state;	
	  data_valid<=data_valid_c;
	end
end



always@(*)
begin

 case(c_state)
   IDLE:
    begin
     if (!RX_IN ) 
      begin
      n_state=Start;	
      end
     else
      begin
      n_state=IDLE;	
      end
    end
   Start:
    begin
    if ( (bit_cnt==0) && (edge_cnt==(Prescale-1)) )  //(Prescale-6'd1)
     begin
       if (strt_glitch) 
        begin
        n_state=IDLE;	
        end
       else              //else if(bit_cnt==1)
        begin
        n_state=Data;	
        end
     end
    else
      n_state=Start;
    end

   Data:
    begin
    
     if ( (bit_cnt==4'd8) && (edge_cnt==(Prescale-1)))                 // if(bit_cnt==9)
      begin
       if(PAR_EN)
        n_state= Parity;
       else
        n_state=Stop;
       end
     else
      n_state = Data;    
    end   
   
   Parity:
    begin
     if ( (bit_cnt==4'd9) && (edge_cnt==(Prescale-1)))  //(Prescale-6'd1)
      n_state=Stop;
     else
      n_state=Parity;
    end
   
   Stop:	
    begin
     if(PAR_EN)
      begin 
       if ((bit_cnt==4'd10 )&& (edge_cnt==(Prescale-1)))
        begin
         if(par_err|stp_err)
          n_state=error; 
          else
          n_state=DONE; 
        end
       else
         n_state=Stop;
     end
     else
      begin
       if ((bit_cnt==4'd9 )&& (edge_cnt==(Prescale-1)))
        begin
        if(par_err|stp_err)
          n_state=error; 
          else
          n_state=DONE; 
        end
       else
         n_state=Stop;
      end  
    end

   error:
     n_state=IDLE;
    DONE:
    begin
     //if(((bit_cnt==4'd10 && (!PAR_EN))||(bit_cnt==4'd11 && (PAR_EN))  && (edge_cnt==4'd15)))           // 
       //begin
       if (!RX_IN) 
       n_state=Start;
       else
       n_state=DONE;
          
     //else 
       //n_state=DONE; 
    end     
    

    default:
     n_state=IDLE;
 endcase
end


always@(*)
begin
 data_samp_en=0;
 enable=0;
 par_chk_en=0;
 strt_chk_en=0;
 stp_chk_en=0;
 deser_en=0;
 data_valid_c=0;
 
  case(c_state)
   IDLE:
    begin
     if (!RX_IN ) 
      begin
       enable=1;
       data_samp_en=0;
       strt_chk_en=1;	
      end
    end
   Start:
    begin
       enable=1;
       data_samp_en=1;
       strt_chk_en=1;
    end
   
   Data:
    begin
       enable=1;
       data_samp_en=1;
       deser_en=1;
    end   
   
   Parity:
    begin
       enable=1;
       data_samp_en=1;
       par_chk_en=1;
    end
   
   Stop:
    begin
       enable=1;
       data_samp_en=1;
       //par_chk_en=1;
       stp_chk_en=1;
     end
   error:
    begin
       enable=0;
       data_samp_en=1;

    end
    DONE:
    begin
     data_valid_c=1;
    data_samp_en=0;
    if(!RX_IN)
    enable=1;
    else
    enable=0;

   
    end


    default:
    begin
    data_samp_en=0;
    enable=0;
    par_chk_en=0;
    strt_chk_en=0;
    stp_chk_en=0;
    deser_en=0;
    data_valid_c=0;	
    end
   
 endcase
end
endmodule  