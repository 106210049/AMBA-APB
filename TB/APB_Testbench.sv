`timescale 1ns/1ps

module APB_Top_tb;

    // Input signals
    reg         PCLK;
    reg         PRESETn;
    reg         TRANS;
    reg         READ;
    reg         WRITE;
    reg [31:0]  APB_WRITE_PADDR;
    reg [31:0]  APB_WRITE_DATA;
    reg [3:0]   APB_WRITE_STRB;   // NEW
    reg [31:0]  APB_READ_PADDR;

    // Output signals
    wire [31:0] APB_READ_DATA_OUT;
    wire        PSLVERR;

    // UUT
    APB_Top uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .TRANS(TRANS),
        .READ(READ),
        .WRITE(WRITE),
        .APB_WRITE_STRB(APB_WRITE_STRB),   // NEW
        .APB_WRITE_PADDR(APB_WRITE_PADDR),
        .APB_WRITE_DATA(APB_WRITE_DATA),
        .APB_READ_PADDR(APB_READ_PADDR),
        .APB_READ_DATA_OUT(APB_READ_DATA_OUT),
        .PSLVERR(PSLVERR)
    );

    // Clock
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    // Task: Write
    task apb_write(input [31:0] addr, input [31:0] data, input [3:0] strb);
    begin
        @(posedge PCLK);
        TRANS = 1;
        WRITE = 1;
        READ  = 0;
        APB_WRITE_PADDR = addr;
        APB_WRITE_DATA  = data;
        APB_WRITE_STRB  = strb;
        @(posedge PCLK);
        TRANS = 0;

        wait(uut.master_inst.current_state == 2'b10);
        @(posedge PCLK);

        while (!uut.PREADY_bus) begin
            $display("  [WAITING] Slave not ready @%0t", $time);
            @(posedge PCLK);
        end

        $display("[WRITE] Addr=0x%h | Data=0x%h | STRB=%b | PSLVERR=%b | Time=%0t",
                 addr, data, strb, PSLVERR, $time);
        WRITE = 0;
    end
    endtask

    // Task: Read
    task apb_read(input [31:0] addr);
    begin
        @(posedge PCLK);
        TRANS = 1;
        WRITE = 0;
        READ  = 1;
      	APB_WRITE_STRB = '0;
        APB_READ_PADDR = addr;
        @(posedge PCLK);
        TRANS = 0;

        wait(uut.master_inst.current_state == 2'b10);
        @(posedge PCLK);

        while (!uut.PREADY_bus) begin
            $display("  [WAITING] Slave not ready @%0t", $time);
            @(posedge PCLK);
        end

        $display("[READ]  Addr=0x%h | Data=0x%h | PSLVERR=%b | Time=%0t",
                 addr, APB_READ_DATA_OUT, PSLVERR, $time);
        READ = 0;
    end
    endtask

    // Testcases
    initial begin
        $dumpfile("dump.vcd"); $dumpvars;

        PRESETn = 0;
        TRANS = 0; READ = 0; WRITE = 0;
        APB_WRITE_PADDR = 0; APB_WRITE_DATA = 0; APB_WRITE_STRB = 0;
        APB_READ_PADDR = 0;

        #20 PRESETn = 1;
        #10;

        $display("--- TC1: Full word write/read ---");
        apb_write(32'h0000_0008, 32'hDEADBEEF, 4'b1111);
        apb_read (32'h0000_0008);

        $display("\n--- TC2: Byte write (LSB only) ---");
      	apb_write(32'h0000_0008, 32'h0000AABB, 4'b0001);
        apb_read (32'h0000_0008);

        $display("\n--- TC3: Half-word write (lower 16-bit) ---");
      	apb_write(32'h0000_0008, 32'h00AA_BBCC, 4'b0011);
        apb_read (32'h0000_0008);

        $display("\n--- TC4: Half-word write (upper 16-bit) ---");
        apb_write(32'h0000_0008, 32'hCCCC_0000, 4'b1100);
        apb_read (32'h0000_0008);

        $display("\n--- TC5: Slave 1 access (MSB=1) ---");
        apb_write(32'h8000_0004, 32'hCAFEBABE, 4'b1111);
        apb_read (32'h8000_0004);

        $display("\n--- TC6: Address out-of-range ---");
        apb_write(32'h0000_5000, 32'hAAAA_BBBB, 4'b1111);
        apb_read (32'h0000_5000);

        $display("\n--- TC7: Wait states ---");
        apb_write(32'h0000_0003, 32'h1111_2222, 4'b1111); // 3-cycle wait
        apb_read (32'h0000_0001);                         // 1-cycle wait

        #100;
        $display("\n--- Simulation Finished ---");
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | State=%b | PSEL=%b | PADDR=%h | PWRITE=%b | PSTRB=%b | PREADY=%b",
                 $time, uut.master_inst.current_state, uut.PSELx, uut.PADDR,
                 uut.PWRITE, uut.PSTRB, uut.PREADY_bus);
    end

endmodule
