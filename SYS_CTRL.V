module SYS_CTRL #( parameter DATA_WIDTH = 8,ADDR_width=4)
	(
	  input      [DATA_WIDTH-1:0]  RX_OUT_SYN,
	  input                        RX_VALID_SYN,
	 
	  output reg [DATA_WIDTH-1:0]  FIFO_WR_DATA,
	  output reg                   FIFO_WR_INC,
	  input                        FIFO_FULL,

	  input     [2*DATA_WIDTH-1:0] ALU_OUT,
	  input                        ALU_OUT_Valid,
	  output reg                   ALU_EN,
	  output reg [3:0]             ALU_FUN,

	  input     [DATA_WIDTH-1:0]   RF_Rd_D,
	  input                        RF_Rd_D_Vld,
	  output reg [DATA_WIDTH-1:0]  RF_Wr_D,
	  output reg [ADDR_width-1:0]  RF_ADDr,
	  output reg                   RF_RdEn,
	  output reg                   RF_WrEn,

	  output reg                   CLK_DIV_EN,
	  output reg                   G_CLK_EN,

	  input                        CLK,
	  input                        RST);


//////////////////////////////////////////
///////Register File Write command////////
////FRAME2///////FRAME1/////FRAME0////////
//RF_Wr_Data//RF_Wr_ADDR//RF_Wr_CMD(AA)///
//////////////////////////////////////////	


//////////////////////////////////////////
///////Register File READ command/////////
///////////FRAME1//////////FRAME0/////////
/////////RF_Rd_ADDR//////RF_Rd_CMD(BB)////
//////////////////////////////////////////	

/////////////////////////////////////////////////////
////ALU Operation command with operand///////////////
//FRAME3/////FRAME2/////FRAME1/////FRAME0////////////
//ALU_FUN///  OPB  ///   OPA  // ALU_OPER_W_OP(CC)///
/////////////////////////////////////////////////////	

////////////////////////////////////////////
////ALU Operation command with operand//////
////////////FRAME1//////////FRAME0//////////
///////////ALU_FUN/////ALU_OPER_W_NOP(DD)///
////////////////////////////////////////////

localparam  [3:0]     IDLE          = 4'b0000 ,
					  
					  
					  WRITE_ADDR    = 4'b0001 ,
                      WRITE_DATA    = 4'b0010 ,
                      
                      READ_ADDR     = 4'b0011 ,
                      RD_ADDR_VLD_FIFO   = 4'b0100 ,

                      ALU_OPA       = 4'b0101 ,
                      ALU_OPB       = 4'b0110 ,

                      ALU_FUN_S     = 4'b0111 ,
                      ALU_FUN_S_VLD_FIFO = 4'b1000 ,

                      FIFO2          = 4'b1001 ;
                      //FIFO2         = 4'b1010 ;    



////////////////////CMDS////////////////////
localparam  [7:0]    RF_Wr_CMD      = 8'hAA,
                     RF_Rd_CMD      = 8'hBB,
                     ALU_OPER_W_OP  = 8'hCC,
                     ALU_OPER_W_NOP = 8'hDD;
 


reg         [3:0]    c_state,
                     n_state ;


reg [DATA_WIDTH-1:0]   RF_ADDr_R;
reg [DATA_WIDTH-1:0] FiFO_DATA_temp;
//reg [DATA_WIDTH-1:0] FiFO_DATA_temp2;

always @(posedge CLK or negedge RST) 
begin 
	if (!RST) 
	begin
	  c_state <= IDLE ;
    end
	else 
	begin
	  c_state <= n_state ;	
	end
end


