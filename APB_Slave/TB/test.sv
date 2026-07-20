import testcase_pkg::*;

program apb_test(apb_if vif);

  // -----------------------------
  // Environment
  // -----------------------------
  env env_o;

  // -----------------------------
  // Runtime params
  // -----------------------------
  string testname;
  int    timeout;

  // -----------------------------
  // Main
  // -----------------------------
  initial begin

    //----------------------------------------
    // Default config
    //----------------------------------------
    // `ifdef FIXED_ADDR
    //     testname = "FIXED_ADDR";
    // `elsif RAND_ADDR
    //     testname = "RAND_ADDR";
    // `elsif RAND_ADDR_INRANGE
    //     testname = "RAND_ADDR_INRANGE";
    // `elsif SLAVE_0
    //     testname = "SLAVE_0";
    // `elsif SLAVE_1
    //     testname = "SLAVE_1";
    // `elsif ERROR_RESP
    //     testname = "ERROR_RESP";
    // `elsif WAITING_STATE
    //     testname = "WAITING_STATE";
    // `else
    //     testname = "RAND_ADDR";
    // `endif
    timeout  = 2000;
	// TODO: Uncomment if you want to run VCS tools
    //----------------------------------------
    // Override via plusargs
    //----------------------------------------
    void'($value$plusargs("TESTNAME=%s", testname));
    void'($value$plusargs("TIMEOUT=%d", timeout));

    $display("[TEST] TESTNAME=%s TIMEOUT=%0d", testname, timeout);

    //----------------------------------------
    // Create ENV
    // IMPORTANT: pass correct modports
    //----------------------------------------
    env_o = new(vif.DRV, vif.MON);

    //----------------------------------------
    // Configure TEST
    //----------------------------------------
    case (testname)

      //--------------------------------------------------
      // Address tests
      //--------------------------------------------------
      "FIXED_ADDR":
        env_o.agt.cfg_gen(10, FIXED_ADDR);

      "RAND_ADDR":
        env_o.agt.cfg_gen(30, RAND_ADDR,
                          32'h0000_0000,
                          32'h0000_00FF);

      "RAND_ADDR_INRANGE":
        env_o.agt.cfg_gen(30, RAND_ADDR_INRANGE);

      //--------------------------------------------------
      // Protocol behavior tests
      //--------------------------------------------------
      "SLAVE_0":
        env_o.agt.cfg_gen(30, SLAVE_0);

      "SLAVE_1":
        env_o.agt.cfg_gen(30, SLAVE_1);

      "ERROR_RESP":
        env_o.agt.cfg_gen(10, ERROR_RESP);

      //--------------------------------------------------
      // HSIZE stress test
      //--------------------------------------------------
      "WAITING_STATE":
        env_o.agt.cfg_gen(30, WAITING_STATE);

      //--------------------------------------------------
      default:
        $fatal("[TEST] Unknown TESTNAME=%s", testname);

    endcase

    //----------------------------------------
    // Start ENV
    //----------------------------------------
    env_o.run();

    //----------------------------------------
    // Timeout control
    //----------------------------------------
    #(timeout);

    //----------------------------------------
    // Report + Finish
    //----------------------------------------
    $display("[TEST] TIMEOUT reached");

    env_o.report();

    $finish;

  end

endprogram