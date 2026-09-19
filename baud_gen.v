module baud_gen(
    input clk,            // FPGA/system Clock 
    input reset,
    input [15:0] divisor,
    input uart_enable,     // pwremu_mgmt 
    output reg baud_tick,
    output reg [15:0] counter
);

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        counter <= 16'd0;
        baud_tick <= 1'b0;
    end
    else if(uart_enable)    // condition for enable disable of baud genrator (pwremu_mgmt)
    begin
        if(counter == divisor - 1)
        begin
            counter <= 16'd0;
            baud_tick <= 1'b1;
        end
        else
        begin
            counter <= counter + 1'b1;
            baud_tick <= 1'b0;
        end
     end 
     else     // uart_disable 
      begin
        counter   <= 16'd0;
        baud_tick <= 1'b0;
      end
   
end

endmodule