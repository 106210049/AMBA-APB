//  Class: apb_slave_env
//
class apb_slave_env extends uvm_env;
    `uvm_component_utils(apb_slave_env);

    apb_slave_agent agent;
    func_cov fc;

    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_slave_env", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = apb_slave_agent::type_id::create("agent", this);
        fc = func_cov::type_id::create("fc", this);
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        agent.monitor.item_collected_port.connect(fc.analysis_export);
    endfunction: connect_phase 

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction : start_of_simulation_phase
    
endclass: apb_slave_env
