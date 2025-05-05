SetActiveLib -work
comp -include "$dsn\src\RTC CLOCK.vhd" 
comp -include "$dsn\src\TestBench\rtc_TB.vhd" 
asim +access +r TESTBENCH_FOR_rtc 
wave 
wave -noreg clk_1hz
wave -noreg rst
wave -noreg btn_time
wave -noreg btn_hour
wave -noreg btn_min
wave -noreg sec_out
wave -noreg min_out
wave -noreg hour_out
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\rtc_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_rtc 
