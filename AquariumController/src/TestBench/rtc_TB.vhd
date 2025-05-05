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
	signal clk_1hz   : STD_LOGIC ;
	signal rst       : STD_LOGIC;
	signal btn_time  : STD_LOGIC;
	signal btn_hour  : STD_LOGIC;
	signal btn_min   : STD_LOGIC;
	signal sec_out   : UNSIGNED(5 downto 0);
	signal min_out   : UNSIGNED(5 downto 0);
	signal hour_out  : UNSIGNED(4 downto 0);

begin

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

	-- Simulate a real-time 1Hz clock (1 second period)
	clk_process: process
	begin
		loop
			clk_1hz <= '0';
			wait for 500 ms;
			clk_1hz <= '1';
			wait for 500 ms;
		end loop;
	end process;

	stim_proc: process
	begin
		-- Assert reset
		rst <= '1';
		wait for 1 sec;
		rst <= '0';

		-- Wait briefly before time set
		wait for 2 sec;

		-- Enter time set mode
		btn_time <= '1';
		wait for 1 sec;

		-- Increment hour to 23
		for i in 1 to 23 loop
			btn_hour <= '1';
			wait for 1 sec;
			btn_hour <= '0';
			wait for 1 sec;
		end loop;

		-- Increment minute to 58
		for i in 1 to 58 loop
			btn_min <= '1';
			wait for 1 sec;
			btn_min <= '0';
			wait for 1 sec;
		end loop;

		-- Exit time set mode
		btn_time <= '0';
		wait for 1 sec;

		-- Let RTC run normally for 10 seconds
		wait for 10 sec;

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
