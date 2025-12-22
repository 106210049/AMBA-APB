`timescale 1ns/1ps

module APB_Top_tb;

    // Input signals (reg)
    reg         PCLK;
    reg         PRESETn;
    reg         TRANS;
    reg         READ;
    reg         WRITE;
    reg [31:0]  APB_WRITE_PADDR;
    reg [31:0]  APB_WRITE_DATA;
    reg [31:0]  APB_READ_PADDR;

    // Output signals (wire)
    wire [31:0] APB_READ_DATA_OUT;
    wire        PSLVERR;

    // Unit Under Test (UUT)
    APB_Top uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .TRANS(TRANS),
        .READ(READ),
        .WRITE(WRITE),
        .APB_WRITE_PADDR(APB_WRITE_PADDR),
        .APB_WRITE_DATA(APB_WRITE_DATA),
        .APB_READ_PADDR(APB_READ_PADDR),
        .APB_READ_DATA_OUT(APB_READ_DATA_OUT),
        .PSLVERR(PSLVERR)
    );

    // Clock generation (10ns period -> 100MHz)
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    // Task for APB Write Transaction
    task apb_write(input [31:0] addr, input [31:0] data);
    begin
        @(posedge PCLK);
        TRANS = 1;
        WRITE = 1;
        READ  = 0;
        APB_WRITE_PADDR = addr;
        APB_WRITE_DATA  = data;
        
        @(posedge PCLK); 
        TRANS = 0;       
        
        wait(uut.master_inst.current_state == 2'b10); 
        @(posedge PCLK);
        
        // Vòng lặp chờ PREADY (Xử lý Waiting States)
        while (!uut.PREADY_bus) begin
            $display("  [WAITING] Slave is not ready at Time=%0t", $time);
            @(posedge PCLK);
        end
        
        $display("[WRITE] Addr: 0x%h | Data: 0x%h | PSLVERR: %b | Time: %0t", addr, data, PSLVERR, $time);
        WRITE = 0;
    end
    endtask

    // Task for APB Read Transaction
    task apb_read(input [31:0] addr);
    begin
        @(posedge PCLK);
        TRANS = 1;
        WRITE = 0;
        READ  = 1;
        APB_READ_PADDR = addr;

        @(posedge PCLK);
        TRANS = 0;

        wait(uut.master_inst.current_state == 2'b10);
        @(posedge PCLK);
        
        while (!uut.PREADY_bus) begin
            $display("  [WAITING] Slave is not ready at Time=%0t", $time);
            @(posedge PCLK);
        end

        $display("[READ]  Addr: 0x%h | Data: 0x%h | PSLVERR: %b | Time: %0t", addr, APB_READ_DATA_OUT, PSLVERR, $time);
        READ = 0;
    end
    endtask

    // Test Scenarios
    initial begin
        $dumpfile("dump.vcd"); $dumpvars;
        
        // Initialize signals
        PRESETn = 0;
        TRANS = 0;
        READ = 0;
        WRITE = 0;
        APB_WRITE_PADDR = 0;
        APB_WRITE_DATA = 0;
        APB_READ_PADDR = 0;

        // Release Reset
        #20 PRESETn = 1;
        #10;

        $display("--- Starting Testcase 1: Slave 0 Access (MSB=0) ---");
        apb_write(32'h0000_0008, 32'hDEADBEEF); // Addr 8 (Wait=0)
        apb_read(32'h0000_0008);                

        $display("\n--- Starting Testcase 2: Slave 1 Access (MSB=1) ---");
        apb_write(32'h8000_0004, 32'hCAFEBABE); // Addr 4 (Wait=0)
        apb_read(32'h8000_0004);                

        $display("\n--- Starting Testcase 3: Address Range Error ---");
        apb_write(32'h0000_0500, 32'h12345678); 
        apb_read(32'h0000_0500);

        $display("\n--- Starting Testcase 4: Dynamic Waiting States (PADDR[1:0]) ---");
        // Test trễ 3 chu kỳ (Địa chỉ kết thúc bằng 11)
        $display("Testing 3-cycle wait state:");
        apb_write(32'h0000_0003, 32'hAAAA_BBBB);
        
        // Test trễ 1 chu kỳ (Địa chỉ kết thúc bằng 01)
        $display("Testing 1-cycle wait state:");
        apb_read(32'h0000_0001);

        #100;
        $display("\n--- Simulation Finished ---");
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%0t | State=%b | PSEL=%b | PADDR=%h | PWRITE=%b | PREADY=%b", 
                 $time, uut.master_inst.current_state, uut.PSELx, uut.PADDR, uut.PWRITE, uut.PREADY_bus);
    end

endmodule