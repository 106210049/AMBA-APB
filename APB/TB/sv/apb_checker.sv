program apb_checker (apb_if vif);

    // 1. VALID RESPONSE (không X/Z)
    property valid_resp;
        @(posedge vif.PCLK) disable iff (!vif.PRESETn)
        (|tb_apb_top.uut.PSELx && tb_apb_top.uut.PENABLE && vif.PREADY)
        |->
        (!$isunknown(vif.PREADY) && !$isunknown(vif.PSLVERR));
    endproperty
    assert property (valid_resp)
    else $error("[FAIL] PREADY/PSLVERR contains X/Z");
    cover property (valid_resp);

    // 2. PENABLE phải theo sau Setup phase
    property penable_after_setup;
        @(posedge vif.PCLK) disable iff (!vif.PRESETn)
        $rose(tb_apb_top.uut.PENABLE)
        |->
        $past(|tb_apb_top.uut.PSELx && !tb_apb_top.uut.PENABLE);
    endproperty
    assert property (penable_after_setup)
    else $error("[FAIL] PENABLE asserted without Setup phase");
    cover property (penable_after_setup);

    // 3. PREADY chỉ xuất hiện ở Access phase
    property pready_access_phase;
        @(posedge vif.PCLK) disable iff (!vif.PRESETn)
        vif.PREADY
        |->
        (|tb_apb_top.uut.PSELx && tb_apb_top.uut.PENABLE);
    endproperty
    assert property (pready_access_phase)
    else $error("[FAIL] PREADY asserted outside Access phase");
    cover property (pready_access_phase);

    // 4. PSLVERR chỉ được bật cùng transfer complete
    property slverr_with_pready;
        @(posedge vif.PCLK) disable iff (!vif.PRESETn)
        vif.PSLVERR
        |->
        vif.PREADY;
    endproperty
    assert property (slverr_with_pready)
    else $error("[FAIL] PSLVERR asserted without PREADY");
    cover property (slverr_with_pready);

    // 5. Invalid address phải sinh PSLVERR
    property invalid_addr_error;
        @(posedge vif.PCLK) disable iff (!vif.PRESETn)
        (vif.PREADY && (tb_apb_top.uut.PADDR[30:2] >= 1024))
        |->
        vif.PSLVERR;
    endproperty
    assert property (invalid_addr_error)
    else $error("[FAIL] Invalid address must assert PSLVERR");
    cover property (invalid_addr_error);

    // 6. Valid address không được sinh PSLVERR
    property valid_addr_no_error;
        @(posedge vif.PCLK) disable iff (!vif.PRESETn)
        (vif.PREADY && (tb_apb_top.uut.PADDR[30:2] < 1024))
        |->
        !vif.PSLVERR;
    endproperty
    assert property (valid_addr_no_error)
    else $error("[FAIL] PSLVERR asserted for valid address");
    cover property (valid_addr_no_error);

    // 7. COVER successful APB transfer
    property apb_success;
        @(posedge vif.PCLK) disable iff (!vif.PRESETn)
        (|tb_apb_top.uut.PSELx && vif.PENABLE && vif.PREADY && !vif.PSLVERR);
    endproperty
    cover property (apb_success);

    // 8. COVER APB ERROR transfer
    property apb_error;
        @(posedge vif.PCLK) disable iff (!vif.PRESETn)
        (vif.PREADY && vif.PSLVERR);
    endproperty
    cover property (apb_error);

endprogram
