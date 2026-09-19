
module tb_uart_tx;

reg clk;
reg reset;
reg baud_tick;
reg tx_start;
reg [7:0] data_in;
reg uart_enable;

wire tx;
wire tx_busy;


//====================================================
// Instantiate UART TX
//====================================================

uart_tx uut (
    .clk(clk),
    .reset(reset),
    .baud_tick(baud_tick),
    .tx_start(tx_start),
    .data_in(data_in),
    .uart_enable(uart_enable),
    .tx(tx),
    .tx_busy(tx_busy)
);


//====================================================
// Clock Generation
//====================================================

initial
begin
    clk = 0;
end

always #5 clk = ~clk;


//====================================================
// Test Sequence
//====================================================

initial
begin

    // Initial values
    reset = 1;
    uart_enable = 0;
    baud_tick = 0;
    tx_start = 0;
    data_in = 8'b10110010;

    // Hold reset for some time
    #20;
    reset = 0;
    
    #20;
    uart_enable = 1;

    // Start transmission
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


    // Stop simulation
    #100;
    $stop;

end

endmodule


