library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

entity rtc_tb is
end rtc_tb;

architecture TB_ARCHITECTURE of rtc_tb is
	component rtc
		port(
			clk_1hz   : in  STD_LOGIC;
			rst       : in  STD_LOGIC;
			btn_time  : in  STD_LOGIC;
			btn_hour  : in  STD_LOGIC;
			btn_min   : in  STD_LOGIC;
			sec_out   : out UNSIGNED(5 downto 0);
			min_out   : out UNSIGNED(5 downto 0);
			hour_out  : out UNSIGNED(4 downto 0)
		);
	end component;

	-- Signals
	signal clk_1hz   : STD_LOGIC := '0';
	signal rst       : STD_LOGIC := '0';
	signal btn_time  : STD_LOGIC := '0';
	signal btn_hour  : STD_LOGIC := '0';
	signal btn_min   : STD_LOGIC := '0';
	signal sec_out   : UNSIGNED(5 downto 0);
	signal min_out   : UNSIGNED(5 downto 0);
	signal hour_out  : UNSIGNED(4 downto 0);

begin

	-- Instantiate the UUT
	UUT: rtc
		port map (
			clk_1hz   => clk_1hz,
			rst       => rst,
			btn_time  => btn_time,
			btn_hour  => btn_hour,
			btn_min   => btn_min,
			sec_out   => sec_out,
			min_out   => min_out,
			hour_out  => hour_out
		);

	-- 10 ns clock generation (100 MHz)
	clk_process: process
	begin
		while true loop
			clk_1hz <= '0';
			wait for 10 ns;
			clk_1hz <= '1';
			wait for 10 ns;
		end loop;
	end process;

	-- Stimulus process
	stim_proc: process
	begin
		-- Assert reset
		rst <= '1';
		wait for 20 ns;
		rst <= '0';

		-- Let it run for 200 ns (20 clock ticks)
		wait for 200 ns;

		-- Enter time set mode
		btn_time <= '1';

		-- Pulse hour button once (1 clock tick)
		btn_hour <= '1';
		wait for 10 ns;
		btn_hour <= '0';

		-- Wait a few ticks
		wait for 30 ns;

		-- Pulse minute button twice
		btn_min <= '1';
		wait for 10 ns;
		btn_min <= '0';
		wait for 20 ns;
		btn_min <= '1';
		wait for 10 ns;
		btn_min <= '0';

		-- Exit time set mode
		wait for 20 ns;
		btn_time <= '0';

		-- Let clock tick normally for another 100 ns
		wait for 100 ns;

		-- End simulation
		wait;
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_rtc of rtc_tb is
	for TB_ARCHITECTURE
		for UUT : rtc
			use entity work.rtc(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_rtc;
