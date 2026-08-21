//  Class: apb_master_driver
//
class apb_master_driver extends uvm_driver #(apb_master_seq_item);
    `uvm_component_utils(apb_master_driver);

    int num_pkg_sent;
    virtual interface apb_if.master vif;

    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_master_driver", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        if(!apb_master_vif_config::get(this, "", "vif", vif))
            `uvm_error(get_type_name(), $sformatf("virtual interface must be set for: %s vif", get_full_name()))
        else 
            `uvm_info(get_type_name(), "Driver is connected with interface", UVM_HIGH)
    endfunction: connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction : start_of_simulation_phase
    
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(),$sformatf("Driver is running"), UVM_LOW);
        fork
            begin
                @(negedge vif.PRESETn)
                @(posedge vif.PRESETn);
                `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)
                forever begin
                    // Get new item from the sequencer
                    seq_item_port.get_next_item(req);
                    // Send the item to DUT
                    send_packet(req);
                    // Communicate item done to the sequencer
                    seq_item_port.item_done();
                end
            end
            reset_signals();
        join
    endtask: run_phase

    task send_packet(apb_master_seq_item apb_master_pkt);
        `uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s", req.sprint()), UVM_HIGH)
        fork
            begin
                vif.master_write_transfer(req.APB_WRITE_PADDR, req.APB_WRITE_STRB, req.APB_WRITE_DATA);
                vif.master_read_transfer(req.APB_READ_PADDR);
                `uvm_info(get_type_name(), $sformatf("Read Data: %0h", vif.APB_READ_DATA_OUT), UVM_HIGH)
            end
            @(posedge vif.master_drvstart) void'(begin_tr(req, "Driver_APB_Master"));
        join
        end_tr(req);
        num_pkg_sent++;
    endtask: send_packet

    task reset_signals();
        vif.apb_master_reset();
    endtask: reset_signals

endclass: apb_master_driver
