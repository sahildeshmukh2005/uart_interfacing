`timescale 1ns/1ps

module tb_uart_rx;

reg clk;
reg reset;
reg baud_tick;
reg rx;
reg uart_enable;

wire [7:0] data_out;
wire rx_done;
wire framing_error;
wire break_interrupt;

//====================================================
// DUT
//====================================================

uart_rx uut(
    .clk(clk),
    .reset(reset),
    .baud_tick(baud_tick),
    .uart_enable(uart_enable),
    .rx(rx),
    .data_out(data_out),
    .rx_done(rx_done),
    .framing_error(framing_error),
    .break_interrupt(break_interrupt)
);

//====================================================
// Clock Generation
//====================================================

always #5 clk = ~clk;

//====================================================
// Monitor RX Done
//====================================================

always @(posedge clk)
begin
    if(rx_done)
        $display("Time=%0t  RX_DONE  Data=%b",$time,data_out);
end

//====================================================
// Test
//====================================================

initial
begin

    clk         = 0;
    reset       = 1;
    baud_tick   = 0;
    rx          = 1;      // UART idle
    uart_enable = 0;

    //----------------------------
    // Reset
    //----------------------------

    #20;
    reset = 0;

    #20;
    uart_enable = 1;

    //================================================
    // FRAME : 10110010
    //================================================

    // START BIT
    rx = 0;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    // Bit0 = 0
    rx = 0;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    // Bit1 = 1
    rx = 1;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    // Bit2 = 0
    rx = 0;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    // Bit3 = 0
    rx = 0;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    // Bit4 = 1
    rx = 1;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    // Bit5 = 1
    rx = 1;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    // Bit6 = 0
    rx = 0;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    // Bit7 = 1
    rx = 1;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    // STOP BIT
    rx = 1;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    #20;

    if(data_out == 8'b10110010)
        $display("RX PASS : %b",data_out);
    else
        $display("RX FAIL : %b",data_out);

    //================================================
    // BREAK TEST
    //================================================

    #100;

    // START BIT
    rx = 0;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    // 8 Data Bits = 00000000

    repeat(8)
    begin
        rx = 0;
        #10 baud_tick = 1;
        #10 baud_tick = 0;
    end

    // INVALID STOP BIT

    rx = 0;
    #10 baud_tick = 1;
    #10 baud_tick = 0;

    #20;

    

    $stop;

end

endmodule