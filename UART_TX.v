module UART_TX (
 input [7:0] P_DATA,
 input DATA_VALID,
 input PAR_EN,
 input PAR_TYP,
 input CLK,
 input RST,
 output TX_OUT,
 output Busy
 );
 

wire ser_done;
wire ser_en;
wire [1:0] mux_sel;
wire ser_data;
wire par_bit;


serializer U0_serializer (
.P_data (P_DATA),
.clk (CLK),
.rst (RST),
.ser_en (ser_en),
.ser_dn (ser_done),
.S_data (ser_data),
.busy (Busy)
);
/*
fsm U0_fsm (
.par_en (PAR_EN),
.clk (CLK),
.rst (RST),
.data_valid (DATA_VALID),
.ser_dn (ser_done),
.busy (Busy),
.select (mux_sel),
.ser_en (ser_en)
);
*/
fsm U0_fsm (
.PAR_EN (PAR_EN),
.CLK (CLK),
.RST (RST),
.DATA_VALID (DATA_VALID),
.ser_done (ser_done),
.Busy (Busy),
.mux_sel (mux_sel),
.ser_en (ser_en)
);
parity U0_parity (
.data_valid (DATA_VALID),
.P_data (P_DATA),
.P_type (PAR_TYP),
.P_bit (par_bit),
.clk (CLK),
.rst (RST),
.busy (Busy)
);

muxm U0_mux (
.select (mux_sel),
.parity_bit (par_bit),
.data (ser_data),
.tx_out (TX_OUT)
//.CLK(CLK),
//.RST(RST)
);

endmodule
 
