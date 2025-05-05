library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

entity maintenance_tb is
end maintenance_tb;

architecture TB_ARCHITECTURE of maintenance_tb is
	-- Component declaration of the tested unit
	component maintenance
	port(
		compclock    : in  STD_LOGIC;
		swmaint      : in  STD_LOGIC;
		holdheat     : out STD_LOGIC;
		maint_pumps  : out STD_LOGIC
	);
	end component;

	-- Stimulus signals
	signal compclock   : STD_LOGIC;
	signal swmaint     : STD_LOGIC;

	-- Observed signals
	signal holdheat    : STD_LOGIC;
	signal maint_pumps : STD_LOGIC;

begin

	-- Unit Under Test port map
	UUT : maintenance
		port map (
			compclock    => compclock,
			swmaint      => swmaint,
			holdheat     => holdheat,
			maint_pumps  => maint_pumps
		);

	-- 100MHz compclock generation (10 ns period)
	compclock_proc : process
	begin
		loop
			compclock <= '0';
			wait for 5 ns;
			compclock <= '1';
			wait for 5 ns;
		end loop;
	end process;

	-- Stimulus process to simulate maintenance switch
	stimulus : process
	begin
		-- Initial state
		swmaint <= '0';
		wait for 100 ns;

		-- Activate maintenance mode
		swmaint <= '1';
		wait for 200 ns;

		-- Deactivate maintenance mode
		swmaint <= '0';
		wait for 200 ns;

		-- Reactivate maintenance mode
		swmaint <= '1';
		wait for 200 ns;

		-- Finish simulation
		wait;
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_maintenance of maintenance_tb is
	for TB_ARCHITECTURE
		for UUT : maintenance
			use entity work.maintenance(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_maintenance;