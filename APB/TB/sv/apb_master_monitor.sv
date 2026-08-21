//  Class: apb_master_monitor
//
class apb_master_monitor extends uvm_monitor;
    `uvm_component_utils(apb_master_monitor);

    apb_master_seq_item apb_master_pkt;
    int num_pkt_col;
    uvm_analysis_port #(apb_master_seq_item) item_collected_port;
    virtual interface apb_if.master vif;

    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_master_monitor", uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction: new

    function void connect_phase(uvm_phase phase);
        if(!apb_master_vif_config::get(this, "", "vif", vif))
            `uvm_error(get_type_name(),
                $sformatf("virtual interface must be set for: %s vif", get_full_name()))
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
            {"start of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        @(negedge vif.PRESETn)
        @(posedge vif.PRESETn);
        `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)
        forever begin
            // Create a new packet object
            apb_master_pkt = apb_master_seq_item::type_id::create("apb_master_pkt", this);
            fork 
                // Collect packet from the DUT
                vif.apb_master_collector(   apb_master_pkt.APB_READ_PADDR, 
                                            apb_master_pkt.APB_READ_DATA_OUT, 
                                            apb_master_pkt.PSLVERR, 
                                            apb_master_pkt.READ,
                                            apb_master_pkt.WRITE,
                                            apb_master_pkt.APB_WRITE_PADDR, 
                                            apb_master_pkt.APB_WRITE_DATA, 
                                            apb_master_pkt.APB_WRITE_STRB
                );
                begin
                    @(posedge vif.master_monstart)
                    void'(begin_tr(apb_master_pkt, "Monitor_APB_Master"));    
                end
            join
            end_tr(apb_master_pkt);
            item_collected_port.write(apb_master_pkt);
            `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", apb_master_pkt.sprint()), UVM_LOW)
            num_pkt_col++;
        end
    endtask: run_phase

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
            $sformatf("Report: APB Master Monitor observed %0d transactions", num_pkt_col),
            UVM_LOW)
        if(num_pkt_col == 0)
            `uvm_error(get_type_name(), "No packets observed")
    endfunction
    
endclass: apb_master_monitor
