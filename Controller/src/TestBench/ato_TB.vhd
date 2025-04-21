library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

entity ato_tb is
end ato_tb;

architecture TB_ARCHITECTURE of ato_tb is

    -- Component declaration of the tested unit
    component ato
        port(
            clk_1hz    : in  STD_LOGIC;
            compclock  : in  STD_LOGIC;
            ATO_RESET  : in  STD_LOGIC;
            S1ATO      : in  STD_LOGIC;
            S2ATO      : in  STD_LOGIC;
            ATO_PUMP   : out STD_LOGIC;
            ATO_ERROR  : out STD_LOGIC
        );
    end component;

    -- Stimulus signals
    signal clk_1hz    : STD_LOGIC := '0';
    signal compclock  : STD_LOGIC := '0';
    signal ATO_RESET  : STD_LOGIC := '0';
    signal S1ATO      : STD_LOGIC := '1'; -- Default: tank full
    signal S2ATO      : STD_LOGIC := '0'; -- Default: not overfill
    signal ATO_PUMP   : STD_LOGIC;
    signal ATO_ERROR  : STD_LOGIC;

begin

    -- Unit Under Test port map
    UUT : ato
        port map (
            clk_1hz    => clk_1hz,
            compclock  => compclock,
            ATO_RESET  => ATO_RESET,
            S1ATO      => S1ATO,
            S2ATO      => S2ATO,
            ATO_PUMP   => ATO_PUMP,
            ATO_ERROR  => ATO_ERROR
        );

    -- 200 MHz compclock
    compclock_process : process
    begin
        while true loop
            compclock <= '0';
            wait for 5 ns;
            compclock <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- 50 MHz clk_1hz for simulation speed-up (20 ns period)
    clk_1hz_process : process
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
        -- Initial reset
        ATO_RESET <= '1';
        wait for 100 ns;
        ATO_RESET <= '0';

        -- Wait before beginning test
        wait for 100 ns;

        -- Normal fill: S1 low, S2 low
        S1ATO <= '0';
        S2ATO <= '0';
        wait for 1000 ns;

        -- Recovery: S1 high
        S1ATO <= '1';
        wait for 100 ns;

        -- Timeout test: S1 stays low, S2 low
        S1ATO <= '0';
        S2ATO <= '0';
        wait for 1300 ns;

        -- Sensor 2 test case: simulate S2 trigger during fill
        S1ATO <= '0';
        S2ATO <= '1';  -- simulate overfill condition
        wait for 200 ns;

        -- Apply second reset pulse to clear error state
        ATO_RESET <= '1';
        wait for 100 ns;
        ATO_RESET <= '0';

        -- Hold for observation
        wait for 200 ns;

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
