# System

########### RTL to GDS Implementation of Low Power Configurable Multi Clock Digital System  ############
                                  (Under supervision of Eng. Ali ElTemsah)
Responsible of receiving commands through UART receiver to do different system functions as register file
reading/writing or doing some processing using ALU block and send result using 4 bytes frame through UART
transmitter communication protocol.

1.This system contains 10 blocks: -
1) Clock Domain 1 (REF_CLK)
• RegFile
• ALU
• Clock Gating
• SYS_CTRL

2) Clock Domain 2 (UART_CLK)

• UART_TX
• UART_RX
• PULSE_GEN
• Clock Dividers

3) Data Synchronizers
• RST Synchronizer
• Data Synchronizer
• ASYNC FIFO


