module rx_fifo (
    input clk,
    input reset,
    input clear,

    input wr_en,
    input rd_en,

    input [7:0] data_in,
    output reg [7:0] data_out,

    output full,
    output empty
);

    reg [7:0] mem [0:15];

    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;
    reg [4:0] count;

    assign full  = (count == 16);
    assign empty = (count == 0);

    always @(posedge clk or posedge reset)
    begin
        if(reset || clear)
        begin
            wr_ptr   <= 4'd0;
            rd_ptr   <= 4'd0;
            count    <= 5'd0;
            data_out <= 8'd0;
        end
        else
        begin

            if(wr_en && !full && !(rd_en && !empty))
            begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;
                count  <= count + 1'b1;
            end

            else if(rd_en && !empty && !(wr_en && !full))
            begin
                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
                count  <= count - 1'b1;
            end

            else if(wr_en && !full && rd_en && !empty)
            begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;

                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
            end

        end
    end

endmodule