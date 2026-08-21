interface apb_if(input logic PCLK, input logic PRESETn);

    // Input of Master (Global Signals)
    logic        TRANS;
    logic        READ;
    logic        WRITE;
    logic [3:0]	 APB_WRITE_STRB;
    logic [31:0] APB_WRITE_PADDR;
    logic [31:0] APB_WRITE_DATA;
    logic [31:0] APB_READ_PADDR;
    logic [31:0] APB_READ_DATA_OUT;

    // Output of Slave (Input of Master)
    logic        PSLVERR;
    logic        PREADY;
    logic [31:0] PRDATA;

    // Output of Master (Input of Slave)
    logic        PENABLE;
    logic        PWRITE;
    logic [1:0]  PSELx;
    logic [3:0]  PSTRB;         
    logic [31:0] PADDR;
    logic [31:0] PWDATA;

    bit master_monstart, master_drvstart;
    bit slave_monstart, slave_drvstart;
    modport master(
        input   PCLK,
        input   PRESETn,
        input   TRANS, 
                READ, 
                WRITE,
                APB_WRITE_STRB,
                APB_WRITE_PADDR,
                APB_WRITE_DATA,
                APB_READ_PADDR,
                PSLVERR,
                PREADY,
                PRDATA,
        output  APB_READ_DATA_OUT,
                PENABLE,
                PWRITE,
                PSELx,
                PSTRB,
                PADDR,
                PWDATA,
        import  apb_master_reset,
                master_write_transfer,
                master_read_transfer,
                apb_master_collector,
        input   master_monstart,
                master_drvstart
    );

     modport slave (
        input   PCLK,
        input   PRESETn,
        input   PWRITE,
                PENABLE,
                PADDR,
                PWDATA,
                PSELx,
                PSTRB,
        output  PRDATA,
                PREADY,
                PSLVERR,
        import  apb_slave_collector,
                apb_slave_reset,
        input   slave_monstart,
                slave_drvstart
    );
    

task apb_master_reset();
        @(negedge PRESETn);
        TRANS            <= '0;
        READ             <= '0;
        WRITE            <= '0;
        APB_WRITE_STRB   <= '0;
        APB_WRITE_PADDR  <= '0;
        APB_READ_PADDR   <= '0;
        // APB_READ_DATA_OUT<= '0;
        // PSLVERR          <= '0;
        // PREADY           <= '0;
        PRDATA           <= '0;
        PENABLE          <= '0;
        PWRITE           <= '0;
        PSELx            <= '0;
        PSTRB            <= '0;
        PADDR            <= '0;
        PWDATA           <= '0;
        disable master_write_transfer;
        disable master_read_transfer;
endtask

task apb_slave_reset();
        @(negedge PRESETn);
        // PSLVERR          <= '0;
        // PREADY           <= '0;
        // PRDATA           <= '0;
        PENABLE          <= '0;
        PWRITE           <= '0;
        PSELx            <= '0;
        PSTRB            <= '0;
        PADDR            <= '0;
        PWDATA           <= '0;
        disable apb_slave_collector;
endtask 

task master_write_transfer(
        input   bit [31:0]       WRITE_ADDR,
                bit [3:0]        WRITE_STROBES,
                bit [31:0]       WRITE_DATA );
        @(posedge PCLK);
        master_drvstart = 1'b1;
        TRANS              <= 1'b1;
        WRITE              <= 1'b1;
        @(posedge PCLK);
        TRANS              <= 1'b0;
        APB_WRITE_STRB     <= WRITE_STROBES;
        APB_WRITE_PADDR    <= WRITE_ADDR;
        APB_WRITE_DATA     <= WRITE_DATA;
        @(posedge PREADY);
        @(posedge PCLK);
        WRITE              <= 1'b0;
        master_drvstart = 1'b0;
endtask: master_write_transfer

task master_read_transfer(
        input   bit [31:0]       READ_ADDR );
        @(posedge PCLK);
        master_drvstart = 1'b1;
        TRANS              <= 1'b1;
        READ               <= 1'b1;
        @(posedge PCLK);
        TRANS              <= 1'b0;
        APB_READ_PADDR     <= READ_ADDR;
        @(posedge PREADY);
        @(posedge PCLK);
        READ               <= 1'b0;
        master_drvstart = 1'b0;
endtask: master_read_transfer

task apb_master_collector(
        output  bit [31:0]      READ_ADDR,
                bit [31:0]      DATA_READ,
                bit             ERROR_FLAG,
                bit             READ_EN,
                bit             WRITE_EN,
                bit [31:0]      WRITE_ADDR,
                bit [31:0]      WRITE_DATA,
                bit [3:0]       WRITE_STROBES );
        @(posedge PCLK iff (PREADY));
        master_monstart = 1'b1;
        if(READ)        begin
                READ_ADDR       = APB_READ_PADDR;
                DATA_READ       = APB_READ_DATA_OUT;
                READ_EN         = READ;
                ERROR_FLAG      = PSLVERR;
                WRITE_EN        = 0;
                WRITE_STROBES   = 0;
        end
        else if(WRITE)   begin
                WRITE_EN        = WRITE;
                READ_EN         = 0;
                WRITE_ADDR      = APB_WRITE_PADDR;
                WRITE_DATA      = APB_WRITE_DATA;
                WRITE_STROBES   = APB_WRITE_STRB;
                ERROR_FLAG      = PSLVERR;
        end
        @(posedge PCLK);
        master_monstart = 1'b0;

endtask: apb_master_collector

task slave_transfer(
        input   bit              SELx,
                bit              WRITE_EN,
                bit [31:0]       ADDR,
                bit [3:0]        STROBES,
                bit [31:0]       DATA_WRITE
);
        @(posedge PCLK);
        PSELx   <= SELx;
        PWRITE  <= WRITE_EN;
        PADDR   <= ADDR;
        PWDATA  <= DATA_WRITE;
        @(posedge PCLK);
        PENABLE <= 1'b1;
        @(posedge PREADY);
        PSELx   <= 0;
        PWRITE  <= '0;
        PENABLE <= '0;
        PSTRB   <= '0;

endtask: slave_transfer

task apb_slave_collector(
        output  bit             WRITE_EN,
                bit [3:0]       WRITE_STROBES,
                bit [1:0]       SELx,
                bit [31:0]      DATA_WRITE,
                bit [31:0]      ADDR,
                bit [31:0]      DATA_OUT
);
        @(posedge PCLK iff (PREADY));
        slave_monstart = 1'b1;
        SELx          = tb_apb_top.uut.PSELx;
        WRITE_EN      = tb_apb_top.uut.PWRITE;
        ADDR          = tb_apb_top.uut.PADDR;
        WRITE_STROBES = tb_apb_top.uut.PSTRB;
        DATA_WRITE    = tb_apb_top.uut.PWDATA;
        // Nếu là đọc thì lấy dữ liệu từ PRDATA
        if (!WRITE_EN) begin
                DATA_OUT = tb_apb_top.uut.PRDATA_bus;
                $display("[%0t][SLAVE-CONNECTOR][READ] ADDR=0x%0h SELx=%02b DATA_OUT=0x%0h",
                        $time, ADDR, SELx, DATA_OUT);
        end
        else begin
                $display("[%0t][SLAVE-CONNECTOR][WRITE] ADDR=0x%0h SELx=%02b DATA_WRITE=0x%0h",
                        $time, ADDR, SELx, DATA_WRITE);
        end
        @(posedge PCLK);
        slave_monstart = 1'b0;

endtask: apb_slave_collector

        
endinterface: apb_if 