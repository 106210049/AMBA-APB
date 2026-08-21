//  Class: apb_master_sequences
//
class apb_master_sequences extends uvm_sequence #(apb_master_seq_item);
    `uvm_object_utils(apb_master_sequences);
    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_master_sequences");
        super.new(name);
    endfunction: new

    task pre_body();
        uvm_phase phase;
        `ifdef UVM_VERSION_1_2
            phase = get_starting_phase();
        `else 
            phase = starting_phase;
        `endif
        if(phase != null) begin
            // Raise objection to prevent the run_phase from ending before the sequence is complete
            phase.raise_objection(this, get_type_name());
            `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
        end
    endtask: pre_body

    task post_body();
        uvm_phase phase;
        `ifdef UVM_VERSION_1_2
            phase = get_starting_phase();
        `else 
            phase = starting_phase;
        `endif
        if(phase != null) begin
            // Drop objection to allow the run_phase to end after the sequence is complete
            phase.drop_objection(this, get_type_name());
            `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
        end
    endtask: post_body
    
endclass: apb_master_sequences


class apb_master_slave_1_sequences extends apb_master_sequences;
    `uvm_object_utils(apb_master_slave_1_sequences);

    function new(string name = "apb_master_slave_1_sequences");
        super.new(name);
    endfunction: new

    task body();
        `uvm_info(get_type_name(), "Executing apb_master_slave_1_sequences", UVM_LOW)
        `uvm_do_with(req, {req.APB_WRITE_PADDR[31] == 1'b0 ;})
    endtask: body
endclass: apb_master_slave_1_sequences

class apb_master_slave_2_sequences extends apb_master_sequences;
    `uvm_object_utils(apb_master_slave_2_sequences);

    function new(string name = "apb_master_slave_2_sequences");
        super.new(name);
    endfunction: new

    task body();
        `uvm_info(get_type_name(), "Executing apb_master_slave_2_sequences", UVM_LOW)
        `uvm_do_with(req, {req.APB_WRITE_PADDR[31] == 1'b1;})
    endtask: body
endclass: apb_master_slave_2_sequences

class apb_master_random_sequences extends apb_master_sequences;
    `uvm_object_utils(apb_master_random_sequences);

    function new(string name = "apb_master_random_sequences");
        super.new(name);
    endfunction: new

    task body();
        `uvm_info(get_type_name(), "Executing apb_master_random_sequences", UVM_LOW)
        `uvm_do(req)
    endtask: body
endclass: apb_master_random_sequences

class apb_master_wait_trans_sequences extends apb_master_sequences;
    `uvm_object_utils(apb_master_wait_trans_sequences);

    function new(string name = "apb_master_wait_trans_sequences");
        super.new(name);
    endfunction: new

    task body();
        `uvm_info(get_type_name(), "Executing apb_master_wait_trans_sequences", UVM_LOW)
        `uvm_do_with(req, {req.APB_WRITE_PADDR[1:0] inside {[2'b01:2'b11]};})
    endtask: body
endclass: apb_master_wait_trans_sequences

class apb_master_error_response_sequences extends apb_master_sequences;
    `uvm_object_utils(apb_master_error_response_sequences);

    function new(string name = "apb_master_error_response_sequences");
        super.new(name);
    endfunction: new
    // req.address_c.constraint_mode(0); // disable constraint
    task body();
        `uvm_info(get_type_name(), "Executing apb_master_error_response_sequences", UVM_LOW)
        // `uvm_do_with(req, {req.APB_WRITE_PADDR[30:0] inside {[32'hFFFF:32'hFFFF_FFFF]};})
        `uvm_do(req);
    endtask: body
endclass:apb_master_error_response_sequences


class apb_master_5_random_sequences extends apb_master_sequences;
    `uvm_object_utils(apb_master_5_random_sequences);

    function new(string name = "apb_master_5_random_sequences");
        super.new(name);
    endfunction: new
    // req.address_c.constraint_mode(0); // disable constraint
    task body();
        `uvm_info(get_type_name(), "Executing apb_master_5_random_sequences", UVM_LOW)
        repeat(5)
            `uvm_do(req);
    endtask: body
endclass: apb_master_5_random_sequences

class apb_master_full_strobes_sequences extends apb_master_sequences;
    `uvm_object_utils(apb_master_full_strobes_sequences);

    function new(string name = "apb_master_full_strobes_sequences");
        super.new(name);
    endfunction: new
    // req.address_c.constraint_mode(0); // disable constraint
    task body();
        `uvm_info(get_type_name(), "Executing apb_master_full_strobes_sequences", UVM_LOW)
        `uvm_do_with(req, {req.APB_WRITE_STRB == 4'b1111;})
    endtask: body
endclass: apb_master_full_strobes_sequences