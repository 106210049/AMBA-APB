//  Class: apb_test_lib
//
class apb_test_lib extends uvm_component;
    `uvm_component_utils(apb_test_lib);

    apb_tb tb;
    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_test_lib", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        // UVM Config to set the agent to active mode and set the recording detail to 1
        uvm_config_int::set(this, "tb.master_env.agent", "is_active", UVM_ACTIVE);
        uvm_config_int::set(this, "tb.slave_env.agent", "is_active", UVM_PASSIVE);
        uvm_config_int::set(this, "*", "recording_detail", 1);
        super.build_phase(phase);
        // Create the testbench
        tb = apb_tb::type_id::create("tb", this);
        `uvm_info(get_type_name(), $sformatf("Build Phase of Test is being executed!"), UVM_HIGH)
    endfunction: build_phase

    // function end of elaboration phase
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        // Print the topology of the testbench
        `uvm_info(get_type_name(), $sformatf("End of Elaboration Phase of Test is being executed!"), UVM_HIGH)
        uvm_top.print_topology();
        super.end_of_elaboration_phase(phase);        
    endfunction: end_of_elaboration_phase

    task run_phase(uvm_phase phase);
         // Set drain time to 200ns to allow for any pending transactions to complete before ending     
        uvm_objection obj = phase.get_objection();
        obj.set_drain_time(this, 200ns);
        `uvm_info(get_type_name(), $sformatf("Run Phase of Test is being executed!"), UVM_HIGH)
        super.run_phase(phase);
        phase.raise_objection(this, get_type_name());
        `uvm_info(get_type_name(), $sformatf("Raise objection in run phase"), UVM_HIGH)
        phase.drop_objection(this, get_type_name());
        `uvm_info(get_type_name(), $sformatf("Drop objection in run phase"), UVM_HIGH)
    endtask: run_phase
    
    virtual function void check_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Check config usage at check phase", UVM_HIGH);
        check_config_usage();
    endfunction: check_phase
    
endclass: apb_test_lib

class apb_master_slave_1_test extends apb_test_lib;
    `uvm_component_utils(apb_master_slave_1_test)

    //  Constructor: new
    function new(string name = "apb_master_slave_1_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, 
                                "tb.master_env.agent.sequencer.run_phase", 
                                "default_sequence", 
                                apb_master_slave_1_sequences::get_type());
        super.build_phase(phase);
    endfunction: build_phase
endclass: apb_master_slave_1_test

class apb_master_slave_2_test extends apb_test_lib;
    `uvm_component_utils(apb_master_slave_2_test)

    //  Constructor: new
    function new(string name = "apb_master_slave_2_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, 
                                "tb.master_env.agent.sequencer.run_phase", 
                                "default_sequence", 
                                apb_master_slave_2_sequences::get_type());
        super.build_phase(phase);
    endfunction: build_phase
endclass: apb_master_slave_2_test

class apb_master_random_test extends apb_test_lib;
    `uvm_component_utils(apb_master_random_test)

    //  Constructor: new
    function new(string name = "apb_master_random_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, 
                                "tb.master_env.agent.sequencer.run_phase", 
                                "default_sequence", 
                                apb_master_random_sequences::get_type());
        super.build_phase(phase);
    endfunction: build_phase
endclass: apb_master_random_test

class apb_master_wait_trans_test extends apb_test_lib;
    `uvm_component_utils(apb_master_wait_trans_test)

    //  Constructor: new
    function new(string name = "apb_master_wait_trans_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, 
                                "tb.master_env.agent.sequencer.run_phase", 
                                "default_sequence", 
                                apb_master_wait_trans_sequences::get_type());
        super.build_phase(phase);
    endfunction: build_phase
endclass: apb_master_wait_trans_test

class apb_master_error_response_test extends apb_test_lib;
    `uvm_component_utils(apb_master_error_response_test)

    //  Constructor: new
    function new(string name = "apb_master_error_response_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(apb_master_seq_item::get_type(), illegal_address_seq_item::get_type());
        uvm_config_wrapper::set(this, 
                                "tb.master_env.agent.sequencer.run_phase", 
                                "default_sequence", 
                                apb_master_error_response_sequences::get_type());
        super.build_phase(phase);
    endfunction: build_phase
endclass: apb_master_error_response_test


class apb_master_5_random_test extends apb_test_lib;
    `uvm_component_utils(apb_master_5_random_test)

    //  Constructor: new
    function new(string name = "apb_master_5_random_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, 
                                "tb.master_env.agent.sequencer.run_phase", 
                                "default_sequence", 
                                apb_master_5_random_sequences::get_type());
        super.build_phase(phase);
    endfunction: build_phase
endclass: apb_master_5_random_test

class apb_master_full_strobes_test extends apb_test_lib;
    `uvm_component_utils(apb_master_full_strobes_test)

    //  Constructor: new
    function new(string name = "apb_master_full_strobes_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, 
                                "tb.master_env.agent.sequencer.run_phase", 
                                "default_sequence", 
                                apb_master_full_strobes_sequences::get_type());
        super.build_phase(phase);
    endfunction: build_phase
endclass: apb_master_full_strobes_test

class apb_master_zero_stobes_test extends apb_test_lib;
    `uvm_component_utils(apb_master_zero_stobes_test)

    //  Constructor: new
    function new(string name = "apb_master_zero_stobes_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, 
                                "tb.master_env.agent.sequencer.run_phase", 
                                "default_sequence", 
                                apb_master_zero_strobes_sequences::get_type());
        super.build_phase(phase);
    endfunction: build_phase
endclass: apb_master_zero_stobes_test

class apb_master_sequence_trans_test extends apb_test_lib;
    `uvm_component_utils(apb_master_sequence_trans_test)

    //  Constructor: new
    function new(string name = "apb_master_sequence_trans_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(apb_master_driver::get_type(), apb_master_5_transfer_driver::get_type());
        uvm_config_wrapper::set(this, 
                                "tb.master_env.agent.sequencer.run_phase", 
                                "default_sequence", 
                                apb_master_5_random_sequences::get_type());
        super.build_phase(phase);
    endfunction: build_phase
endclass: apb_master_sequence_trans_test