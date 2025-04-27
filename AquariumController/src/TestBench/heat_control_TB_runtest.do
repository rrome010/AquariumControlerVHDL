SetActiveLib -work
comp -include "$dsn\src\Heat control.vhd" 
comp -include "$dsn\src\TestBench\heat_control_TB.vhd" 
asim +access +r TESTBENCH_FOR_heat_control 
wave 
wave -noreg Hold_Heat
wave -noreg compclock
wave -noreg reset_heat
wave -noreg btn_change_temp
wave -noreg btn_temp_up
wave -noreg btn_temp_down
wave -noreg CurrentTemp
wave -noreg min_out
wave -noreg tempmax
wave -noreg tempuser
wave -noreg tempmin
wave -noreg heater
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\heat_control_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_heat_control 
