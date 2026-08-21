//  Class: apb_master_sequencer
//
class apb_master_sequencer extends uvm_sequencer #(apb_master_seq_item);
    `uvm_component_utils(apb_master_sequencer);

    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_master_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
    endfunction: start_of_simulation_phase
    
endclass: apb_master_sequencer
