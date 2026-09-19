module test(
    input clk,
    output reg q
);

initial
begin
    q = 0;
end

always @(posedge clk)
begin
    q <= ~q;
end

endmodule