always@(*)
 begin

  case(c_state)

   IDLE: begin
          if(RX_VALID_SYN)
           begin
            case(RX_OUT_SYN)
             RF_Wr_CMD      : n_state = WRITE_ADDR ;
             RF_Rd_CMD      : n_state = READ_ADDR  ;
             ALU_OPER_W_OP  : n_state = ALU_OPA    ;
             ALU_OPER_W_NOP : n_state = ALU_FUN_S  ;
             default        : n_state = IDLE       ;
            endcase
           end

          else
           n_state=IDLE;

         end
      /////////////////write////////////////
   WRITE_ADDR:
         begin
          if(RX_VALID_SYN)
           n_state=WRITE_DATA;
          else
           n_state=WRITE_ADDR;
         end
   WRITE_DATA:
         begin
          if(RX_VALID_SYN)
           n_state= IDLE;
          else 
           n_state=WRITE_DATA;
         end
      ///////////read/////////////////
   
   READ_ADDR:
         begin
          if(RX_VALID_SYN)
           n_state= RD_ADDR_VLD_FIFO;
          else 
           n_state=READ_ADDR;
         end

   RD_ADDR_VLD_FIFO:
         begin
          if(RF_Rd_D_Vld)
           n_state=IDLE;
          else 
           n_state=RD_ADDR_VLD_FIFO;
         end

   
      ///////////ALU/////////////////
    ALU_OPA:
          begin
           if(RX_VALID_SYN)
            n_state= ALU_OPB;
           else 
            n_state= ALU_OPA; 
          end
    ALU_OPB:
          begin
           if(RX_VALID_SYN)
            n_state= ALU_FUN_S;
           else 
            n_state= ALU_OPB; 
          end

    ALU_FUN_S:
          begin
           if(RX_VALID_SYN)
            n_state=ALU_FUN_S_VLD_FIFO;
           else 
            n_state= ALU_FUN_S; 
          end
    ALU_FUN_S_VLD_FIFO:
          begin
           if(ALU_OUT_Valid&&!FIFO_FULL)
            n_state=FIFO2;
           else
            n_state=ALU_FUN_S_VLD_FIFO ;
          end
    FIFO2:
         begin
          if (!FIFO_FULL)
          n_state=IDLE;
          else
          n_state=FIFO2;	
         end
    /*     
    FIFO2:
         begin
          if (!FIFO_FULL)
          n_state=IDLE;
          else
          n_state=FIFO2;	
         end

    */



    default:
            n_state=c_state;
  endcase
 end



reg                    RF_ADDR_SAVE   ;





always@(*)
 begin
