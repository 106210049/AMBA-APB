//  Class: apb_slave_seq_item
//
class apb_slave_seq_item extends uvm_sequence_item;

    rand bit [3:0]         PSTRB;
    rand bit [31:0]        PADDR;
    rand bit [31:0]        PWDATA;
    rand bit [1:0]         PSELx;
    rand bit               PWRITE;

    logic               PSLVERR;
    logic               PREADY;
    logic [31:0]        PRDATA;
    logic               PENABLE;
    
    
    `uvm_object_utils_begin(apb_slave_seq_item)
        `uvm_field_int(PSLVERR, UVM_ALL_ON)
        `uvm_field_int(PREADY, UVM_ALL_ON)
        `uvm_field_int(PRDATA, UVM_ALL_ON)
        `uvm_field_int(PENABLE, UVM_ALL_ON)
        `uvm_field_int(PWRITE, UVM_ALL_ON)
        `uvm_field_int(PSELx, UVM_ALL_ON + UVM_BIN)
        `uvm_field_int(PSTRB, UVM_ALL_ON + UVM_BIN)
        `uvm_field_int(PADDR,  UVM_ALL_ON)
        `uvm_field_int(PWDATA,  UVM_ALL_ON)
    `uvm_object_utils_end

    //  Group: Functions

    //  Constructor: new
    function new(string name = "apb_slave_seq_item");
        super.new(name);
    endfunction: new

    constraint psel_depends_on_addr_msb_c {
        PSELx == (PADDR[31] ? 2'b10 : 2'b01);
    }

    constraint paddr_legal_c {
        PADDR[30:0] inside {[0 : 32'h3FF]};
    } 
    
endclass: apb_slave_seq_item

class slave_illegal_address_seq_item extends apb_slave_seq_item;
    `uvm_object_utils(slave_illegal_address_seq_item)

    function new(string name = "slave_illegal_address_seq_item");
        super.new(name);
    endfunction: new

    constraint paddr_legal_c {}
    constraint illegal_addr {PADDR inside {[32'hFFFF:32'hFFFF_FFFF]};}
    
endclass: slave_illegal_address_seq_item