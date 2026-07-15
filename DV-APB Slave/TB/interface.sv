interface apb_if #(
  parameter int BUS_WIDTH = 32
)(
  input  bit PCLK,
  input  bit PRESETn
);

  // Master -> Slave
  logic                 PWRITE;
  logic                 PENABLE;
  logic [BUS_WIDTH-1:0] PADDR;
  logic [BUS_WIDTH-1:0] PWDATA;
  logic [1:0]           PSELx;

  // Slave -> Master
  logic [BUS_WIDTH-1:0] PRDATA;
  logic                 PREADY;
  logic                 PSLVERR;

  // Monitor clocking block (sample)
  clocking cb_mon @(posedge PCLK);
    input #1step PRESETn;
    input #1step PWRITE, PENABLE, PADDR, PWDATA, PSELx;
    input #1step PRDATA, PREADY, PSLVERR;
  endclocking

  // Driver clocking block (drive)
  clocking cb_drv @(posedge PCLK);
    input  #1step PRESETn;
    output #0     PWRITE, PENABLE, PADDR, PWDATA, PSELx;
    input  #1step PRDATA, PREADY, PSLVERR;
  endclocking

  // Modports
  modport MON (clocking cb_mon);
  modport DRV (clocking cb_drv);

  // Modport kiểu RTL để nối vào DUT
  modport slv (
    input  PWRITE,
           PENABLE,
           PADDR,
           PWDATA,
           PSELx,
    output PRDATA,
           PREADY,
           PSLVERR
  );

endinterface