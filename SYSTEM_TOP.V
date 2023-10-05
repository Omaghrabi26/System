module SYSTEM_TOP # ( parameter DATA_WIDTH = 8,ADDR_width=8)
(
  input            			    RX_IN,
  input                     UART_CLK,
  input                     RST,
  input                     REF_CLK,
  output                    TX_OUT,
  output                    parity_error,
  output                    framing_error);



wire [DATA_WIDTH-1:0] RX_OUT;

wire [DATA_WIDTH-1:0]   UART_Config;
wire [DATA_WIDTH-1:0]   DIV_RATIO_DEF;

wire [DATA_WIDTH-1:0]   DIV_RATIO_RX;

wire                    RX_VALID;
wire [DATA_WIDTH-1:0]   RX_OUT_SYN;
wire                    RX_VALID_SYN;


wire [2*DATA_WIDTH-1:0] ALU_OUT;
wire [3:0]              ALU_FUN;
wire                    ALU_OUT_Valid;
wire                    ALU_EN;
wire [DATA_WIDTH-1:0] RF_Rd_D;
wire                    RF_Rd_D_Vld;
wire [DATA_WIDTH-1:0]   RF_Wr_D;
wire [ADDR_width-1:0]   RF_ADDr;
wire                    RF_RdEn;
wire                    RF_WrEn;

wire [DATA_WIDTH-1:0]   OPA;
wire [DATA_WIDTH-1:0]   OPB;

wire                    G_CLK_EN;
wire                    GATED_CLK;

wire                    SYNC_RST1;
wire                    SYNC_RST_UART;
wire                    TX_CLK;
wire                    RX_CLK;

wire [DATA_WIDTH-1:0]   FIF0_DATA_TX;
wire                    FIFO_VALID_TX;
wire                    TX_BUSY;

wire                    FIFO_WR_INC;
wire                    UART_TX_Busy_PULSE;

wire [DATA_WIDTH-1:0]   FIFO_WR_DATA;
wire                    CLK_DIV_EN;


DATA_SYNC #(.BUS_WIDTH(DATA_WIDTH))
U0_DATA_SYNC
(
 .CLK(REF_CLK),
 .RST(SYNC_RST1),
 .unsync_bus(RX_OUT),
 .bus_enable(RX_VALID),
 .sync_bus(RX_OUT_SYN),
 .enable_pulse_d(RX_VALID_SYN)
);



UART_TOP #(.DATA_WIDTH(DATA_WIDTH))
U0_UART_TOP
(
 .RST(SYNC_RST_UART),
 .RX_CLK(RX_CLK),
 .RX_IN(RX_IN),
 .Prescale(UART_Config[7:2]),
 .PAR_EN(UART_Config[0]),
 .PAR_TYP(UART_Config[1]),
 .RX_OUT(RX_OUT),
 .RX_VALID(RX_VALID),
 .parity_error(parity_error),
 .framing_error(framing_error),


 .TX_CLK(TX_CLK),
 .TX_RD_IN(FIF0_DATA_TX),
 .TX_V_F_EMPTY(!FIFO_VALID_TX),
 .TX_OUT(TX_OUT),
 .Busy(TX_BUSY)
 	);


SYS_CTRL #(.DATA_WIDTH(DATA_WIDTH),.ADDR_width(ADDR_width))
U0_SYS_CTRL
  (
    .RX_OUT_SYN(RX_OUT_SYN),
    .RX_VALID_SYN(RX_VALID_SYN),
   
    .FIFO_WR_DATA(FIFO_WR_DATA),
    .FIFO_WR_INC(FIFO_WR_INC),
    .FIFO_FULL(FIFO_FULL),

    .ALU_OUT(ALU_OUT),
    .ALU_OUT_Valid(ALU_OUT_Valid),
    .ALU_EN(ALU_EN),
    .ALU_FUN(ALU_FUN),

    .RF_Rd_D(RF_Rd_D),
    .RF_Rd_D_Vld(RF_Rd_D_Vld),
    .RF_Wr_D(RF_Wr_D),
    .RF_ADDr(RF_ADDr),
    .RF_RdEn(RF_RdEn),
    .RF_WrEn(RF_WrEn),

    .CLK_DIV_EN(CLK_DIV_EN),
    .G_CLK_EN(G_CLK_EN),

    .CLK(REF_CLK),
    .RST(SYNC_RST1) 
    );

