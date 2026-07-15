class env;

    agent agt;
    scoreboard scb;

    mailbox mon_to_sb;

    function new(
        virtual apb_if.DRV drv_vif,
        virtual apb_if.MON mon_vif
    );
        // Shared mailbox (Monitor -> Scoreboard)
        mon_to_sb = new();

        // Agent: contains generator/driver/monitor
        agt = new(drv_vif, mon_vif, mon_to_sb);

        // Scoreboard: consumes monitor transactions
        scb = new(mon_to_sb);
  endfunction

  // -----------------------------
  // Run
  // -----------------------------
  task run();
    fork
      agt.run();
      scb.run();
    join_none
  endtask

  // -----------------------------
  // Optional: Summary hook
  // Call at end of sim
  // -----------------------------
  task report();
    scb.report();
  endtask
endclass