// ============================================
// scoreboard.sv
// ============================================

class scoreboard;

  //------------------------------------------
  // Configuration
  //------------------------------------------
  localparam int MEM_DEPTH = 1024;

  //------------------------------------------
  // Communication
  //------------------------------------------
  mailbox mon_to_sb;
  transaction tr;

  //------------------------------------------
  // Reference Memories
  //------------------------------------------
  localparam int BUS_WIDTH = 32;
  bit [BUS_WIDTH-1:0] ref_mem_s0[*];
  bit [BUS_WIDTH-1:0] ref_mem_s1[*];

  //------------------------------------------
  // Statistics
  //------------------------------------------
  int total;
  int n_wr;
  int n_rd;
  int n_err;

  //------------------------------------------
  // Constructor
  //------------------------------------------
  function new(mailbox mon_to_sb);

    this.mon_to_sb = mon_to_sb;

    total = 0;
    n_wr  = 0;
    n_rd  = 0;
    n_err = 0;

  endfunction

  //------------------------------------------
  // Process Transaction
  //------------------------------------------
  task process_transaction(
    transaction tr
  );

    bit [BUS_WIDTH-1:0] exp_data;
    int unsigned        mem_addr;

    mem_addr = tr.PADDR[30:2];

    total++;

    //----------------------------------------
    // WRITE
    //----------------------------------------
    if (tr.PWRITE) begin

      n_wr++;

      case (tr.PSELx)

        //------------------------------------
        // Slave 0
        //------------------------------------
        2'b01: begin

          if (mem_addr < MEM_DEPTH) begin

            `ifdef STROBES
              `ifdef BIG_EDIAN
                  if (tr.PSTRB[0]) ref_mem_s0[mem_addr][7:0]   = tr.PWDATA[7:0];
                  if (tr.PSTRB[1]) ref_mem_s0[mem_addr][15:8]  = tr.PWDATA[15:8];
                  if (tr.PSTRB[2]) ref_mem_s0[mem_addr][23:16] = tr.PWDATA[23:16];
                  if (tr.PSTRB[3]) ref_mem_s0[mem_addr][31:24] = tr.PWDATA[31:24];
                `else 
                  if (tr.PSTRB[0]) ref_mem_s0[mem_addr][7:0] = tr.PWDATA[31:24];
                  if (tr.PSTRB[1]) ref_mem_s0[mem_addr][15:8] = tr.PWDATA[23:16];
                  if (tr.PSTRB[2]) ref_mem_s0[mem_addr][23:16] = tr.PWDATA[15:8];
                  if (tr.PSTRB[3]) ref_mem_s0[mem_addr][31:24] = tr.PWDATA[7:0];
                `endif
            `else
              `ifdef BIG_EDIAN
                  ref_mem_s0[mem_addr][31:24] = tr.PWDATA[31:24];
                  ref_mem_s0[mem_addr][23:16] = tr.PWDATA[23:16];
                  ref_mem_s0[mem_addr][15:8]  = tr.PWDATA[15:8];
                  ref_mem_s0[mem_addr][7:0]   = tr.PWDATA[7:0];
                `else
                  ref_mem_s0[mem_addr][7:0] = tr.PWDATA[31:24];
                  ref_mem_s0[mem_addr][15:8] = tr.PWDATA[23:16];
                  ref_mem_s0[mem_addr][23:16] = tr.PWDATA[15:8];
                  ref_mem_s0[mem_addr][31:24] = tr.PWDATA[7:0];
                `endif
            `endif
            // `ifdef STROBES
            //       if (tr.PSTRB[0]) ref_mem_s0[mem_addr][7:0]   = tr.PWDATA[7:0];
            //       if (tr.PSTRB[1]) ref_mem_s0[mem_addr][15:8]  = tr.PWDATA[15:8];
            //       if (tr.PSTRB[2]) ref_mem_s0[mem_addr][23:16] = tr.PWDATA[23:16];
            //       if (tr.PSTRB[3]) ref_mem_s0[mem_addr][31:24] = tr.PWDATA[31:24];
            //   `else
            //      ref_mem_s0[mem_addr] = tr.PWDATA;
            //   `endif
          
            $display(
              "[%0t][SB-WRITE][S0] ADDR=0x%0h IDX=%0d DATA=0x%0h",
              $time,
              tr.PADDR,
              mem_addr,
              tr.PWDATA
            );

          end
          else begin

            $display(
              "[%0t][SB-INFO][S0] IGNORE WRITE ADDR=0x%0h IDX=%0d OUT-OF-RANGE",
              $time,
              tr.PADDR,
              mem_addr
            );

          end

        end

        //------------------------------------
        // Slave 1
        //------------------------------------
        2'b10: begin

          if (mem_addr < MEM_DEPTH) begin

            `ifdef STROBES
              `ifdef BIG_EDIAN
                  if (tr.PSTRB[0]) ref_mem_s1[mem_addr][7:0]   = tr.PWDATA[7:0];
                  if (tr.PSTRB[1]) ref_mem_s1[mem_addr][15:8]  = tr.PWDATA[15:8];
                  if (tr.PSTRB[2]) ref_mem_s1[mem_addr][23:16] = tr.PWDATA[23:16];
                  if (tr.PSTRB[3]) ref_mem_s1[mem_addr][31:24] = tr.PWDATA[31:24];
                `else 
                  if (tr.PSTRB[0]) ref_mem_s1[mem_addr][7:0]   = tr.PWDATA[31:24];
                  if (tr.PSTRB[1]) ref_mem_s1[mem_addr][15:8]  = tr.PWDATA[23:16];
                  if (tr.PSTRB[2]) ref_mem_s1[mem_addr][23:16] = tr.PWDATA[15:8];
                  if (tr.PSTRB[3]) ref_mem_s1[mem_addr][31:24] = tr.PWDATA[7:0];
                `endif
            `else
              `ifdef BIG_EDIAN
                  ref_mem_s1[mem_addr][31:24] = tr.PWDATA[31:24];
                  ref_mem_s1[mem_addr][23:16] = tr.PWDATA[23:16];
                  ref_mem_s1[mem_addr][15:8]  = tr.PWDATA[15:8];
                  ref_mem_s1[mem_addr][7:0]   = tr.PWDATA[7:0];
                `else
                  ref_mem_s1[mem_addr][7:0] = tr.PWDATA[31:24];
                  ref_mem_s1[mem_addr][15:8] = tr.PWDATA[23:16];
                  ref_mem_s1[mem_addr][23:16] = tr.PWDATA[15:8];
                  ref_mem_s1[mem_addr][31:24] = tr.PWDATA[7:0];
                `endif
            `endif
            // `ifdef STROBES
            //       if (tr.PSTRB[0]) ref_mem_s1[mem_addr][7:0]   = tr.PWDATA[7:0];
            //       if (tr.PSTRB[1]) ref_mem_s1[mem_addr][15:8]  = tr.PWDATA[15:8];
            //       if (tr.PSTRB[2]) ref_mem_s1[mem_addr][23:16] = tr.PWDATA[23:16];
            //       if (tr.PSTRB[3]) ref_mem_s1[mem_addr][31:24] = tr.PWDATA[31:24];
            //   `else
            //      ref_mem_s1[mem_addr] = tr.PWDATA;
            //   `endif

            $display(
              "[%0t][SB-WRITE][S1] ADDR=0x%0h IDX=%0d DATA=0x%0h",
              $time,
              tr.PADDR,
              mem_addr,
              tr.PWDATA
            );

          end
          else begin

            $display(
              "[%0t][SB-INFO][S1] IGNORE WRITE ADDR=0x%0h IDX=%0d OUT-OF-RANGE",
              $time,
              tr.PADDR,
              mem_addr
            );

          end

        end

        //------------------------------------
        // Invalid PSEL
        //------------------------------------
        default: begin

          $warning(
            "[%0t][SB] Invalid PSELx=%b on WRITE",
            $time,
            tr.PSELx
          );

        end

      endcase

    end

    //----------------------------------------
    // READ
    //----------------------------------------
    else begin

      n_rd++;

      case (tr.PSELx)

        //------------------------------------
        // Slave 0
        //------------------------------------
        2'b01: begin

          if (mem_addr >= MEM_DEPTH) begin

            exp_data = '0;

          end
          else if (ref_mem_s0.exists(mem_addr)) begin

            exp_data = ref_mem_s0[mem_addr];

          end
          else begin

            exp_data = '0;

          end

        end

        //------------------------------------
        // Slave 1
        //------------------------------------
        2'b10: begin

          if (mem_addr >= MEM_DEPTH) begin

            exp_data = '0;

          end
          else if (ref_mem_s1.exists(mem_addr)) begin

            exp_data = ref_mem_s1[mem_addr];

          end
          else begin

            exp_data = '0;

          end

        end

        //------------------------------------
        // Invalid PSEL
        //------------------------------------
        default: begin

          exp_data = '0;

          $warning(
            "[%0t][SB] Invalid PSELx=%b on READ",
            $time,
            tr.PSELx
          );

        end

      endcase

      //--------------------------------------
      // Compare
      //--------------------------------------
      if (tr.PRDATA === exp_data) begin

        $display(
          "[%0t][SB-PASS] PSELx=%02b ADDR=0x%0h IDX=%0d EXP=0x%0h ACT=0x%0h",
          $time,
          tr.PSELx,
          tr.PADDR,
          mem_addr,
          exp_data,
          tr.PRDATA
        );

      end
      else begin

        n_err++;

        $error(
          "[%0t][SB-FAIL] PSELx=%02b ADDR=0x%0h IDX=%0d EXP=0x%0h ACT=0x%0h",
          $time,
          tr.PSELx,
          tr.PADDR,
          mem_addr,
          exp_data,
          tr.PRDATA
        );

      end

    end

  endtask

  //------------------------------------------
  // Main Loop
  //------------------------------------------
  task run();

    forever begin

      mon_to_sb.get(tr);

      process_transaction(tr);

    end

  endtask

  //------------------------------------------
  // Report
  //------------------------------------------
  function void report();

    $display("");
    $display("=============== SCOREBOARD SUMMARY ===============");
    $display(" Transactions : %0d", total);
    $display(" Writes       : %0d", n_wr);
    $display(" Reads        : %0d", n_rd);
    $display(" Errors       : %0d", n_err);

    if (total > 0)
      $display(
        " Pass Rate    : %0.2f%%",
        100.0 * (total - n_err) / total
      );

    $display(
      " RESULT       : %s",
      (n_err == 0) ? "PASS ✅" : "FAIL ❌"
    );
    tr.display_coverage();
    $display("==================================================");
    $display("");

  endfunction

endclass