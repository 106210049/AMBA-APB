//  Class: apb_slave_monitor
//
class apb_slave_monitor extends uvm_monitor;
    `uvm_component_utils(apb_slave_monitor);

    apb_slave_seq_item apb_slave_pkt;
    int num_pkt_col;
    uvm_analysis_port #(apb_slave_seq_item) item_collected_port;
    virtual interface apb_if.slave vif;
    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_slave_monitor", uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction: new

    function void connect_phase(uvm_phase phase);
        if(!apb_slave_vif_config::get(this, "", "vif", vif))
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
            apb_slave_pkt = apb_slave_seq_item::type_id::create("apb_slave_pkt", this);
            fork 
                // Collect packet from the DUT
                vif.apb_slave_collector(apb_slave_pkt.PWRITE,
                                        apb_slave_pkt.PSTRB,
                                        apb_slave_pkt.PSELx,
                                        apb_slave_pkt.PWDATA,
                                        apb_slave_pkt.PADDR,
                                        apb_slave_pkt.PRDATA
                );
                begin
                    @(posedge vif.slave_monstart)
                    void'(begin_tr(apb_slave_pkt, "Monitor_APB_Slave"));    
                end
            join
            end_tr(apb_slave_pkt);
            item_collected_port.write(apb_slave_pkt);
            `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", apb_slave_pkt.sprint()), UVM_LOW)
            num_pkt_col++;
        end
    endtask: run_phase

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
            $sformatf("Report: APB Slave Monitor observed %0d transactions", num_pkt_col),
            UVM_LOW)
        if(num_pkt_col == 0)
            `uvm_error(get_type_name(), "No packets observed")
    endfunction
endclass: apb_slave_monitor
