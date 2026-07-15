`timescale 1ns/1ns
`default_nettype none
`define RAND_ADDR_INRANGE // TODO: Change test here

`include "interface.sv"
`include "transaction.sv"
`include "testcase_pkg.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "env.sv"
`include "checker.sv"
`include "test.sv"

import testcase_pkg::*;
module apb_tb_top;
localparam int BUS_WIDTH = 32;

bit PCLK;
bit PRESETn;

initial PCLK = 0;
always #5 PCLK = ~PCLK;

// Reset sequence
  initial begin
    PRESETn = 1'b0;                 // assert reset
    repeat (20) @(posedge PCLK);
    PRESETn = 1'b1;                 // deassert reset
  end

  initial begin
    $dumpfile("apb_wave.vcd");
    $dumpvars(0, apb_tb_top);
  end
  apb_if #(.BUS_WIDTH(BUS_WIDTH)) vif (
    .PCLK(PCLK),
    .PRESETn(PRESETn)
  );
  APB_Slave_TOP slave_top_inst (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),
        .PENABLE  (vif.PENABLE),    // <-- NỐI VÀO ĐÂY
        .PWRITE   (vif.PWRITE),
        .PSELx    (vif.PSELx),
        .PADDR    (vif.PADDR),
        .PWDATA   (vif.PWDATA),
        .PRDATA   (vif.PRDATA),
        .PREADY   (vif.PREADY),
        .PSLVERR  (vif.PSLVERR)
    );

    apb_test t1(vif);
    apb_checker chk(vif);

endmodule