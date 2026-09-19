module tb_baud_gen;

reg clk;
reg reset;
reg [15:0] divisor;
reg uart_enable ; 

wire baud_tick;
wire [15:0] counter;

baud_gen uut(
    .clk(clk),
    .reset(reset),
    .divisor(divisor),
    .baud_tick(baud_tick),
    .counter(counter),
    .uart_enable(uart_enable)
);

// Clock Generation
always #5 clk = ~clk;

initial
begin
    $monitor("counter = %d",counter);

    clk = 0;
    reset = 1;
    uart_enable = 0;
    divisor = 16'd5;

    #20;
    reset = 0;

    #20;
    uart_enable = 1;

    #80 ;

    uart_enable = 0;

    #40 ;
    uart_enable = 1;

    #80;

    
    $stop;

end

endmodule