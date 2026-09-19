module divisor_latch(
    input clk,
    input reset,

    input [7:0] dll,
    input [7:0] dlm,

    output reg [15:0] divisor   // it provides to baud gen
);

always @(posedge clk or posedge reset)
begin
    if (reset)
        divisor <= 16'd0;
    else
        divisor <= {dlm, dll};
end

endmodule