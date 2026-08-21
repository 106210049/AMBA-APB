// -------------------------------------
// Base class: uvm_subscriber
// -------------------------------------
virtual class uvm_subscriber #(type T=int) extends uvm_component;

  typedef uvm_subscriber #(T) this_type;
  uvm_analysis_imp #(T, this_type) analysis_export;
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
    analysis_export = new("analysis_imp", this);
  endfunction
  
  pure virtual function void write(T t);
endclass: uvm_subscriber


// -------------------------------------
// Subscriber class: func_cov
// -------------------------------------
class func_cov extends uvm_subscriber #(apb_slave_seq_item);
    `uvm_component_utils(func_cov);

    // Biến mirror để sample covergroup
    bit [31:0] PADDR;
    bit [1:0]  PSELx;
    bit        PWRITE;
    bit [3:0]  PSTRB;

    // Covergroups
    covergroup cov_slv_apb;
        cp_paddr: coverpoint PADDR {
            bins valid_addr   = { [32'h0000_0000 : 32'h0000_03FF],
                                [32'h8000_0000 : 32'h8000_03FF] };
            bins invalid_addr = { [32'hFFFF : 32'hFFFF_FFFF] };
        }

        // Coverpoint riêng cho 2 bit cuối
        cp_paddr_low2: coverpoint PADDR[1:0] {
            bins waiting_addr = {2'b01, 2'b10};
        }

        cp_pselx: coverpoint PSELx {
            bins slave_1 = {2'b01};
            bins slave_2 = {2'b10};
        }

        cross cp_paddr, cp_pselx {
            ignore_bins invalid_addr_slv1 = binsof(cp_paddr) intersect { [32'h0000_0000:32'h0000_03FF] } &&
                                            binsof(cp_pselx.slave_2);
            ignore_bins invalid_addr_slv2 = binsof(cp_paddr) intersect { [32'h8000_0000:32'h8000_03FF] } &&
                                            binsof(cp_pselx.slave_1);
        }
    endgroup


    covergroup cov_pwrite;
        cp_pwrite: coverpoint PWRITE {
            bins write = {1'b1};
            bins read  = {1'b0};
        }
    endgroup

    covergroup cov_strobes;
        cp_pstrb: coverpoint PSTRB {
            bins be_none  = {4'b0000};
            bins be_byte0 = {[4'b0001:4'b1110]};
            bins be_full  = {4'b1111};
        }
    endgroup

    function new(string name = "func_cov", uvm_component parent);
        super.new(name, parent);
        cov_slv_apb = new();
        cov_pwrite  = new();
        cov_strobes = new();
    endfunction

    // Override đúng signature: write(T t)
    function void write(apb_slave_seq_item t);
        // Gán từ transaction sang biến mirror
        PADDR  = t.PADDR;
        PSELx  = t.PSELx;
        PWRITE = t.PWRITE;
        PSTRB  = t.PSTRB;

        // Sample covergroups
        cov_slv_apb.sample();
        cov_pwrite.sample();
        cov_strobes.sample();
    endfunction
endclass: func_cov