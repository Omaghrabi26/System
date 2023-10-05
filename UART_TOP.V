module UART_TOP #(parameter DATA_WIDTH = 8)
(
  input                    RST,
  input                    RX_CLK,
  input                    RX_IN,
  input [5:0]              Prescale,
  input		               PAR_EN,
  input                    PAR_TYP,
  output [DATA_WIDTH-1:0]  RX_OUT,
  output                   RX_VALID,
  output                   parity_error,
  output                   framing_error,


  input                    TX_CLK,
  input  [DATA_WIDTH-1:0]  TX_RD_IN,
  input                    TX_V_F_EMPTY,
  output                   TX_OUT,
  output                   Busy
 	);


UART_TX U0_UART_TX(
 .P_DATA(TX_RD_IN),
 .DATA_VALID(TX_V_F_EMPTY),
 .PAR_EN(PAR_EN),
 .PAR_TYP(PAR_TYP),
 .CLK(TX_CLK),
 .RST(RST),
 .TX_OUT(TX_OUT),
 .Busy(Busy));





UART_RX U0_UART_RX(
 .RX_IN(RX_IN),
 .Prescale(Prescale),
 .PAR_EN(PAR_EN),
 .PAR_TYP(PAR_TYP),
 .CLK(RX_CLK),
 .RST(RST),
 .P_DATA(RX_OUT),
 .data_valid(RX_VALID),
 .parity_error(parity_error),
 .framing_error(framing_error));
endmodule