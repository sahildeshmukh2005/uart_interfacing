module uart_reg_bank (
    input  wire        clk,
    input  wire        rst,


//----------------Peripheral Bus-----------------//
    input  wire        wr_en,        // 1 bit control signal
    input  wire        rd_en,        //  1 bit control signal

    input  wire [5:0]  addr,         // 6 bit address bus

    input  wire [7:0]  wr_data,      // 8 bit Data Bus    also data bus buffer
    output reg  [7:0]  rd_data,      // 8 bit Data Bus    also data bus buffer
// --------------------------------------------//

    output reg [7:0] tx_fifo_data,
    output reg       tx_fifo_wr,

  // ================= RX ADDED =================
   input  wire [7:0] rx_data,
   input  wire       rx_valid,

   input wire       tx_fifo_empty,
   input wire       tx_busy,

   input wire overrun_error,
   input wire framing_error,
   input wire break_interrupt,

   output wire      interrupt,
   output wire      rx_fifo_clear,
   output wire      tx_fifo_clear,
   output wire      uart_enable,
   output wire etbei,
   output wire erbi,
   output wire elsi
);

    //==================================================
    // Address Map (Datasheet)
    //==================================================
    localparam RBR_THR_ADDR      = 6'h00;          // rbr ani thr address is same 
    localparam IER_ADDR          = 6'h04;
    localparam IIR_FCR_ADDR      = 6'h08;
    localparam LCR_ADDR          = 6'h0C;
    localparam MCR_ADDR          = 6'h10;
    localparam LSR_ADDR          = 6'h14;
    localparam MSR_ADDR          = 6'h18;
    localparam SCR_ADDR          = 6'h1C;
    localparam DLL_ADDR          = 6'h20;
    localparam DLH_ADDR          = 6'h24;
    localparam REVID1_ADDR       = 6'h28;
    localparam REVID2_ADDR       = 6'h2C;
    localparam PWREMU_MGMT_ADDR  = 6'h30;         // power emulation managment register 
    localparam MDR_ADDR          = 6'h34;

    //==================================================
    // Internal Registers
    //==================================================
    reg [7:0] thr;             // write only register 
    reg [7:0] rbr;             // read only reg ahe haa

    reg [7:0] ier;
    reg [7:0] iir;
    reg [7:0] fcr;

    reg [7:0] lcr;
    reg [7:0] mcr;

    //reg [7:0] lsr_reg;
    wire [7:0] lsr;      //lsr register
    reg [7:0] msr;

    reg [7:0] scr;

    reg [7:0] dll;          // divisor latch lsb/lower
    reg [7:0] dlh;          // divisor lacth msb/higher

    reg [7:0] mdr;
    reg [7:0] pwremu_mgmt;         // 8 bit register 

    reg [7:0] revid1;
    reg [7:0] revid2;

    wire rx_interrupt;
    wire tx_interrupt;
    
    assign uart_enable = pwremu_mgmt[0];     // means pwremu_mgmt[0]= 1 means uart enable if 0 it disable
    //==================================================
    // Write Logic
    //==================================================
    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            thr          <= 8'h00;
            rbr          <= 8'h00;

            ier          <= 8'h00;
            iir          <= 8'h01;   // No interrupt pending
            fcr          <= 8'h00;

            lcr          <= 8'h03;   // 8-bit UART default
            mcr          <= 8'h00;

           // lsr          <= 8'h60;   // THR empty + TX empty
            msr          <= 8'h00;

            scr          <= 8'h00;

            dll          <= 8'h00;     
            dlh          <= 8'h00;

            mdr          <= 8'h00;
            pwremu_mgmt  <= 8'h01;   // UART enabled  if 8'h00 is there then it is disable

            revid1       <= 8'h10;
            revid2       <= 8'h01;
      
            tx_fifo_data <= 8'h00;
            tx_fifo_wr   <= 1'b0;
        end
        else
          begin

             tx_fifo_wr <= 1'b0;

          if (wr_en)
            begin
            case (addr)              // address decoder 

                // THR (write only)
                RBR_THR_ADDR:
                    begin
                       thr <= wr_data;         // firstly data is come into thr from cpu through data bus(wr_data)

                       tx_fifo_data <= wr_data;    // data goes to tx_fifo
                       tx_fifo_wr   <= 1'b1;
                    end

                IER_ADDR:
                    ier <= wr_data;

                // FCR (write only)
                IIR_FCR_ADDR:
                    fcr <= wr_data;

                LCR_ADDR:
                    lcr <= wr_data;

                MCR_ADDR:
                    mcr <= wr_data;

                SCR_ADDR:
                    scr <= wr_data;

                DLL_ADDR:
                    dll <= wr_data;

                DLH_ADDR:
                    dlh <= wr_data;

                PWREMU_MGMT_ADDR:
                    pwremu_mgmt <= wr_data;

                MDR_ADDR:
                    mdr <= wr_data;

                default:
                     ;

                endcase
           end      // if(wr_en)
           //========================
           // IIR UPDATE LOGIC
           //========================
           if (rx_interrupt)
               iir <= 8'h04;      // RX Interrupt

           else if (tx_interrupt)
               iir <= 8'h02;      // TX Interrupt

           else
               iir <= 8'h01;      // No Interrupt Pending

         end      // else
     end

