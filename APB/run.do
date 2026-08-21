# regression_apb.do

# Setup paths
set uvm_path C:/questasim64_10.7c/verilog_src/uvm-1.1d/src
set wlf_dir ./wlf_out
set cov_dir ./cov_out
set log_dir ./logs

# Dọn dẹp thư mục cũ
foreach dir [list $wlf_dir $cov_dir $log_dir] {
    if {[file exists $dir]} {
        foreach f [glob -nocomplain -directory $dir *] {
            file delete -force $f
        }
        file delete -force $dir
    }
    file mkdir $dir
}

# Xóa coverage tổng hợp cũ
file delete -force apb_all.ucdb

# Compile UVM package
vlog -sv +define+UVM_CMDLINE_NO_DPI +define+UVM_REGEX_NO_DPI +define+UVM_NO_DPI +incdir+$uvm_path \
     $uvm_path/uvm_pkg.sv

# Compile project (package, interface, RTL, testbench)
vlog +cover -sv -svinputport=relaxed +incdir+$uvm_path -f ./TB/tb/apb_run.f

# Danh sách các test
set TESTS {
    apb_master_slave_1_test
    apb_master_slave_2_test
    apb_master_random_test
    apb_master_wait_trans_test
    apb_master_error_response_test
    apb_master_5_random_test
    apb_master_full_strobes_test
}

# Chạy từng test
foreach t $TESTS {
    set wlf_file "$wlf_dir/${t}.wlf"
    set ucdb_file "$cov_dir/${t}.ucdb"
    set log_file "$log_dir/${t}.log"

    puts ">>> Running test: $t"

    vsim -c -coverage -wlf $wlf_file work.tb_apb_top \
         "+SVSEED=random" \
         "+UVM_TESTNAME=$t" \
         "+UVM_VERBOSITY=UVM_FULL" \
         "+UVM_TR_RECORD" \
         -onfinish final \
         -do "transcript file $log_file; log -r /*; run -all; coverage save -onexit $ucdb_file; quit -sim;" \
         -debugDB
}
# Merge coverage
vcover merge apb_all.ucdb $cov_dir/*.ucdb

# Report coverage
if {[file exists apb_all.ucdb]} {
    # HTML report (bao gồm cả assertion coverage)
    exec vcover report -html -htmldir covhtmlreport apb_all.ucdb

    # TXT report chi tiết, bao gồm code, functional và assertion coverage
    exec vcover report -detail -cvg -assert -comments -output apb_cover_report.txt apb_all.ucdb

    # Hiển thị nội dung TXT ngay trong transcript
    set fp [open "apb_cover_report.txt" r]
    puts ">>> Nội dung coverage report:"
    puts [read $fp]
    close $fp
} else {
    puts "Không tìm thấy file apb_all.ucdb để tạo báo cáo coverage!"
}

exit
