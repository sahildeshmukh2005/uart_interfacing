`timescale 1ns/1ps

module tb_uart_top_basic;

reg clk;
reg reset;

// UART Pins
wire tx;
wire rx;

// Divisor Latch Inputs
reg [7:0] dll;
reg [7:0] dlm;

// UART Control
reg uart_enable;

// TX Inputs
reg tx_start;
reg [7:0] tx_data;

// Interrupt Enable
reg etbei;
reg erbi;
reg elsi;

// Outputs
wire [7:0] rx_data;
wire rx_done;
wire framing_error;
wire break_interrupt;
wire interrupt;
wire [3:0] iir;

//----------------------------------------------------
// Loopback Connection
//----------------------------------------------------
assign rx = tx;

//----------------------------------------------------
// DUT
//----------------------------------------------------

uart_top_basic uut(

    .clk(clk),
    .reset(reset),

    .rx(rx),
    .tx(tx),

    .dll(dll),
    .dlm(dlm),

    .uart_enable(uart_enable),

    .tx_start(tx_start),
    .tx_data(tx_data),

    .etbei(etbei),
    .erbi(erbi),
    .elsi(elsi),

    .rx_data(rx_data),
    .rx_done(rx_done),

    .framing_error(framing_error),
    .break_interrupt(break_interrupt),

    .interrupt(interrupt),
    .iir(iir)

);

//----------------------------------------------------
// Clock Generation
//----------------------------------------------------

always #5 clk = ~clk;

//----------------------------------------------------
// Test Sequence
//----------------------------------------------------

initial
begin

    clk = 0;
    reset = 1;

    dll = 8'd5;
    dlm = 8'd0;

    uart_enable = 0;

    tx_start = 0;
    tx_data = 8'b10110010;

    etbei = 1;
    erbi  = 1;
    elsi  = 1;

    // Apply Reset
    #20;
    reset = 0;

    // Enable UART
    #20;
    uart_enable = 1;

    // Start Transmission
    #20;
    tx_start = 1;

    #10;
    tx_start = 0;

    // Wait for transmission/reception
    #1000;

    $stop;

end

endmodule