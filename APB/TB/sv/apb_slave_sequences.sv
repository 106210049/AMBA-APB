//  Class: apb_slave_sequences
//
class apb_slave_sequences extends uvm_sequence #(apb_slave_seq_item);
    `uvm_object_utils(apb_slave_sequences);

    
    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_slave_sequences");
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
    
endclass: apb_slave_sequences


class apb_slave_write_sequences extends apb_slave_sequences;
    `uvm_object_utils(apb_slave_write_sequences);

    function new(string name = "apb_slave_write_sequences");
        super.new(name);
    endfunction: new

    task body();
        `uvm_info(get_type_name(), "Executing apb_slave_write_sequences", UVM_LOW)
        `uvm_do_with(req, {req.PWRITE == 1'b1;})
    endtask: body
endclass: apb_slave_write_sequences


class apb_slave_read_sequences extends apb_slave_sequences;
    `uvm_object_utils(apb_slave_read_sequences);

    function new(string name = "apb_slave_read_sequences");
        super.new(name);
    endfunction: new

    task body();
        `uvm_info(get_type_name(), "Executing apb_slave_read_sequences", UVM_LOW)
        `uvm_do_with(req, {req.PWRITE == 1'b0;})
    endtask: body
endclass: apb_slave_read_sequences

class apb_slave_error_response_sequences extends apb_slave_sequences;
    `uvm_object_utils(apb_slave_error_response_sequences);

    function new(string name = "apb_slave_error_response_sequences");
        super.new(name);
    endfunction: new

    task body();
        `uvm_info(get_type_name(), "Executing apb_slave_error_response_sequences", UVM_LOW)
        `uvm_do(req);
    endtask: body
endclass: apb_slave_error_response_sequences