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

    always @(posedge PCLK or negedge PRESETn) begin
        if(!PRESETn)    begin
            PREADY <= 0;
            PSLVERR <= 0;
        end
        else    begin
            PREADY <= 0;
            PSLVERR <= 0;
            if(PSELx)   begin
                if(PENABLE & !PWRITE)   begin
                    if(PADDR[30:0]<1024)  begin
                        PRDATA <= memory[PADDR[30:0]];
                        PREADY <= 1;
                    end
                    else    begin
                        PREADY <= 1;
                        PSLVERR <= 1;
                    end
                end
                else if(PENABLE & PWRITE)   begin
                    if(PADDR[30:0]<1024)  begin
                        memory[PADDR[30:0]] <= PWDATA;
                        PREADY <= 1;
                    end
                    else    begin
                        PREADY <= 1;
                        PSLVERR <= 1;
                    end
                end
                else    begin
                    PREADY <= 0;
                    PSLVERR <= 0;
                end
            end
            else    begin
                PREADY <= 0;
                PSLVERR <= 0;
                PRDATA <= 0;
            end
        end
    end
endmodule
