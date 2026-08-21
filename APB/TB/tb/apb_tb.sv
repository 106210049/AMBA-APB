//  Class: apb_master_tb
//
class apb_tb extends uvm_env;
    `uvm_component_utils(apb_tb);

    apb_master_env master_env;
    apb_slave_env  slave_env;
    apb_scoreboard apb_scb;
    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_tb", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        master_env = apb_master_env::type_id::create("master_env", this);
        slave_env = apb_slave_env::type_id::create("slave_env", this);
        apb_scb = apb_scoreboard::type_id::create("apb_scb", this);
        `uvm_info(get_type_name(), $sformatf("Testbench Build Phase is being executed !"), UVM_HIGH)
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        master_env.agent.monitor.item_collected_port.connect(apb_scb.master_imp);
        slave_env.agent.monitor.item_collected_port.connect(apb_scb.slave_imp);
        `uvm_info(get_type_name(), $sformatf("Testbench Connect Phase is being executed !"), UVM_HIGH)
    endfunction: connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction : start_of_simulation_phase
    
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Testbench Run Phase is begin executed!"), UVM_LOW) 
    endtask: run_phase

endclass: apb_tb
