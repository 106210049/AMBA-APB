module tb_apb_top;
// import the UVM library
import uvm_pkg::*;
import apb_pkg::*;
// include the UVM macros
`include "uvm_macros.svh"
`include "../sv/apb_scoreboard.sv"
`include "../sv/apb_checker.sv"
`include "apb_tb.sv"
`include "apb_test_lib.sv"

logic PCLK, PRESETn;

initial PCLK = 1'b0;
initial PRESETn = 1'b1;
always #5 PCLK = ~PCLK;

initial begin
    @(posedge PCLK);
    PRESETn = 1'b0;
    repeat(2)@(posedge PCLK);
    PRESETn = 1'b1;
end

apb_if apb_if0 (PCLK, PRESETn);

APB_Top uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .TRANS(apb_if0.TRANS),
        .READ(apb_if0.READ),
        .WRITE(apb_if0.WRITE),
        .APB_WRITE_STRB(apb_if0.APB_WRITE_STRB),
        .APB_WRITE_PADDR(apb_if0.APB_WRITE_PADDR),
        .APB_WRITE_DATA(apb_if0.APB_WRITE_DATA),
        .APB_READ_PADDR(apb_if0.APB_READ_PADDR),
        .APB_READ_DATA_OUT(apb_if0.APB_READ_DATA_OUT),
        .PREADY(apb_if0.PREADY),
        .PSLVERR(apb_if0.PSLVERR)
);

    // UVM run
    initial begin
        // cấu hình virtual interface cho agent
        apb_master_vif_config::set(null, "*.tb.master_env.agent.*", "vif", apb_if0);
        apb_slave_vif_config::set(null, "*.tb.slave_env.agent.*", "vif", apb_if0);
        run_test();
    end
    apb_checker apb_chk(apb_if0);
endmodule