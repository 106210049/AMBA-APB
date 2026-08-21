//  Class: apb_master_env
//
class apb_master_env extends uvm_env;
    `uvm_component_utils(apb_master_env);

    apb_master_agent agent;


    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_master_env", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = apb_master_agent::type_id::create("agent", this);
    endfunction: build_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction : start_of_simulation_phase
    
endclass: apb_master_env
