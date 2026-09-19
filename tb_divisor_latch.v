module tb_divisor_latch;

reg clk = 0;
reg reset;
reg [7:0] dll;
reg [7:0] dlm;

wire [15:0] divisor;
//wire [15:0] counter;

divisor_latch dut(
    .clk(clk),
    .reset(reset),
    .dll(dll),
    .dlm(dlm),
    .divisor(divisor)
    
);

always #5 clk = ~clk;

initial begin
    reset = 1;
    dll = 0;
    dlm = 0;

    #10 reset = 0;

    dll = 8'h05;
    dlm = 8'h02;

    #20;

    dll = 8'hFF;
    dlm = 8'h01;

    #20;

    $stop;
end

endmodule