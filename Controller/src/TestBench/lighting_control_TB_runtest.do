SetActiveLib -work
comp -include "$dsn\src\Lighting control.vhd" 
comp -include "$dsn\src\TestBench\lighting_control_TB.vhd" 
asim +access +r TESTBENCH_FOR_lighting_control 
wave 
wave -noreg compclock
wave -noreg reset_lights
wave -noreg btn_time_lights_on
wave -noreg btn_time_lights_of
wave -noreg btn_hour
wave -noreg btn_min
wave -noreg min_out
wave -noreg hour_out
wave -noreg min_on
wave -noreg hour_on
wave -noreg min_off
wave -noreg hour_off
wave -noreg Light_on_off
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\lighting_control_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_lighting_control 
