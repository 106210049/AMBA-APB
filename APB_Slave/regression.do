# regression.do

# đọc biến môi trường hoặc file cấu hình ngoài
if {[info exists ::env(MACRO)]} {
    set MACRO_LIST [split $::env(MACRO)]
    puts ">>> Đang chạy với define từ biến môi trường: $MACRO_LIST"
} elseif {[file exists defines.tcl]} {
    source defines.tcl
    puts ">>> Đang chạy với define từ defines.tcl: $MACRO_LIST"
} else {
    set MACRO_LIST {}
    puts ">>> Đang chạy không có define nào"
}

# dọn dẹp logs cũ
if {[file exists logs]} {
    foreach f [glob -nocomplain -directory logs *] {
        file delete -force $f
    }
    file delete -force logs
}
file mkdir logs

# xóa file coverage tổng hợp cũ nếu có
file delete -force all_tests.ucdb

# danh sách các test cần chạy
set TESTS {FIXED_ADDR RAND_ADDR RAND_ADDR_INRANGE SLAVE_0 SLAVE_1 ERROR_RESP WAITING_STATE}

set DEFINE_OPTIONS {}
foreach m $MACRO_LIST {
    lappend DEFINE_OPTIONS "+define+$m"
}

# chạy từng test
foreach t $TESTS {
    vlog +cover {*}$DEFINE_OPTIONS ./RTL/APB_Slave_TOP.sv ./TB/testbench.sv
    transcript file logs/$t.log
    vsim -c -coverage work.apb_tb_top +TESTNAME=$t -onfinish final -do "run -all; coverage save -onexit $t.ucdb;"
    transcript file ""
}


# merge tất cả coverage lại thành một file duy nhất
vcover merge all_tests.ucdb *.ucdb

if {[file exists all_tests.ucdb]} {
    vcover report -html -htmldir covhtmlreport all_tests.ucdb
} else {
    puts "Không tìm thấy file all_tests.ucdb để tạo báo cáo coverage!"
}
