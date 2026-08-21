package apb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef uvm_config_db#(virtual apb_if.master) apb_master_vif_config;
    typedef uvm_config_db#(virtual apb_if.slave) apb_slave_vif_config;
    `include "apb_master_seq_item.sv"
    `include "apb_master_sequences.sv"
    `include "apb_master_sequencer.sv"
    `include "apb_master_driver.sv"
    `include "apb_master_monitor.sv"
    `include "apb_master_agent.sv"
    `include "apb_master_env.sv"

    `include "apb_slave_seq_item.sv"
    `include "apb_slave_sequences.sv"
    `include "apb_slave_sequencer.sv"
    `include "apb_slave_driver.sv"
    `include "apb_slave_monitor.sv"
    `include "apb_slave_agent.sv"
    `include "apb_slave_subscriber.sv"
    `include "apb_slave_env.sv"
endpackage: apb_pkg