RF_Wr_D='b0     ;
RF_ADDr='b0     ;
RF_RdEn=1'b0    ;
RF_WrEn=1'b0    ;
FIFO_WR_DATA=0  ;
FIFO_WR_INC=1'b0;
ALU_FUN=0; 
ALU_EN=0;
CLK_DIV_EN=1'b1;
G_CLK_EN=1'b0;
 RF_ADDR_SAVE=0;
  case(c_state)
   IDLE: begin
          RF_Wr_D='b0     ;
          RF_ADDr='b0     ;
          RF_RdEn=1'b0    ;
          RF_WrEn=1'b0    ;
          FIFO_WR_DATA=0  ;
          FIFO_WR_INC=1'b0;
          ALU_FUN=0;
          ALU_EN=0;
          G_CLK_EN=1'b0;
          //RF_ADDr_R=0;
          FiFO_DATA_temp=0;
         end
      /////////////////write////////////////
   WRITE_ADDR:
         begin
          //RF_ADDr_R=0;
          FiFO_DATA_temp=0;
          /*if()
           RF_ADDr_R = RX_OUT_SYN; 
          else
           RF_ADDr_R =0;*/
           if(RX_VALID_SYN)
                   begin
                    RF_ADDR_SAVE = 1'b1 ;               
                   end
                 else
                   begin
                    RF_ADDR_SAVE = 1'b0 ;           
                   end                        
                
         end

   WRITE_DATA:
         begin
          
          FiFO_DATA_temp=0; 
          if(RX_VALID_SYN)
          begin
           RF_ADDr=RF_ADDr_R[ADDR_width-1:0];
           RF_WrEn=1'b1;
           RF_Wr_D= RX_OUT_SYN;
          end
          else
          begin
           RF_ADDr= 0   ;
           RF_WrEn= 1'b0;
           RF_Wr_D= 0   ;
          end
          //RF_ADDr_R=0;
         end
      ///////////read/////////////////
   READ_ADDR:
         begin
         FiFO_DATA_temp=0;
         	if(RX_VALID_SYN)
            begin
             RF_RdEn=1'b1;
             RF_ADDr = RX_OUT_SYN; 
             end
            else 
            begin
             RF_RdEn=1'b0;
             //RF_ADDr_R=0;	
            end
         end
   

   RD_ADDR_VLD_FIFO:
         begin
          RF_RdEn=1'b1;
          RF_ADDr=RF_ADDr_R;
          
          if(RF_Rd_D_Vld&&!FIFO_FULL)
           begin
           FIFO_WR_DATA=RF_Rd_D;
           FIFO_WR_INC=1'b1;
           end
          else 
          begin
            FIFO_WR_INC=1'b1;
          end

         // RF_ADDr_R=0;
          FiFO_DATA_temp=0;
         end
    

     ///////////ALU/////////////////
    ALU_OPA:
          begin
           if(RX_VALID_SYN)
            begin
             RF_Wr_D = RX_OUT_SYN;
             RF_ADDr = 'b00;
             RF_WrEn =1'b1;
            end
           else 
            begin
             RF_Wr_D = 0;
             RF_ADDr = 0;
             RF_WrEn = 0;
            end
            //RF_ADDr_R=0;
            FiFO_DATA_temp=0;
          end
    ALU_OPB:
          begin
          G_CLK_EN = 1'b1;
           if(RX_VALID_SYN)
            begin
             RF_Wr_D = RX_OUT_SYN;
             RF_ADDr = 'b01;
             RF_WrEn =1'b1;
            end
           else 
            begin
             RF_Wr_D = 0;
             RF_ADDr = 0;
             RF_WrEn = 0;
            end
           // RF_ADDr_R=0;
            FiFO_DATA_temp=0;
          end

    ALU_FUN_S:
          begin
           G_CLK_EN = 1'b1 ;
          if(RX_VALID_SYN)
           begin
            ALU_FUN=RX_OUT_SYN;
            ALU_EN =1'b1;
           end
          else
            begin 
            ALU_FUN=0;
            ALU_EN =0;
            end
           //RF_ADDr_R=0;
           FiFO_DATA_temp=0;
          end
    ALU_FUN_S_VLD_FIFO:
          begin
           //RF_ADDr_R=0;
           G_CLK_EN = 1'b1;
           if(ALU_OUT_Valid)
           begin
           	FIFO_WR_DATA=ALU_OUT[7:0];
           	FIFO_WR_INC=1'b1;
            FiFO_DATA_temp=ALU_OUT[15:8];
           end
           
           else
             FiFO_DATA_temp=0;
          end

    FIFO2:
    	begin
    	 FIFO_WR_DATA=FiFO_DATA_temp;
    	 FIFO_WR_INC=1'b1;
         //RF_ADDr_R=0;
         FiFO_DATA_temp=0;
    	end
    /*	
    FIFO2:
        begin
        FIFO_WR_DATA=FiFO_DATA_temp2;
        FIFO_WR_INC=1'b1; 
        end
*/
    default:
   		  begin
   		  RF_Wr_D='b0     ;
          RF_ADDr='b0     ;
          RF_RdEn=1'b0    ;
          RF_WrEn=1'b0    ;
          FIFO_WR_DATA=0  ;
          FIFO_WR_INC=1'b0;
          ALU_FUN=0; 
          ALU_EN=0;
          CLK_DIV_EN=1'b1;
          G_CLK_EN=1'b0;
         // RF_ADDr_R=0;
          FiFO_DATA_temp=0;
 		  end
  endcase
 end



 always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    RF_ADDr_R <= 0 ;
   end
  else
   begin
    if (RF_ADDR_SAVE)
     begin  
      RF_ADDr_R <= RX_OUT_SYN ;
     end 
   end
 end

endmodule 
