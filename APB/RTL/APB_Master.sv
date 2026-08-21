module APB_Master (
    input  logic        PCLK,
    input  logic        PRESETn,

    // System APB BUS
    input  logic        TRANS,
    input  logic        READ,
    input  logic        WRITE,
  	input  logic [3:0]	APB_WRITE_STRB,
    input  logic [31:0] APB_WRITE_PADDR,
    input  logic [31:0] APB_WRITE_DATA,
    input  logic [31:0] APB_READ_PADDR,
    output logic [31:0] APB_READ_DATA_OUT,

    // APB Signals
    input  logic        PSLVERR,
    input  logic        PREADY,
    input  logic [31:0] PRDATA,

    output logic        PENABLE,
    output logic        PWRITE,
    output logic [1:0]  PSELx,
  	output logic [3:0]  PSTRB,          // NEW: strobes ra bus
    output logic [31:0] PADDR,
    output logic [31:0] PWDATA
);

    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        SETUP  = 2'b01,
        ACCESS = 2'b10
    } state_t;

    state_t current_state, next_state;

    //====================================================
    // State register
    //====================================================
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    //====================================================
    // Next-state logic + Output logic
    //====================================================
    always_comb begin
        // Default values
        next_state        = current_state;

        PENABLE           = 1'b0;
        PWRITE            = 1'b0;
        PSELx             = 2'b00;
        PADDR             = 32'h0;
        PWDATA            = 32'h0;
        APB_READ_DATA_OUT = 32'h0;

        case (current_state)

            IDLE: begin
                if (TRANS)
                    next_state = SETUP;
            end

            SETUP: begin
                next_state = ACCESS;

                if (WRITE && !READ) begin
                    PWRITE = 1'b1;
                    PADDR  = APB_WRITE_PADDR;
                    PWDATA = APB_WRITE_DATA;
					PSTRB  = APB_WRITE_STRB;
                    PSELx  = (APB_WRITE_PADDR[31])
                           ? 2'b10
                           : 2'b01;
                end
                else if (!WRITE && READ) begin
                    PWRITE = 1'b0;
                    PADDR  = APB_READ_PADDR;
					PSTRB  = 4'b0000;
                    PSELx  = (APB_READ_PADDR[31])
                           ? 2'b10
                           : 2'b01;
                end
            end

            ACCESS: begin
                PENABLE = 1'b1;

                // Giữ lại các control signal của SETUP
                if (WRITE && !READ) begin
                    PWRITE = 1'b1;
                    PADDR  = APB_WRITE_PADDR;
                    PWDATA = APB_WRITE_DATA;
                  	PSTRB  = APB_WRITE_STRB;
                    PSELx  = (APB_WRITE_PADDR[31])
                           ? 2'b10
                           : 2'b01;
                end
                else if (!WRITE && READ) begin
                    PWRITE = 1'b0;
                    PADDR  = APB_READ_PADDR;
                  	PSTRB  = 4'b0000;
                    PSELx  = (APB_READ_PADDR[31])
                           ? 2'b10
                           : 2'b01;
                end

                if (!PREADY) begin
                    next_state = ACCESS;
                end
                else begin
                    if (!WRITE && READ)
                        APB_READ_DATA_OUT = PRDATA;

                    next_state = (TRANS) ? SETUP : IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

endmodule