RegFile #(.WIDTH(DATA_WIDTH), .DEPTH(16), .ADDR(ADDR_width))
U0_RegFile
(
.CLK(REF_CLK),
.RST(SYNC_RST1),
.WrEn(RF_WrEn),
.RdEn(RF_RdEn),
.Address(RF_ADDr),
.WrData(RF_Wr_D),
.RdData(RF_Rd_D),
.RdData_VLD(RF_Rd_D_Vld),
.REG0(OPA),
.REG1(OPB),
.REG2(UART_Config),
.REG3(DIV_RATIO_DEF));

CLK_GATE U0_CLK_GATE(
.CLK_EN(G_CLK_EN),
.CLK(REF_CLK),
.GATED_CLK(GATED_CLK)
);

ALU #(.OPER_WIDTH(DATA_WIDTH),.OUT_WIDTH(DATA_WIDTH*2))
U0_ALU
(
 .A(OPA), 
 .B(OPB),
 .EN(ALU_EN),
 .ALU_FUN(ALU_FUN),
 .CLK(GATED_CLK),
 .RST(SYNC_RST1),  
 .ALU_OUT(ALU_OUT),
 .OUT_VALID(ALU_OUT_Valid) 
);

PULSE_GEN PULE_GEN_TX (
 .CLK(TX_CLK),
 .RST(SYNC_RST_UART),
 .sig(TX_BUSY),
 .pulse(UART_TX_Busy_PULSE)
  );
/*
ASYC_FIFO #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(3),.NUM_STAGES(2))
ASYC_FIFO_U
(.W_CLK(REF_CLK),
 .W_RST(SYNC_RST1),
 .W_INC(FIFO_WR_INC),
 .R_CLK(TX_CLK),
 .R_RST(SYNC_RST_UART),
 .R_INC(UART_TX_Busy_PULSE),
 .WR_DATA(FIFO_WR_DATA),

  .FULL(FIFO_FULL),
  .EMPTY(FIFO_VALID_TX),
  .RD_DATA(FIF0_DATA_TX));
*/

Async_fifo #(.D_SIZE(DATA_WIDTH) , .P_SIZE(4)  , .F_DEPTH(8)) U0_UART_FIFO (
.i_w_clk(REF_CLK),
.i_w_rstn(SYNC_RST1),  
.i_w_inc(FIFO_WR_INC),
.i_w_data(FIFO_WR_DATA),

.i_r_clk(TX_CLK),              
.i_r_rstn(SYNC_RST_UART),              
.i_r_inc(UART_TX_Busy_PULSE),

.o_r_data(FIF0_DATA_TX),             
.o_full(FIFO_FULL),               
.o_empty(FIFO_VALID_TX)               
);

RST_SYNC # (.NUM_STAGES(2))
U0_RST_SYNC_1
(
 .RST(RST),
 .CLK(REF_CLK),
 .SYNC_RST(SYNC_RST1)
);

RST_SYNC # (.NUM_STAGES(2))
U0_RST_SYNC_UART
(
 .RST(RST),
 .CLK(UART_CLK),
 .SYNC_RST(SYNC_RST_UART)
);

ClkDiv #(.RATIO_WD(8)) 
CLKDiv_UART_TX (
 .i_ref_clk(UART_CLK),
 .i_rst(SYNC_RST_UART),
 .i_clk_en(CLK_DIV_EN),
 .i_div_ratio(DIV_RATIO_DEF),
 .o_div_clk(TX_CLK)
);

ClkDiv #(.RATIO_WD(8))
CLKDiv_UART_RX (
 .i_ref_clk(UART_CLK),
 .i_rst(SYNC_RST_UART),
 .i_clk_en(CLK_DIV_EN),
 .i_div_ratio(DIV_RATIO_RX),
 .o_div_clk(RX_CLK)
);

CLKDIV_MUX #(.WIDTH(8))
CLKDIV_MUX_RX  (
.IN(UART_Config[7:2]),
.OUT(DIV_RATIO_RX)
);

endmodule














