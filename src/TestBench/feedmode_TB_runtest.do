SetActiveLib -work
comp -include "$dsn\src\Feed mode.vhd" 
comp -include "$dsn\src\TestBench\feedmode_TB.vhd" 
asim +access +r TESTBENCH_FOR_feedmode 
wave 
wave -noreg compclock
wave -noreg clk_1hz
wave -noreg feed_mode
wave -noreg pumps
wave -noreg skimmer
wave -noreg feed_counter
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\feedmode_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_feedmode 
