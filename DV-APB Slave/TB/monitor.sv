// ============================================
// monitor.sv
// ============================================
class monitor;

  virtual apb_if.MON vif;

  mailbox mon_to_sb;

  function new(
    virtual apb_if.MON vif,
    mailbox mon_to_sb = null
  );
    this.vif       = vif;
    this.mon_to_sb = mon_to_sb;
  endfunction

  // ------------------------------------------
  // Reset check
  // ------------------------------------------
  function bit reset_active();
    return (vif.cb_mon.PRESETn === 1'b0);
  endfunction

  // ------------------------------------------
  // Capture SETUP phase
  // ------------------------------------------
  task setup_phase(
    ref transaction tr
  );

    tr.PWRITE = vif.cb_mon.PWRITE;
    tr.PADDR  = vif.cb_mon.PADDR;
    tr.PSELx  = vif.cb_mon.PSELx;
    tr.sample_coverage();
    $display(
      "[%0t][MON-SETUP] PADDR=0x%0h W=%0b PSELx=%02b",
      $time,
      tr.PADDR,
      tr.PWRITE,
      tr.PSELx
    );

  endtask

  // ------------------------------------------
  // Wait ACCESS complete
  // ------------------------------------------
  task wait_access_complete();

    do begin
      @(vif.cb_mon);
    end
    while (!(vif.cb_mon.PSELx   != 0 &&
             vif.cb_mon.PENABLE == 1'b1 &&
             vif.cb_mon.PREADY  == 1'b1));

  endtask

  // ------------------------------------------
  // Capture ACCESS phase
  // ------------------------------------------
  task access_phase(
    ref transaction tr
  );

    if (tr.PWRITE) begin

      tr.PWDATA = vif.cb_mon.PWDATA;

      $display(
        "[%0t][WRITE][MON-ACCESS] PADDR=0x%0h PSELx=%02b PWDATA=0x%0h",
        $time,
        tr.PADDR,
        tr.PSELx,
        tr.PWDATA
      );

    end
    else begin

      tr.PRDATA = vif.cb_mon.PRDATA;

      $display(
        "[%0t][READ][MON-ACCESS] PADDR=0x%0h PSELx=%02b PRDATA=0x%0h",
        $time,
        tr.PADDR,
        tr.PSELx,
        tr.PRDATA
      );

    end

    if (mon_to_sb != null)
      mon_to_sb.put(tr);

  endtask

  // ------------------------------------------
  // Main monitor loop
  // ------------------------------------------
  task run();

    transaction tr;

    forever begin

      @(vif.cb_mon);

      if (reset_active())
        continue;

      // APB SETUP phase
      if ((vif.cb_mon.PSELx != 0) &&
          (vif.cb_mon.PENABLE == 1'b0))
      begin

        tr = new();

        setup_phase(tr);

        // Wait until access phase completed
        wait_access_complete();

        access_phase(tr);

      end

    end

  endtask

endclass