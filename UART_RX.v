module UART_RX 
#(parameter data_width = 8)
//#(parameter prescale_v = 16)
( 
	input                      RX_IN,
	input [5:0]                Prescale,
	input                      PAR_EN,
	input                      PAR_TYP,
	input                      CLK,
	input                      RST,
	output [data_width-1:0]    P_DATA,
	output                     data_valid,
  output  wire                          parity_error,
  output  wire                          framing_error
	);

wire [3:0] bit_cnt ;
wire [5:0] edge_cnt;  
wire data_samp_en ,strt_glitch,
     enable ,par_chk_en ,strt_chk_en ,stp_chk_en ,deser_en ;

FSM_RX FSM_U0(
  .RX_IN(RX_IN),
  .PAR_EN(PAR_EN),
  .edge_cnt(edge_cnt),
  .bit_cnt(bit_cnt),
  .stp_err(framing_error),
  .strt_glitch(strt_glitch),
  .par_err(parity_error),
  .CLK(CLK),
  .RST(RST),
  .Prescale(Prescale),
  .data_samp_en(data_samp_en),
  .enable(enable),
  .par_chk_en(par_chk_en),
  .strt_chk_en(strt_chk_en),
  .stp_chk_en(stp_chk_en),
  .deser_en(deser_en),
 
  .data_valid(data_valid)
  );


edge_bit_counter U0_edge_bit_counter( 
  .enable(enable),
  .Prescale(Prescale),
  .RST(RST),
  .CLK(CLK),
  .PAR_EN(PAR_EN),
  .edge_cnt(edge_cnt),

  .bit_cnt(bit_cnt)
  );

wire sampled_bit;

data_sampling U0_data_sampling(
 .CLK(CLK),
 .RST(RST),
 .RX_IN(RX_IN),
 .Prescale(Prescale),
 .edge_cnt(edge_cnt),
 .data_samp_en(data_samp_en),
 .sampled_bit(sampled_bit));


deserializer #(.data_width(data_width))
 U0_deserializer( 
   .CLK(CLK),
   .RST(RST),
   .sampled_bit(sampled_bit),
   .deser_en(deser_en),
   .P_DATA(P_DATA),
   .bit_cnt(bit_cnt)
);

parity_check #(.data_width(data_width))
U0_parity_check
 (
  .P_DATA(P_DATA),
  .CLK(CLK),
  .RST(RST),
  .PAR_TYP(PAR_TYP),
  .par_chk_en(par_chk_en),
  .sampled_bit(sampled_bit),
  .par_err(parity_error) 
  );

strt_check U0_strt_check ( 
  
  .CLK(CLK),
  .RST(RST),
  .strt_chk_en(strt_chk_en),
  .sampled_bit(sampled_bit),
  .strt_glitch(strt_glitch) 
  );

stop_check  U0_stop_check  ( 
  
  .CLK(CLK),
  .RST(RST),
  .stp_chk_en(stp_chk_en),
  .sampled_bit(sampled_bit),
  .stp_err(framing_error) 
  );
endmodule