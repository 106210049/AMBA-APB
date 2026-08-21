typedef enum bit {EQUALITY, UVM} comp_t;

class apb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(apb_scoreboard)

    // Khai báo analysis imp cho master và slave
    `uvm_analysis_imp_decl(_master)
    `uvm_analysis_imp_decl(_slave)

    uvm_analysis_imp_master #(apb_master_seq_item, apb_scoreboard) master_imp;
    uvm_analysis_imp_slave  #(apb_slave_seq_item,  apb_scoreboard) slave_imp;

    // Reference memories
    bit [31:0] ref_mem_s0[*];
    bit [31:0] ref_mem_s1[*];

    // Hàng đợi lưu expected và actual
    apb_master_seq_item exp_queue[$];
    apb_slave_seq_item  act_queue[$];

    // Counters
    int total, n_wr, n_rd, n_err;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        master_imp = new("master_imp", this);
        slave_imp  = new("slave_imp", this);
        total = 0; n_wr = 0; n_rd = 0; n_err = 0;
    endfunction

    // Nhận packet từ monitor master
    function void write_master(apb_master_seq_item pkt);
        apb_master_seq_item scb_pkt;
        int unsigned addr;
        bit [31:0] old_val, new_val, mask;
        $cast(scb_pkt, pkt.clone());
        exp_queue.push_back(scb_pkt);

        total++;
        if(pkt.WRITE) begin
            n_wr++;
            addr = pkt.APB_WRITE_PADDR[30:2];

            // Lấy giá trị cũ trong ref_mem
            case(pkt.APB_WRITE_PADDR[31])
                1'b0: old_val = ref_mem_s0.exists(addr)?ref_mem_s0[addr]:'0;
                1'b1: old_val = ref_mem_s1.exists(addr)?ref_mem_s1[addr]:'0;
            endcase

            // Tạo mask từ strobes
            mask = { {8{pkt.APB_WRITE_STRB[3]}},
                    {8{pkt.APB_WRITE_STRB[2]}},
                    {8{pkt.APB_WRITE_STRB[1]}},
                    {8{pkt.APB_WRITE_STRB[0]}} };

            // Cập nhật dữ liệu theo strobes
            new_val = (old_val & ~mask) | (pkt.APB_WRITE_DATA & mask);

            // Lưu lại vào ref_mem
            case(pkt.APB_WRITE_PADDR[31])
                1'b0: ref_mem_s0[addr] = new_val;
                1'b1: ref_mem_s1[addr] = new_val;
            endcase

            `uvm_info(get_type_name(),
                $sformatf("[SB-MASTER-WRITE] ADDR=0x%0h DATA=0x%0h STRB=%b NEW_VAL=0x%0h",
                        pkt.APB_WRITE_PADDR, pkt.APB_WRITE_DATA, pkt.APB_WRITE_STRB, new_val),
                UVM_MEDIUM)
        end

        else if(pkt.READ) begin
            n_rd++;
            `uvm_info(get_type_name(),
                $sformatf("[SB-MASTER-READ] ADDR=0x%0h",
                          pkt.APB_READ_PADDR),
                UVM_MEDIUM)
        end
    endfunction

    // Nhận packet từ monitor slave
    function void write_slave(apb_slave_seq_item pkt);
        apb_slave_seq_item scb_pkt;
        $cast(scb_pkt, pkt.clone());
        act_queue.push_back(scb_pkt);
        `uvm_info(get_type_name(),
            $sformatf("[SB-SLAVE] Queued packet: PWRITE=%0b ADDR=0x%0h DATA=0x%0h PRDATA=0x%0h",
                      pkt.PWRITE, pkt.PADDR, pkt.PWDATA, pkt.PRDATA),
            UVM_HIGH)
    endfunction

    // So sánh expected vs actual
    function void check_phase(uvm_phase phase);
        while(exp_queue.size() > 0 && act_queue.size() > 0) begin
            apb_master_seq_item exp_pkt = exp_queue.pop_front();
            apb_slave_seq_item  act_pkt = act_queue.pop_front();

            if(exp_pkt.WRITE) begin
                // Compare WRITE: địa chỉ + dữ liệu
                if(exp_pkt.APB_WRITE_PADDR == act_pkt.PADDR &&
                   exp_pkt.APB_WRITE_DATA === act_pkt.PWDATA)
                    `uvm_info(get_type_name(),$sformatf("WRITE PASS EXP ADDR=0x%0h DATA=0x%0h, ACT ADDR=0x%0h DATA=0x%0h",
                                  exp_pkt.APB_WRITE_PADDR, exp_pkt.APB_WRITE_DATA,
                                  act_pkt.PADDR, act_pkt.PWDATA),UVM_MEDIUM)
                else begin
                    n_err++;
                    `uvm_error(get_type_name(),
                        $sformatf("WRITE FAIL EXP ADDR=0x%0h DATA=0x%0h, ACT ADDR=0x%0h DATA=0x%0h",
                                  exp_pkt.APB_WRITE_PADDR, exp_pkt.APB_WRITE_DATA,
                                  act_pkt.PADDR, act_pkt.PWDATA))
                end
            end 
            else if(exp_pkt.READ) begin
                // Compare READ: dữ liệu slave trả về vs ref_mem
                int unsigned addr = exp_pkt.APB_READ_PADDR[30:2];
                bit [31:0] exp_data;
                case(exp_pkt.APB_READ_PADDR[31])
                    1'b0: exp_data = ref_mem_s0.exists(addr)?ref_mem_s0[addr]:'x;
                    1'b1: exp_data = ref_mem_s1.exists(addr)?ref_mem_s1[addr]:'x;
                    default: exp_data = 'x;
                endcase

                if(act_pkt.PRDATA === exp_data)
                    `uvm_info(get_type_name(),
                        $sformatf("READ PASS ADDR=0x%0h EXP=0x%0h ACT=0x%0h",
                                  act_pkt.PADDR, exp_data, act_pkt.PRDATA),
                        UVM_MEDIUM)
                else begin
                    n_err++;
                    `uvm_error(get_type_name(),
                        $sformatf("READ FAIL ADDR=0x%0h EXP=0x%0h ACT=0x%0h",
                                  act_pkt.PADDR, exp_data, act_pkt.PRDATA))
                end
            end
        end
    endfunction

    // Báo cáo kết quả cuối cùng
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
                  $sformatf("Scoreboard Summary: Total=%0d WR=%0d RD=%0d ERR=%0d",
                            total, n_wr, n_rd, n_err),
                  UVM_NONE)
        if (n_err == 0)
            `uvm_info(get_type_name(), "Simulation PASSED ✅", UVM_NONE)
        else
            `uvm_error(get_type_name(), "Simulation FAILED ❌")
    endfunction
endclass
