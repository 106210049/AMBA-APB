`define WDATA_ALL_ZERO   32'h0000_0000  // All zeros
`define WDATA_ALL_ONE    32'hFFFF_FFFF  // All ones
`define WDATA_ALT_1010   32'hAAAA_AAAA  // Alternating 1010 pattern
`define WDATA_ALT_0101   32'h5555_5555  // Alternating 0101 pattern
// apb_master_seq_item
class apb_master_seq_item extends uvm_sequence_item;

    rand bit [3:0]      APB_WRITE_STRB;
    rand bit [31:0]     APB_WRITE_PADDR;
    rand bit [31:0]     APB_WRITE_DATA;
    rand bit [31:0]     APB_READ_PADDR;

    logic               TRANS;
    logic               READ;
    logic               WRITE;
    logic               PSLVERR;
    logic               PREADY;
    logic [31:0]        PRDATA;
    logic [31:0]        APB_READ_DATA_OUT;

    logic               PENABLE;
    logic               PWRITE;
    logic [1:0]         PSELx;
    logic [3:0]         PSTRB;
    logic [31:0]        PADDR;
    logic [31:0]        PWDATA;

    `uvm_object_utils_begin(apb_master_seq_item)
        // `uvm_field_int(TRANS, UVM_ALL_ON)
        `uvm_field_int(READ, UVM_ALL_ON)
        `uvm_field_int(WRITE, UVM_ALL_ON)
        `uvm_field_int(APB_WRITE_STRB, UVM_ALL_ON + UVM_BIN)
        `uvm_field_int(APB_WRITE_PADDR,  UVM_ALL_ON)
        `uvm_field_int(APB_WRITE_DATA,  UVM_ALL_ON)
        `uvm_field_int(APB_READ_PADDR, UVM_ALL_ON)
        `uvm_field_int(APB_READ_DATA_OUT, UVM_ALL_ON)
        // `uvm_field_int(PSLVERR, UVM_ALL_ON)
        // `uvm_field_int(PREADY, UVM_ALL_ON)
        // `uvm_field_int(PRDATA, UVM_ALL_ON)
        // `uvm_field_int(PENABLE, UVM_ALL_ON)
        // `uvm_field_int(PWRITE, UVM_ALL_ON)
        // `uvm_field_int(PSELx, UVM_ALL_ON + UVM_BIN)
        // `uvm_field_int(PSTRB, UVM_ALL_ON + UVM_BIN)
        // `uvm_field_int(PADDR,  UVM_ALL_ON)
        // `uvm_field_int(PWDATA,  UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "apb_master_seq_item");
        super.new(name);
    endfunction

    constraint address_c {
        // Giới hạn địa chỉ thực tế theo mem depth
        APB_WRITE_PADDR[30:0] inside {[0 : 32'h3FF]};
        APB_READ_PADDR[30:0]  inside {[0 : 32'h3FF]};
    }


    constraint data_write_c {
        APB_WRITE_DATA dist {
            `WDATA_ALL_ZERO := 5,   
            `WDATA_ALL_ONE  := 20,   
            `WDATA_ALT_1010 := 20,    
            `WDATA_ALT_0101 := 20,    
            [32'h0000_0001 : 32'h7FFF_FFFF] :/ 35, 
            [32'h8000_0000 : 32'hFFFF_FFFE] :/ 35  
        };
    }

    constraint addr_test_c {
        APB_WRITE_PADDR == APB_READ_PADDR;
    }

    constraint strobes_c {
        APB_WRITE_STRB inside {[4'b0000:4'b1111]};
    }
    

endclass: apb_master_seq_item

class illegal_address_seq_item extends apb_master_seq_item;
    `uvm_object_utils(illegal_address_seq_item)

    function new(string name = "illegal_address_packet");
        super.new(name);
    endfunction: new

    constraint address_c {}
    constraint illegal_addr {APB_WRITE_PADDR inside {[32'hFFFF:32'hFFFF_FFFF]};}
endclass: illegal_address_seq_item