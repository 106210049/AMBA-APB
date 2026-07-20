`timescale 1ns/1ps
// `define STROBES
// `define BIG_EDIAN
`include "APB_Slave.sv"
module APB_Slave_TOP(
    input  logic        PCLK, 
    input  logic        PRESETn,
    input  logic        PWRITE,
    input  logic        PENABLE,        // <-- THÊM CỔNG NÀY
    input  logic [31:0] PADDR, 
    input  logic [31:0] PWDATA,
    input  logic [1:0]  PSELx,
    `ifdef STROBES
    input  logic [3:0]  PSTRB,
    `endif
    output logic [31:0] PRDATA,
    output logic         PSLVERR,
    output logic         PREADY
);
    // Wires từ mỗi slave
    wire [31:0] PRDATA1, PRDATA2;
    wire        PREADY1, PREADY2;
    wire        PSLVERR1, PSLVERR2;

    // Mux trả về
    wire [31:0] PRDATA_bus  = (PSELx[0]) ? PRDATA1 :
                              (PSELx[1]) ? PRDATA2 : 32'b0;

    wire        PREADY_bus  = (PSELx[0]) ? PREADY1 :
                              (PSELx[1]) ? PREADY2 : 1'b0;

    wire        PSLVERR_bus = (PSELx[0]) ? PSLVERR1 :
                              (PSELx[1]) ? PSLVERR2 : 1'b0;

    // SLAVE 0
    APB_Slave slave0_inst (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),
        .PENABLE  (PENABLE),    // <-- NỐI VÀO ĐÂY
        .PWRITE   (PWRITE),
        .PSELx    (PSELx[0]),
        `ifdef STROBES
        .PSTRB    (PSTRB),
        `endif
        .PADDR    (PADDR),
        .PWDATA   (PWDATA),
        .PRDATA   (PRDATA1),
        .PREADY   (PREADY1),
        .PSLVERR  (PSLVERR1)
    );

    // SLAVE 1
    APB_Slave slave1_inst (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),
        .PENABLE  (PENABLE),    // <-- NỐI VÀO ĐÂY
        .PWRITE   (PWRITE),
        .PSELx    (PSELx[1]),
        `ifdef STROBES
        .PSTRB    (PSTRB),
        `endif
        .PADDR    (PADDR),
        .PWDATA   (PWDATA),
        .PRDATA   (PRDATA2),
        .PREADY   (PREADY2),
        .PSLVERR  (PSLVERR2)
    );

    // Xuất ra
    always @(*) begin
        PRDATA  = PRDATA_bus;
        PSLVERR = PSLVERR_bus;
        PREADY  = PREADY_bus;
    end
endmodule