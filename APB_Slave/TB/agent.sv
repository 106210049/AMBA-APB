import testcase_pkg::*;

class agent;

    // Virtual interface modports (clocking views)
    virtual apb_if.DRV drv_vif;
    virtual apb_if.MON mon_vif;


    mailbox gen_to_drv;
    mailbox mon_to_sb;

    generator gen;
    driver drv;
    monitor mon;

    function new( virtual apb_if.DRV drv_vif,
                  virtual apb_if.MON mon_vif,
                mailbox mon_to_sb );
    this.drv_vif   = drv_vif;
    this.mon_vif   = mon_vif;
    this.mon_to_sb = mon_to_sb;

    // Create mailbox for generator -> driver
    gen_to_drv = new();

    // Create components
    gen = new(gen_to_drv);
    drv = new(gen_to_drv, this.drv_vif);
    mon = new(this.mon_vif, this.mon_to_sb);

  endfunction

  localparam int BUS_WIDTH = 32;

  function void cfg_gen(
    input int                 num_gen,
    input test_case           tc,
    input bit [BUS_WIDTH-1:0] addr_lo = '0,
    input bit [BUS_WIDTH-1:0] addr_hi = '1
  );
    gen.num_gen     = num_gen;
    gen.test        = tc;
    gen.addr_lo     = addr_lo;
    gen.addr_hi     = addr_hi;
  endfunction

   task run();
    fork
      gen.run();
      drv.run();
      mon.run();
    join_none
  endtask

endclass