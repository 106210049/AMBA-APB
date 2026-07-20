module APB_Slave (
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic        PSELx,
    input  logic [3:0]  PSTRB,
    input  logic [31:0] PADDR,
    input  logic [31:0] PWDATA,

    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR
);

    //==================================================
    // DATA PATH
    //==================================================
    logic [31:0] memory [0:1023];

    logic [28:0] addr_index;

    //==================================================
    // CONTROL PATH
    //==================================================
    logic [1:0] count_reg;
    logic [1:0] target_wait;

    logic addr_ok;
    logic wait_done;
    logic read_en;
    logic write_en;

    //--------------------------------------------------
    // Address Decode
    //--------------------------------------------------
    assign target_wait = PADDR[1:0];
    assign addr_index  = PADDR[30:2];

    assign addr_ok =
        (addr_index < 1024);

    //--------------------------------------------------
    // Wait-State Complete
    //--------------------------------------------------
    assign wait_done =
        (count_reg == target_wait);

    //--------------------------------------------------
    // Wait-State Counter
    //--------------------------------------------------
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            count_reg <= 2'd0;
        end
        else begin

            if (PSELx && PENABLE) begin

                if (!wait_done)
                    count_reg <= count_reg + 1'b1;
                else
                    count_reg <= 2'd0;

            end
            else begin
                count_reg <= 2'd0;
            end

        end
    end

    //--------------------------------------------------
    // APB Handshake
    //--------------------------------------------------
    assign PREADY =
        PSELx   &&
        PENABLE &&
        wait_done;

    //--------------------------------------------------
    // Error Response
    //--------------------------------------------------
    assign PSLVERR =
        PREADY &&
        !addr_ok;

    //--------------------------------------------------
    // Read / Write Enable
    //--------------------------------------------------
    assign write_en =
        PREADY  &&
        PWRITE  &&
        addr_ok;

    assign read_en =
        PREADY  &&
        !PWRITE &&
        addr_ok;

    //==================================================
    // DATA PATH : MEMORY WRITE
    //==================================================
    integer i;

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            for (i = 0; i < 1024; i++)
                memory[i] <= '0;
        end
        else if (write_en) begin
            if (PSTRB[0]) memory[addr_index][7:0]   <= PWDATA[7:0];
            if (PSTRB[1]) memory[addr_index][15:8]  <= PWDATA[15:8];
            if (PSTRB[2]) memory[addr_index][23:16] <= PWDATA[23:16];
            if (PSTRB[3]) memory[addr_index][31:24] <= PWDATA[31:24];
        end
    end

    //==================================================
    // DATA PATH : MEMORY READ
    //==================================================
    always_comb begin
        PRDATA = 32'd0;

        if (read_en)
            PRDATA = memory[addr_index];
    end

endmodule
