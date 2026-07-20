class transaction #(
  parameter int BUS_WIDTH = 32
);

  rand bit                  PWRITE;
  rand bit [BUS_WIDTH-1:0]  PADDR;
  rand bit [BUS_WIDTH-1:0]  PWDATA;
  rand bit [1:0]            PSELx;

  `ifdef STROBES
  rand bit [3:0]            PSTRB;
  `endif
       bit [BUS_WIDTH-1:0]  PRDATA;

  // PSELx phụ thuộc MSB của PADDR:
  //   MSB=0 => PSELx=01, MSB=1 => PSELx=10
  covergroup cov_slv_apb;
    cp_paddr: coverpoint PADDR {
      bins fixed_addr         = {32'h0000_0004};
      bins rand_addr_in_range = {32'h0000_0004,
                                32'h8000_0004,
                                32'h0000_0008,
                                32'h0000_0020,
                                32'h8000_0010};
      bins addr_error  = {32'h0000_5000, 32'h8000_5000};
      bins addr_slave1 = {32'h8000_0014};
      bins waiting_addr_slv0 = { 32'h0000_0001, 32'h0000_0002, 32'h0000_0006 };
      bins waiting_addr_slv1 = { 32'h8000_0001, 32'h8000_0002, 32'h8000_0006 };
    }
    cp_pselx: coverpoint PSELx {
      bins slave_0 = {2'b01};
      bins slave_1 = {2'b10};
    }

    cross_paddr_pselx : cross cp_paddr, cp_pselx {

    bins addr_slv0 = binsof(cp_paddr.fixed_addr) && binsof(cp_pselx.slave_0);

    bins addr_slv1 = binsof(cp_paddr.addr_slave1) && binsof(cp_pselx.slave_1);

    bins waiting_slv0 = binsof(cp_paddr.waiting_addr_slv0) && binsof(cp_pselx.slave_0);

    bins waiting_slv1 = binsof(cp_paddr.waiting_addr_slv1) && binsof(cp_pselx.slave_1);

    ignore_bins false_addr_slv0 =
        binsof(cp_paddr.fixed_addr) &&
        binsof(cp_pselx.slave_1) || 
        binsof(cp_paddr.waiting_addr_slv0) &&
        binsof(cp_pselx.slave_1);

    ignore_bins false_addr_slv1 =
        binsof(cp_paddr.addr_slave1) &&
        binsof(cp_pselx.slave_0) ||
        binsof(cp_paddr.waiting_addr_slv1) &&
        binsof(cp_pselx.slave_0);

    ignore_bins error_addr0 = binsof(cp_paddr.addr_error) && binsof(cp_pselx.slave_0);

    ignore_bins error_addr1 = binsof(cp_paddr.addr_error) && binsof(cp_pselx.slave_1);
  }
  endgroup
  
  covergroup cov_pwrite;
    cp_pwrite: coverpoint PWRITE{
      bins write = {1'b1};
      bins read = {1'b0};
    }
  endgroup

  `ifdef STROBES
   covergroup cov_strobes;
    cp_pstrb: coverpoint PSTRB {
      bins be_none = {4'b0000};
      bins be_byte0 = {[4'b0001:4'b1110]}; // ví dụ
      bins be_full = {4'b1111};
    }
  endgroup
  `endif

  // trong transaction class

  constraint c_psel_depends_on_addr_msb {
    PSELx == (PADDR[BUS_WIDTH-1] ? 2'b10 : 2'b01);
  }

   // ensure PSTRB valid: if read then PSTRB == 0, if write then at least one bit set
  `ifdef STROBES
    constraint c_pstrb_valid {
      (!PWRITE) -> (PSTRB == 4'b0000);
      (PWRITE)  -> (PSTRB != 4'b0000);
    }
  `endif
  function new(); 
    cov_slv_apb = new();
    cov_pwrite = new();
    `ifdef STROBES
    cov_strobes = new();
    `endif
  endfunction

  function void display(string tag = "TRANS");
    `ifdef STROBES
    $display("[%0t] %s | %s | PSELx=%b | PSTRB=%b |PADDR=0x%0h | PWDATA=0x%0h | PRDATA=0x%0h",
             $time, tag, (PWRITE ? "WRITE" : "READ "),
             PSELx, PSTRB, PADDR, PWDATA, PRDATA);
    `else
    $display("[%0t] %s | %s | PSELx=%b |PADDR=0x%0h | PWDATA=0x%0h | PRDATA=0x%0h",
             $time, tag, (PWRITE ? "WRITE" : "READ "),
             PSELx, PADDR, PWDATA, PRDATA);
    `endif
  endfunction

  function void sample_coverage();
    if (cov_slv_apb != null) cov_slv_apb.sample();
    if (cov_pwrite  != null) cov_pwrite.sample();
    `ifdef STROBES
    if (cov_strobes != null) cov_strobes.sample();
    `endif
  endfunction

  function void display_coverage();
    if (cov_slv_apb != null) $display("Coverage APB with ADDR and SELx = %0.2f %%", cov_slv_apb.get_coverage());
    if (cov_pwrite  != null) $display("Coverage APB with WRITE/READ = %0.2f %%", cov_pwrite.get_coverage());
    `ifdef STROBES
    if (cov_strobes != null) $display("Coverage PSTRB = %0.2f %%", cov_strobes.get_coverage());
    `endif
  endfunction
endclass