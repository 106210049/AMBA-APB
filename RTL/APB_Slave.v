module APB_Slave (
    input wire PCLK, PRESETn,
    input wire PENABLE, PWRITE,
    input wire PSELx,
    input wire [31:0] PADDR, 
    input wire [31:0] PWDATA,

    output reg [31:0] PRDATA,
    output reg PREADY, PSLVERR
);
    reg [31:0] memory [1023:0];
    
    // Bộ đếm để theo dõi số chu kỳ đã chờ
    reg [1:0] count_reg;
    
    // Xác định số chu kỳ cần chờ dựa trên 2 bit cuối của địa chỉ
    wire [1:0] target_wait;
    assign target_wait = PADDR[1:0];

    always @(posedge PCLK or negedge PRESETn) begin
        if(!PRESETn) begin
            PREADY  <= 0;
            PSLVERR <= 0;
            PRDATA  <= 0;
            count_reg <= 0;
        end
        else begin
            if(PSELx) begin
                // Giai đoạn ACCESS (PENABLE = 1)
                if(PENABLE) begin
                    if(count_reg < target_wait) begin
                        // Chưa đợi đủ số chu kỳ yêu cầu
                        count_reg <= count_reg + 1'b1;
                        PREADY    <= 0;
                    end
                    else begin
                        // Đã đợi đủ, thực hiện Read/Write và bật PREADY
                        PREADY <= 1;
                        count_reg <= 0; // Reset bộ đếm cho giao dịch sau

                        if(PADDR[30:2] < 1024) begin
                            PSLVERR <= 0;
                            if(PWRITE)
                                memory[PADDR[30:2]] <= PWDATA;
                            else
                                PRDATA <= memory[PADDR[30:2]];
                        end
                        else begin
                            // Lỗi địa chỉ vượt quá vùng nhớ
                            PSLVERR <= 1;
                        end
                    end
                end
                else begin
                    // Giai đoạn SETUP (PSEL=1 nhưng PENABLE=0)
                    PREADY    <= 0;
                    count_reg <= 0;
                end
            end
            else begin
                // IDLE: Slave không được chọn
                PREADY    <= 0;
                PSLVERR   <= 0;
                count_reg <= 0;
                PRDATA    <= 0;
            end
        end
    end
endmodule