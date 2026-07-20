// `include "transaction.sv"

import testcase_pkg::*;

class generator;
  localparam int BUS_WIDTH = 32;

  mailbox gen_to_drv;
  integer num_gen;
  test_case test;

  bit [BUS_WIDTH-1:0] addr_lo;
  bit [BUS_WIDTH-1:0] addr_hi;

  transaction tr;
  function new(mailbox gen_to_drv);
    this.gen_to_drv = gen_to_drv;
  endfunction

  task fixed_addr;
    repeat(num_gen)  begin
      tr = new();
      assert(tr.randomize() with {
          PWRITE dist {0:=50, 1:=50};
          `ifdef STROBES
            PSTRB inside {[4'b0000: 4'b1111]};
          `endif
      }) else $fatal("[GEN] randomize failed (rand_addr)");
      tr.PWDATA = tr.PWRITE ? $urandom_range(0, 256) : '0;
      tr.PADDR = 32'h0000_0004;
      tr.PSELx = 2'b01;
      tr.display();
      gen_to_drv.put(tr);
    end
  endtask

  task rand_addr;
    repeat(num_gen)  begin
      tr = new();
      assert(tr.randomize() with {
          PWRITE dist {0:=50, 1:=50};
          PADDR inside {[addr_lo : addr_hi]};
          PSELx inside {2'b01, 2'b10};
          `ifdef STROBES
            PSTRB inside {[4'b0000: 4'b1111]};
          `endif
      }) else $fatal("[GEN] randomize failed (rand_addr)");
      tr.PWDATA = tr.PWRITE ? $urandom_range(0, 256) : '0;
      tr.display();
      gen_to_drv.put(tr);
    end
  endtask

  task rand_addr_in_range;
    repeat(num_gen)  begin
      tr = new();
      assert(tr.randomize() with {
          PWRITE dist {0:=50, 1:=50};
          PADDR inside {32'h0000_0004, 32'h8000_0004, 32'h0000_0008, 32'h0000_0010, 32'h8000_0020};
          PSELx inside {2'b01, 2'b10};
          `ifdef STROBES
            PSTRB inside {[4'b0000: 4'b1111]};
          `endif
      }) else $fatal("[GEN] randomize failed (rand_addr)");
      tr.PWDATA = tr.PWRITE ? $urandom_range(0, 256) : '0;
      tr.display();
      gen_to_drv.put(tr);
    end
  endtask

  task error_resp;
    repeat(num_gen)  begin
      tr = new();
      assert(tr.randomize() with {
          PWRITE dist {0:=50, 1:=50};
          PADDR inside { 32'h0000_5000, 32'h8000_5000};
          PSELx inside {2'b01, 2'b10};
          `ifdef STROBES
            PSTRB inside {[4'b0000: 4'b1111]};
          `endif
      }) else $fatal("[GEN] randomize failed (rand_addr)");
      tr.PWDATA = tr.PWRITE ? $urandom_range(0, 256) : '0;
      // tr.PADDR = 32'h0000_5000;
      // tr.PSELx = 2'b01;
      tr.display();
      gen_to_drv.put(tr);
    end
  endtask

  task waiting_state;
    repeat(num_gen)  begin
      tr = new();
      assert(tr.randomize() with {
          PWRITE dist {0:=50, 1:=50};
          PADDR inside { 32'h0000_0001, 32'h0000_0002, 32'h0000_0006, 32'h8000_0001, 32'h8000_0002, 32'h8000_0006 };
          PSELx inside {2'b01, 2'b10};
          `ifdef STROBES
            PSTRB inside {[4'b0000: 4'b1111]};
          `endif
      }) else $fatal("[GEN] randomize failed (rand_addr)");
      // tr.PWRITE = 1;
      tr.PWDATA = tr.PWRITE ? $urandom_range(0, 256) : '0;
      // tr.PADDR = 32'h0000_0006;
      // tr.PSELx = 2'b01;
      tr.display();
      gen_to_drv.put(tr);
    end
  endtask

  task test_slave_1;
    repeat(num_gen)  begin
      tr = new();
      assert(tr.randomize() with {
          PWRITE dist {0:=50, 1:=50};
          `ifdef STROBES
            PSTRB inside {[4'b0000: 4'b1111]};
          `endif
      }) else $fatal("[GEN] randomize failed (rand_addr)");
      tr.PWDATA = tr.PWRITE ? $urandom_range(0, 256) : '0;
      tr.PADDR = 32'h8000_0014;
      tr.PSELx = 2'b10;
      tr.display();
      gen_to_drv.put(tr);
    end
  endtask

  task run;
      case (test)
        SLAVE_0,
        FIXED_ADDR:          fixed_addr();
        RAND_ADDR:           rand_addr();
        RAND_ADDR_INRANGE:   rand_addr_in_range();
        SLAVE_1:             test_slave_1();
        ERROR_RESP:          error_resp();
        WAITING_STATE:       waiting_state();
        default:             $fatal("[GEN] Unknown test case");
      endcase
  endtask

endclass