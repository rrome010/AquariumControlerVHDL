library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

entity ato_tb is
end ato_tb;

architecture TB_ARCHITECTURE of ato_tb is

    -- Component declaration of the tested unit
    component ato
        port(
            clk_1hz        : in  STD_LOGIC;
            compclock      : in  STD_LOGIC;
            ATO_RESET      : in  STD_LOGIC;
            maintenance_in : in  STD_LOGIC;
            S1ATO          : in  STD_LOGIC;
            S2ATO          : in  STD_LOGIC;
            ATO_PUMP       : out STD_LOGIC;
            ATO_ERROR      : out STD_LOGIC
        );
    end component;

    -- Stimulus signals
    signal clk_1hz        : STD_LOGIC := '0';
    signal compclock      : STD_LOGIC := '0';
    signal ATO_RESET      : STD_LOGIC := '0';
    signal maintenance_in : STD_LOGIC := '0';
    signal S1ATO          : STD_LOGIC := '1'; -- Default: tank full
    signal S2ATO          : STD_LOGIC := '0'; -- Default: not overfill
    signal ATO_PUMP       : STD_LOGIC;
    signal ATO_ERROR      : STD_LOGIC;

begin

    -- Unit Under Test port map
    UUT : ato
        port map (
            clk_1hz        => clk_1hz,
            compclock      => compclock,
            ATO_RESET      => ATO_RESET,
            maintenance_in => maintenance_in,
            S1ATO          => S1ATO,
            S2ATO          => S2ATO,
            ATO_PUMP       => ATO_PUMP,
            ATO_ERROR      => ATO_ERROR
        );

    -- 1 kHz compclock (period = 1ms)
    compclock_process : process
    begin
        while true loop
            compclock <= '0';
            wait for 500000 ns; 
            compclock <= '1';
            wait for 500000 ns; 
        end loop;
    end process;

    -- 1 Hz clock (period = 1s)
    clk_1hz_process : process
    begin
        while true loop
            clk_1hz <= '0';
            wait for 500000000 ns; 
            clk_1hz <= '1';
            wait for 500000000 ns; 
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset
        ATO_RESET <= '1';
        wait for 2 sec;
        ATO_RESET <= '0';

        wait for 2 sec;

        -- Normal fill: S1 low, S2 low (simulate water drop)
        S1ATO <= '0';
        S2ATO <= '0';
        wait for 5 sec;

        -- Recovery: S1 high (tank filled back up)
        S1ATO <= '1';
        wait for 2 sec;

        -- Timeout test: S1 stays low, S2 low (simulate pump running too long)
        S1ATO <= '0';
        S2ATO <= '0';
        wait for 130 sec; -- simulate long fill (over timeout)

        -- Sensor 2 test case: simulate S2 triggering (overfill error)
        S1ATO <= '0';
        S2ATO <= '1';
        wait for 2 sec;

        -- Apply reset to clear error
        ATO_RESET <= '1';
        wait for 2 sec;
        ATO_RESET <= '0';

        wait for 2 sec;

        -- Now simulate entering maintenance mode
        maintenance_in <= '1';
        wait for 5 sec;

        -- Try to cause fill while in maintenance (should ignore)
        S1ATO <= '0';
        S2ATO <= '0';
        wait for 5 sec;

        -- Exit maintenance mode
        maintenance_in <= '0';
        wait for 2 sec;

        -- Resume normal operation
        S1ATO <= '0';
        S2ATO <= '0';
        wait for 5 sec;

        -- Simulate full again
        S1ATO <= '1';
        wait for 2 sec;
		S2ATO <= '1';
        wait for 10 sec;	
		maintenance_in <= '1';
        wait for 2 sec;
        -- Hold forever to observe behavior
        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_ato of ato_tb is
    for TB_ARCHITECTURE
        for UUT : ato
            use entity work.ato(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_ato;
