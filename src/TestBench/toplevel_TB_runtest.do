SetActiveLib -work
comp -include "C:\Users\Robert\Downloads\TopLevel.vhd" 
comp -include "$dsn\src\TestBench\toplevel_TB.vhd" 
asim +access +r TESTBENCH_FOR_toplevel 
wave 
wave -noreg clk_1hz
wave -noreg compclock
wave -noreg reset
wave -noreg btn_feed
wave -noreg sw_maint
wave -noreg heater_out
wave -noreg light_on_off
wave -noreg ato_pump_out
wave -noreg ATO_ERROr
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\toplevel_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_toplevel 
