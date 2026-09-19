module uart_rx(
    input clk,
    input reset,
    input baud_tick,
    input uart_enable,     // pwremu_mgmt 
    input rx,

    output reg [7:0] data_out,   // behaves like RBR 
    output reg rx_done,
    output reg framing_error,
    output reg break_interrupt
);

    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;

    reg [1:0] state;

    reg [7:0] shift_reg;       // RSR 
    reg [2:0] bit_count;

    always @(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            state     <= IDLE;
            shift_reg <= 8'd0;
            bit_count <= 0;
            data_out  <= 0;
            rx_done   <= 0;
            framing_error <= 0;
            break_interrupt <= 0;
        end
        else
        begin
            rx_done <= 0;
            break_interrupt <= 0;

            case(state)

            IDLE:
            begin
                if(uart_enable && (rx == 0))     //condition for enable disable of receiver (pwremu_mgmt)
                begin
                    framing_error <= 0;
                    state <= START;
                end
            end

            START:
            begin
                if(baud_tick)
                begin
                    // move to middle of start bit
                    bit_count <= 0;
                    shift_reg <= 0;
                    state <= DATA;
                end
            end

            DATA:
            begin
                if(baud_tick)
                begin
                    // ? CORRECT LSB FIRST SHIFT
                    shift_reg[bit_count] <= rx;          // one by one bits are coming in RSR 

                    if(bit_count == 7)
                        state <= STOP;
                    else
                        bit_count <= bit_count + 1;
                end
            end

            STOP:
            begin
                if(baud_tick)
                begin
                    if(rx == 1'b0)
                    begin
                    framing_error <= 1'b1;

                         if(shift_reg == 8'h00)
                            break_interrupt <= 1'b1;
                     end

                      data_out <= shift_reg;         // data challa pn kona kade RBR kade 
                      rx_done  <= 1'b1;
                       state    <= IDLE;
                 end
            end

            endcase
        end
    end

endmodule