assign etbei = ier[1];
assign erbi  = ier[0];
assign elsi  = ier[2];


// =================kela re add kahi tarhi =================
//================ LSR LOGIC =================
assign lsr[0] = rx_valid;          // Data Ready

assign lsr[1] = overrun_error;    // OE
assign lsr[2] = 1'b0;            // PE (later)
assign lsr[3] = framing_error;   // FE
assign lsr[4] = break_interrupt;            // BI (later)

assign lsr[5] = tx_fifo_empty;              // THR Empty (we will refine later)
assign lsr[6] = tx_fifo_empty & ~tx_busy;              // TX Empty (temporary safe default)
assign lsr[7]   = 1'b0;
///=======================================================444444
assign rx_interrupt = ier[0] & rx_valid;

assign tx_interrupt =
       ier[1] &
       tx_fifo_empty &
       (~tx_busy);      //assign tx_interrupt = ier[1] & tx_fifo_empty;

assign interrupt = rx_interrupt | tx_interrupt;

//====================================
// FCR FIFO CLEAR LOGIC
//====================================
assign rx_fifo_clear =
       wr_en &&
       (addr == IIR_FCR_ADDR) &&
       wr_data[1];

assign tx_fifo_clear =
       wr_en &&
       (addr == IIR_FCR_ADDR) &&
       wr_data[2];
 
always @(*)
begin
    if (rx_interrupt)
        iir = 8'h04;     // RX interrupt

    else if (tx_interrupt)
        iir = 8'h02;     // TX interrupt

    else
        iir = 8'h01;     // No interrupt pending
end


    //==================================================
    // Read Logic
    //==================================================
    always @(*)
    begin
        rd_data = 8'h00;

        if (rd_en)
        begin
            case (addr)                 // address decoder

                // RBR (read only)
                RBR_THR_ADDR:
                    rd_data = rbr;

                IER_ADDR:
                    rd_data = ier;

                // IIR (read only)
                IIR_FCR_ADDR:
                    rd_data = iir;

                LCR_ADDR:
                    rd_data = lcr;

                MCR_ADDR:
                    rd_data = mcr;

                LSR_ADDR:
                    rd_data = lsr;

                MSR_ADDR:
                    rd_data = msr;

                SCR_ADDR:
                    rd_data = scr;

                DLL_ADDR:
                    rd_data = dll;

                DLH_ADDR:
                    rd_data = dlh;

                REVID1_ADDR:
                    rd_data = revid1;

                REVID2_ADDR:
                    rd_data = revid2;

                PWREMU_MGMT_ADDR:
                    rd_data = pwremu_mgmt;

                MDR_ADDR:
                    rd_data = mdr;

                // ================= RX ADDITION START =================
                6'h38: rd_data = rx_data;
                6'h3c: rd_data = {7'b0, rx_valid};
                // ================= RX ADDITION END =================


                default:
                    rd_data = 8'h00;
            endcase
        end
    end

endmodule