`timescale 1ns/1ps

module tb_uart_loopback;

    reg clk;
    reg reset;
    reg baud_tick;
    reg tx_start;
    reg [7:0] data_in;

    wire tx;
    wire tx_busy;

    wire [7:0] data_out;
    wire rx_done;

    //==============================
    // UART Transmitter
    //==============================
    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    //==============================
    // UART Receiver
    //==============================
    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .rx(tx),          // LOOPBACK CONNECTION
        .data_out(data_out),
        .rx_done(rx_done)
    );

    //==============================
    // Clock Generation
    //==============================
    initial
        clk = 0;

    always #5 clk = ~clk;

    //==============================
    // Test Sequence
    //==============================
    initial
    begin

        reset     = 1;
        baud_tick = 0;
        tx_start  = 0;
        data_in   = 8'b10110010;

        // Reset
        #20;
        reset = 0;

        // Start TX
        #20;
        tx_start = 1;

        #10;
        tx_start = 0;

        // Generate baud ticks
        repeat(12)
        begin
            #20;
            baud_tick = 1;

            #10;
            baud_tick = 0;
        end

        // Wait for RX completion
        #100;

        // Check Result
        if(data_out == data_in)
            $display("UART LOOPBACK PASS");
        else
        begin
            $display("UART LOOPBACK FAIL");
            $display("Expected = %b", data_in);
            $display("Received = %b", data_out);
        end

        $stop;

    end

endmodule
