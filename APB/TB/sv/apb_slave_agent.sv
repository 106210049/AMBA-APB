//  Class: apb_slave_agent
//
class apb_slave_agent extends uvm_agent;
    `uvm_component_utils(apb_slave_agent);
    int is_active = UVM_ACTIVE;

    apb_slave_driver driver;
    apb_slave_sequencer sequencer;
    apb_slave_monitor monitor;
    
    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_slave_agent", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = apb_slave_monitor::type_id::create("monitor", this);
        if (uvm_config_int::exists(this, "", "is_active")) begin
            `uvm_info("CFG", "Property is_active exists in config DB", UVM_LOW)
            if (!uvm_config_int::get(this, "", "is_active", is_active)) begin
            `uvm_error("CFG", "Failed to get is_active value")
            is_active = UVM_PASSIVE; // fallback
            end
        end else begin
            `uvm_error("CFG", "Property is_active haven't set in config DB")
            is_active = UVM_PASSIVE; // fallback
        end

        if(is_active == UVM_ACTIVE) begin
            `uvm_info(get_type_name(), "AGENT IS ACTIVE !", UVM_HIGH);
            driver = apb_slave_driver::type_id::create("driver", this);
            sequencer = apb_slave_sequencer::type_id::create("sequencer", this);
        end
        
    endfunction: build_phase
    
    virtual function void connect_phase(uvm_phase phase);
        if(is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction: connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction : start_of_simulation_phase
    
endclass: apb_slave_agent
