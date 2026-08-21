//  Class: apb_slave_sequencer
//
class apb_slave_sequencer extends uvm_sequencer #(apb_slave_seq_item);
    `uvm_component_utils(apb_slave_sequencer);

    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_slave_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    // Connect Phase
    function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction : connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
    endfunction: start_of_simulation_phase

    task run_phase (uvm_phase phase);
            super.run_phase(phase);
    endtask : run_phase
    
endclass: apb_slave_sequencer
