module APB_Master (
    input wire PCLK, PRESETn,
    // System APB BUS
    input wire TRANS, READ, WRITE,
    input wire [31:0] APB_WRITE_PADDR, APB_WRITE_DATA, APB_READ_PADDR,
    output reg [31:0] APB_READ_DATA_OUT,
    // APB Signals
    input wire PSLVERR, PREADY,
    input wire [31:0] PRDATA,

    output reg PENABLE, PWRITE,
    output reg [1:0] PSELx,
    output reg [31:0] PADDR,
    output reg [31:0] PWDATA
);
    localparam IDLE = 2'b00;
    localparam SETUP = 2'b01;
    localparam ACCESS = 2'b10;

    reg [1:0] current_state, next_state;
    // Sequential circuits for current state
    always @(posedge PCLK or negedge PRESETn ) begin
        if(!PRESETn)    begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end
    // Combinational Circuits for next state
    always @(*) begin
        case(current_state)
        IDLE:   begin
            if(TRANS)   begin
                next_state = SETUP;
            end
            else    begin
                next_state = IDLE;
            end
        end
        SETUP:  begin
            next_state = ACCESS;
        end
        ACCESS: begin
            if(!PREADY) begin
                next_state = current_state;
            end
            else    begin
                if(TRANS)   begin
                    next_state = SETUP;
                end
                else    begin
                    next_state = IDLE;
                end
            end
        end
        default: next_state = IDLE;
        endcase
    end
    // Output signals
    always @(*) begin
        case(current_state)
        IDLE: begin
            PSELx = 2'b00;
            PWRITE = 0;
            PADDR = 0;
            PWDATA = 0;
            PENABLE = 0;
        end
        SETUP:  begin
            PENABLE = 0;
            if(WRITE & !READ)    begin
                PWRITE = 1;
                PADDR = APB_WRITE_PADDR;
                PSELx[0] = (APB_WRITE_PADDR[31] == 0);
                PSELx[1] = (APB_WRITE_PADDR[31] == 1);

                PWDATA = APB_WRITE_DATA;
            end
            else if(!WRITE & READ)    begin
                PWRITE = 0;
                PADDR = APB_READ_PADDR;
                PSELx[0] = (APB_READ_PADDR[31] == 0);
                PSELx[1] = (APB_READ_PADDR[31] == 1);
            end
            else    begin
                PSELx = 0;
                PWRITE = 0;
                PADDR = 0;
                PWDATA = 0;
            end
        end
        ACCESS: begin
            PENABLE = 1;
            if(PREADY)  begin
                if(!WRITE & READ)   begin
                    APB_READ_DATA_OUT = PRDATA;
                end
                else    begin
                    APB_READ_DATA_OUT = 0;
                end
            end
            else    begin
                APB_READ_DATA_OUT = 0;
            end
        end
        default: begin
            PSELx = 2'b00;
            PWRITE = 0;
            PENABLE = 0;
            PADDR = 0;
            PWDATA = 0;
            APB_READ_DATA_OUT = 0;
        end
        endcase
    end
endmodule
