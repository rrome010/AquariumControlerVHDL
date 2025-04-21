SetActiveLib -work
comp -include "$dsn\src\SimHeatADC.vhd" 
comp -include "$dsn\src\TestBench\simheatadc_TB.vhd" 
asim +access +r TESTBENCH_FOR_simheatadc 
wave 
wave -noreg clk_us
wave -noreg one_wire
wave -noreg currentTempsim
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\simheatadc_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_simheatadc 
