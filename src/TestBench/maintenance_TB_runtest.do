SetActiveLib -work
comp -include "$dsn\src\Maitenence.vhd" 
comp -include "$dsn\src\TestBench\maintenance_TB.vhd" 
asim +access +r TESTBENCH_FOR_maintenance 
wave 
wave -noreg compclock
wave -noreg swmaint
wave -noreg holdheat
wave -noreg maint_pumps
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\maintenance_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_maintenance 
