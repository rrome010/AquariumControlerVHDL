SetActiveLib -work
comp -include "$dsn\src\ATO.vhd" 
comp -include "$dsn\src\TestBench\ato_TB.vhd" 
asim +access +r TESTBENCH_FOR_ato 
wave 
wave -noreg clk_1hz
wave -noreg compclock
wave -noreg ATO_RESET
wave -noreg S1ATO
wave -noreg S2ATO
wave -noreg ATO_PUMP
wave -noreg ATO_ERROR
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\ato_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_ato 
