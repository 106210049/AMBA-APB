class transaction;

  localparam int BUS_WIDTH = 32;

  rand bit                  PWRITE;
  rand bit [BUS_WIDTH-1:0]  PADDR;
  rand bit [BUS_WIDTH-1:0]  PWDATA;
  rand bit [1:0]            PSELx;

       bit [BUS_WIDTH-1:0]  PRDATA;

  // PSELx phụ thuộc MSB của PADDR:
  //   MSB=0 => PSELx=01, MSB=1 => PSELx=10
  covergroup cov_slv_apb;
    cp_paddr: coverpoint PADDR {
      bins fixed_addr         = {32'h0000_0004};
      bins rand_addr_in_range = {32'h0000_0006,
                                32'h8000_0003,
                                32'h0000_0001,
                                32'h0000_0004,
                                32'h8000_0004};
      bins addr_error  = {32'h0000_5000};
      bins addr_slave0 = {32'h0000_0004};
      bins addr_slave1 = {32'h8000_0004};
    }

    cp_pselx: coverpoint PSELx {
      bins slave_0 = {2'b01};
      bins slave_1 = {2'b10};
    }

    cross_paddr_pselx : cross cp_paddr, cp_pselx {

    bins addr_slv0 =
        binsof(cp_paddr.addr_slave0) &&
        binsof(cp_pselx.slave_0);

    bins addr_slv1 =
        binsof(cp_paddr.addr_slave1) &&
        binsof(cp_pselx.slave_1);

    ignore_bins false_addr_slv0 =
        binsof(cp_paddr.addr_slave0) &&
        binsof(cp_pselx.slave_1);

    ignore_bins false_addr_slv1 =
        binsof(cp_paddr.addr_slave1) &&
        binsof(cp_pselx.slave_0);

    ignore_bins error_addr0 =
        binsof(cp_paddr.addr_error) &&
        binsof(cp_pselx.slave_0);

    ignore_bins error_addr1 =
        binsof(cp_paddr.addr_error) &&
        binsof(cp_pselx.slave_1);
  }
  endgroup
  
  covergroup cov_pwrite;
    cp_pwrite: coverpoint PWRITE{
      bins write = {1'b1};
      bins read = {1'b0};
    }
  endgroup

  constraint c_psel_depends_on_addr_msb {
    PSELx == (PADDR[BUS_WIDTH-1] ? 2'b10 : 2'b01);
  }
  function new(); 
    cov_slv_apb = new();
    cov_pwrite = new();
  endfunction

  function void display(string tag = "TRANS");
    $display("[%0t] %s | %s | PSELx=%b | PADDR=0x%0h | PWDATA=0x%0h | PRDATA=0x%0h",
             $time, tag, (PWRITE ? "WRITE" : "READ "),
             PSELx, PADDR, PWDATA, PRDATA);
  endfunction

  function void sample_coverage();
    if(cov_slv_apb != null && cov_pwrite != null) begin
        cov_slv_apb.sample();
        cov_pwrite.sample();
    end
  endfunction
  
  function void display_coverage();
    $display("Coverage APB with ADDR and SELx = %0.2f %%", cov_slv_apb.get_coverage());
    $display("Coverage APB with WRITE/READ = %0.2f %%", cov_pwrite.get_coverage());
  endfunction
endclass