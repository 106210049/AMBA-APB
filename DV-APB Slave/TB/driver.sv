class driver;

  localparam int TIMEOUT_CYCLES = 1000;

  mailbox gen_to_drv;
  virtual apb_if.DRV    vif;
  transaction          tr;

  function new(mailbox gen_to_drv,
               virtual apb_if.DRV vif);
    this.gen_to_drv = gen_to_drv;
    this.vif        = vif;
  endfunction

  task reset_bus();
    @(vif.cb_drv);
    vif.cb_drv.PSELx   <= 2'b00;
    vif.cb_drv.PENABLE <= 1'b0;
    vif.cb_drv.PWRITE  <= 1'b0;
    vif.cb_drv.PADDR   <= '0;
    vif.cb_drv.PWDATA  <= '0;
  endtask

  task reset_phase();
    reset_bus();
    do @(vif.cb_drv); while (vif.cb_drv.PRESETn == 1'b0);
    reset_bus();
  endtask

  task setup_phase(input transaction t);
    @(vif.cb_drv);
    while (vif.cb_drv.PRESETn == 1'b0) @(vif.cb_drv);

    vif.cb_drv.PSELx   <= t.PSELx;
    vif.cb_drv.PENABLE <= 1'b0;
    vif.cb_drv.PWRITE  <= t.PWRITE;
    vif.cb_drv.PADDR   <= t.PADDR;
    vif.cb_drv.PWDATA  <= t.PWDATA;
  endtask

  task access_phase(inout transaction t);
    int unsigned wait_cnt = 0;

    @(vif.cb_drv);
    vif.cb_drv.PENABLE <= 1'b1;

    while (vif.cb_drv.PREADY == 1'b0) begin
      @(vif.cb_drv);
      wait_cnt++;
      if (wait_cnt > TIMEOUT_CYCLES) begin
        $error("[%0t] APB DRIVER TIMEOUT: PREADY không lên trong %0d chu kỳ (addr=0x%0h, pselx=%b)",
               $time, TIMEOUT_CYCLES, t.PADDR, t.PSELx);
        break;
      end
    end

    if (!t.PWRITE) begin
      t.PRDATA = vif.cb_drv.PRDATA;
    end

    // @(vif.cb_drv);
    vif.cb_drv.PSELx   <= 2'b00;
    vif.cb_drv.PENABLE <= 1'b0;
    vif.cb_drv.PWRITE  <= 1'b0;
  endtask

  task run();
    reset_phase();
    forever begin
      gen_to_drv.get(tr);
      setup_phase(tr);
      access_phase(tr);
      tr.display("DRV");
    end
  endtask

endclass
