program apb_checker (apb_if vif);

    // ==========================================
    // 1. VALID RESPONSE (không X/Z)
    // ==========================================
    property p_valid_resp;
        @(vif.cb_mon)
        disable iff (!vif.cb_mon.PRESETn)

        (|vif.cb_mon.PSELx &&
         vif.cb_mon.PENABLE &&
         vif.cb_mon.PREADY)

        |->
        (!$isunknown(vif.cb_mon.PREADY) &&
         !$isunknown(vif.cb_mon.PSLVERR));
    endproperty

    ASSERT_VALID_RESP :
    assert property (p_valid_resp)
        $display("[PASS] VALID APB RESPONSE");
    else
        $error("[FAIL] PREADY/PSLVERR contains X/Z");


    // ==========================================
    // 2. PENABLE phải theo sau Setup phase
    // ==========================================
    property p_penable_after_setup;
        @(vif.cb_mon)
        disable iff (!vif.cb_mon.PRESETn)

        $rose(vif.cb_mon.PENABLE)

        |->
        $past(|vif.cb_mon.PSELx &&
              !vif.cb_mon.PENABLE);
    endproperty

    ASSERT_PENABLE_AFTER_SETUP :
    assert property (p_penable_after_setup)
        $display("[PASS] PENABLE protocol OK");
    else
        $error("[FAIL] PENABLE asserted without Setup phase");


    // ==========================================
    // 3. PREADY chỉ xuất hiện ở Access phase
    // ==========================================
    property p_pready_access_phase;
        @(vif.cb_mon)
        disable iff (!vif.cb_mon.PRESETn)

        vif.cb_mon.PREADY
        |->
        (|vif.cb_mon.PSELx &&
         vif.cb_mon.PENABLE);
    endproperty

    ASSERT_PREADY_ACCESS :
    assert property (p_pready_access_phase)
        $display("[PASS] PREADY access phase OK");
    else
        $error("[FAIL] PREADY asserted outside Access phase");


    // ==========================================
    // 4. PSLVERR chỉ được bật cùng transfer complete
    // ==========================================
    property p_slverr_with_pready;
        @(vif.cb_mon)
        disable iff (!vif.cb_mon.PRESETn)

        vif.cb_mon.PSLVERR
        |->
        vif.cb_mon.PREADY;
    endproperty

    ASSERT_PSLVERR_WITH_PREADY :
    assert property (p_slverr_with_pready)
        $display("[PASS] PSLVERR timing OK");
    else
        $error("[FAIL] PSLVERR asserted without PREADY");


    // ==========================================
    // 5. Invalid address phải sinh PSLVERR
    // Theo RTL:
    // addr_ok = (PADDR[30:2] < 1024)
    // ==========================================
    property p_invalid_addr_error;
        @(vif.cb_mon)
        disable iff (!vif.cb_mon.PRESETn)

        (vif.cb_mon.PREADY &&
         (vif.cb_mon.PADDR[30:2] >= 1024))

        |->
        vif.cb_mon.PSLVERR;
    endproperty

    ASSERT_INVALID_ADDR_ERROR :
    assert property (p_invalid_addr_error)
        $display("[PASS] Invalid address ERROR OK");
    else
        $error("[FAIL] Invalid address must assert PSLVERR");


    // ==========================================
    // 6. Valid address không được sinh PSLVERR
    // ==========================================
    property p_valid_addr_no_error;
        @(vif.cb_mon)
        disable iff (!vif.cb_mon.PRESETn)

        (vif.cb_mon.PREADY &&
         (vif.cb_mon.PADDR[30:2] < 1024))

        |->
        !vif.cb_mon.PSLVERR;
    endproperty

    ASSERT_VALID_ADDR_NO_ERROR :
    assert property (p_valid_addr_no_error)
        $display("[PASS] Valid address response OK");
    else
        $error("[FAIL] PSLVERR asserted for valid address");


    // ==========================================
    // 7. COVER successful APB transfer
    // ==========================================
    property p_apb_success;
        @(vif.cb_mon)
        disable iff (!vif.cb_mon.PRESETn)

        (|vif.cb_mon.PSELx &&
         vif.cb_mon.PENABLE &&
         vif.cb_mon.PREADY &&
         !vif.cb_mon.PSLVERR);
    endproperty

    COVER_APB_SUCCESS :
    cover property (p_apb_success)
        $display("[COVER] Successful APB transfer observed");


    // ==========================================
    // 8. COVER APB ERROR transfer
    // ==========================================
    property p_apb_error;
        @(vif.cb_mon)
        disable iff (!vif.cb_mon.PRESETn)

        (vif.cb_mon.PREADY &&
         vif.cb_mon.PSLVERR);
    endproperty

    COVER_APB_ERROR :
    cover property (p_apb_error)
        $display("[COVER] APB ERROR transfer observed");

endprogram