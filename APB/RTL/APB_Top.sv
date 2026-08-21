module APB_Top (
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic        TRANS,
    input  logic        READ,
    input  logic        WRITE,
  	input  logic [3:0]	APB_WRITE_STRB,
    input  logic [31:0] APB_WRITE_PADDR,
    input  logic [31:0] APB_WRITE_DATA,
    input  logic [31:0] APB_READ_PADDR,

    output logic [31:0] APB_READ_DATA_OUT,
    output logic        PREADY,
    output logic        PSLVERR
);

    //========================================
    // Wires từ Master
    //========================================
    logic        PENABLE;
    logic        PWRITE;
    logic [1:0]  PSELx;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
  	logic [3:0]  PSTRB;
    //========================================
    // Slave 0
    //========================================
    logic [31:0] PRDATA1;
    logic        PREADY1;
    logic        PSLVERR1;

    //========================================
    // Slave 1
    //========================================
    logic [31:0] PRDATA2;
    logic        PREADY2;
    logic        PSLVERR2;

    //========================================
    // Bus response
    //========================================
    logic [31:0] PRDATA_bus;
    logic        PREADY_bus;
    logic        PSLVERR_bus;

    //========================================
    // Master read data
    //========================================
    logic [31:0] master_read_data;

    //========================================
    // APB Bus Multiplexer
    //========================================
    assign PRDATA_bus  = PSELx[0] ? PRDATA1 :
                         PSELx[1] ? PRDATA2 :
                         32'h0;

    assign PREADY_bus  = PSELx[0] ? PREADY1 :
                         PSELx[1] ? PREADY2 :
                         1'b0;

    assign PSLVERR_bus = PSELx[0] ? PSLVERR1 :
                         PSELx[1] ? PSLVERR2 :
                         1'b0;

    //========================================
    // APB Master
    //========================================
    APB_Master master_inst (
        .PCLK              (PCLK),
        .PRESETn           (PRESETn),

        .TRANS             (TRANS),
        .READ              (READ),
        .WRITE             (WRITE),
      	.APB_WRITE_STRB	   (APB_WRITE_STRB),
        .APB_WRITE_PADDR   (APB_WRITE_PADDR),
        .APB_WRITE_DATA    (APB_WRITE_DATA),
        .APB_READ_PADDR    (APB_READ_PADDR),

        .APB_READ_DATA_OUT (master_read_data),

        .PSLVERR           (PSLVERR_bus),
        .PREADY            (PREADY_bus),
        .PRDATA            (PRDATA_bus),

        .PENABLE           (PENABLE),
        .PWRITE            (PWRITE),
        .PSELx             (PSELx),
      	.PSTRB			       (PSTRB),
        .PADDR             (PADDR),
        .PWDATA            (PWDATA)
    );

    //========================================
    // APB Slave 1
    //========================================
    APB_Slave slave1_inst (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),
        .PENABLE  (PENABLE),
        .PWRITE   (PWRITE),
        .PSELx    (PSELx[0]),
      	.PSTRB	  (PSTRB),
        .PADDR    (PADDR),
        .PWDATA   (PWDATA),
        .PRDATA   (PRDATA1),
        .PREADY   (PREADY1),
        .PSLVERR  (PSLVERR1)
    );

    //========================================
    // APB Slave 1
    //========================================
    APB_Slave slave2_inst (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),
        .PENABLE  (PENABLE),
        .PWRITE   (PWRITE),
        .PSELx    (PSELx[1]),
      	.PSTRB	  (PSTRB),
        .PADDR    (PADDR),
        .PWDATA   (PWDATA),
        .PRDATA   (PRDATA2),
        .PREADY   (PREADY2),
        .PSLVERR  (PSLVERR2)
    );

    //========================================
    // Top outputs
    //========================================
    always_comb begin
        APB_READ_DATA_OUT = master_read_data;
        PSLVERR           = PSLVERR_bus;
        PREADY            = PREADY_bus;
    end

    // Simulation check
    // always_comb begin
    //     assert (PSELx != 2'b11)
    //     else $error("APB_Top: Both slaves selected concurrently!");
    // end

endmodule
