// Code your design here
`include "APB_Master.v"
`include "APB_Slave.v"
module APB_Top(
    input  wire        PCLK, PRESETn,
    input  wire        TRANS, READ, WRITE,
    input  wire [31:0] APB_WRITE_PADDR, APB_WRITE_DATA, APB_READ_PADDR,
    output reg  [31:0] APB_READ_DATA_OUT,
    output reg         PSLVERR
);
    // Wires từ master sang bus APB
    wire        PENABLE, PWRITE;
    wire [1:0]  PSELx;
    wire [31:0] PADDR;
    wire [31:0] PWDATA;

    // Wires từ mỗi slave
    wire [31:0] PRDATA1, PRDATA2;
    wire        PREADY1, PREADY2;
    wire        PSLVERR1, PSLVERR2;

    // Wires bus trả về master (multiplex theo PSELx)
    wire [31:0] PRDATA_bus;
    wire        PREADY_bus;
    wire        PSLVERR_bus;

    // Wire cho dữ liệu đọc từ master (để gán ra output reg của top)
    wire [31:0] master_read_data;

    // =========================
    // Multiplex bus theo PSELx
    // =========================
    assign PRDATA_bus  = (PSELx[0]) ? PRDATA1 :
                         (PSELx[1]) ? PRDATA2 : 32'b0;

    assign PREADY_bus  = (PSELx[0]) ? PREADY1 :
                         (PSELx[1]) ? PREADY2 : 1'b0;

    assign PSLVERR_bus = (PSELx[0]) ? PSLVERR1 :
                         (PSELx[1]) ? PSLVERR2 : 1'b0;

    // =========================
    // Instantiation: MASTER
    // =========================
    APB_Master master_inst (
        .PCLK              (PCLK),
        .PRESETn           (PRESETn),
        // điều khiển giao dịch
        .TRANS             (TRANS),
        .READ              (READ),
        .WRITE             (WRITE),
        // địa chỉ & dữ liệu từ phía hệ thống
        .APB_WRITE_PADDR   (APB_WRITE_PADDR),
        .APB_WRITE_DATA    (APB_WRITE_DATA),
        .APB_READ_PADDR    (APB_READ_PADDR),
        // dữ liệu đọc trả ra (kết nối vào wire rồi gán ra output reg của top)
        .APB_READ_DATA_OUT (master_read_data),
        // tín hiệu từ slave (đã multiplex)
        .PSLVERR           (PSLVERR_bus),
        .PREADY            (PREADY_bus),
        .PRDATA            (PRDATA_bus),
        // tín hiệu APB sang slaves
        .PENABLE           (PENABLE),
        .PWRITE            (PWRITE),
        .PSELx             (PSELx),
        .PADDR             (PADDR),
        .PWDATA            (PWDATA)
    );

    // =========================
    // Instantiation: SLAVE 0
    // =========================
    APB_Slave slave0_inst (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),
        .PENABLE  (PENABLE),
        .PWRITE   (PWRITE),
        .PSELx    (PSELx[0]),   // bit 0 chọn slave 0
        .PADDR    (PADDR),
        .PWDATA   (PWDATA),
        .PRDATA   (PRDATA1),
        .PREADY   (PREADY1),
        .PSLVERR  (PSLVERR1)
    );

    // =========================
    // Instantiation: SLAVE 1
    // =========================
    APB_Slave slave1_inst (
        .PCLK     (PCLK),
        .PRESETn  (PRESETn),
        .PENABLE  (PENABLE),
        .PWRITE   (PWRITE),
        .PSELx    (PSELx[1]),   // bit 1 chọn slave 1
        .PADDR    (PADDR),
        .PWDATA   (PWDATA),
        .PRDATA   (PRDATA2),
        .PREADY   (PREADY2),
        .PSLVERR  (PSLVERR2)
    );

    // =========================
    // Đưa dữ liệu ra cổng reg của TOP
    // =========================
    always @(*) begin
        APB_READ_DATA_OUT = master_read_data;
        PSLVERR           = PSLVERR_bus;
    end

    // (Không bắt buộc) Cảnh báo khi cả hai slave đều được chọn cùng lúc.
    // Chỉ dùng trong mô phỏng (non-synthesizable display).
    // always @(*) begin
    //     if (PSELx == 2'b11) $display("APB_Top WARN: Both slaves selected concurrently!");
    // end

endmodule
