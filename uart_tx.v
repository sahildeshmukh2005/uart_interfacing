
module uart_tx(
    input clk,
    input reset,
    input baud_tick,
    input tx_start,         // start transmitting 
    input [7:0] data_in,    // coming from thr
    input uart_enable,  // PWREMU_MGMT 

    output reg tx,
    output reg tx_busy
);


//====================================================
// State Declaration
//====================================================

parameter IDLE  = 2'b00;
parameter START = 2'b01;
parameter DATA  = 2'b10;
parameter STOP  = 2'b11;

reg [1:0] state;


//====================================================
// Internal Registers
//====================================================

reg [7:0] shift_reg;       // TSR 
reg [2:0] bit_count;       


//====================================================
// UART Transmission Logic
//====================================================

always @(posedge clk or posedge reset)
begin

    if(reset)
    begin
        state      <= IDLE;
        tx         <= 1'b1;
        tx_busy    <= 1'b0;
        shift_reg  <= 8'd0;
        bit_count  <= 3'd0;
    end

    else
    begin

        case(state)


//====================================================
// IDLE STATE
//====================================================

        IDLE:
        begin

            tx <= 1'b1;
            tx_busy <= 1'b0;

            if(uart_enable && tx_start)    // important condition for enable disable of transmitter (pwremu_mgmt)
            begin
                shift_reg <= data_in;       // 
                bit_count <= 3'd0;

                tx_busy <= 1'b1;

                state <= START;
            end

        end


//====================================================
// START BIT
//====================================================

        START:
        begin

            if(baud_tick)
            begin
                tx <= 1'b0;

                state <= DATA;
            end

        end


//====================================================
// DATA BITS
//====================================================

        DATA:
        begin

            if(baud_tick)
            begin

                tx <= shift_reg[0];

                shift_reg <= shift_reg >> 1;

                if(bit_count == 3'd7)
                begin
                    state <= STOP;
                end

                else
                begin
                    bit_count <= bit_count + 1'b1;
                end

            end

        end


//====================================================
// STOP BIT
//====================================================

        STOP:
        begin

            if(baud_tick)
            begin

                tx <= 1'b1;

                state <= IDLE;
            end

        end

        endcase

    end

end

endmodule

