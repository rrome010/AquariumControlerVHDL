library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity feedmode_tb is
end feedmode_tb;

architecture TB_ARCHITECTURE of feedmode_tb is
    -- Component declaration of the tested unit
    component feedmode
    port(
        compclock : in STD_LOGIC;
        clk_1hz   : in STD_LOGIC;
        feed_mode : in STD_LOGIC;
        feed_pumps : out STD_LOGIC;  
        skimmer    : out STD_LOGIC
    );
    end component;

    -- Stimulus signals
    signal compclock  : STD_LOGIC := '0';
    signal clk_1hz    : STD_LOGIC := '0';
    signal feed_mode  : STD_LOGIC := '0';
    signal feed_pumps : STD_LOGIC;   
    signal skimmer    : STD_LOGIC;

begin

    -- Unit Under Test port map
    UUT : feedmode
        port map (
            compclock  => compclock,
            clk_1hz    => clk_1hz,
            feed_mode  => feed_mode,
            feed_pumps => feed_pumps,  
            skimmer    => skimmer
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

    -- 1Hz clock simulation 
    clk1hz_proc : process
    begin
        loop
            clk_1hz <= '0';
            wait for 0.5 ms;   -- <<< FIX: real 1Hz: 1ms cycle (0.5ms low + 0.5ms high)
            clk_1hz <= '1';
            wait for 0.5 ms;
        end loop;
    end process;

    -- Stimulus Process
    stimulus : process
    begin
        -- Wait for system to stabilize
        wait for 2 ms;

        -- Enter feed mode
        feed_mode <= '1';
        wait for 1 ms; -- short pulse
        feed_mode <= '0';

        -- Let the system process for a while
        wait for 10 sec;  

        -- Simulation done
        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_feedmode of feedmode_tb is
    for TB_ARCHITECTURE
        for UUT : feedmode
            use entity work.feedmode(Behavioral);
        end for;
    end for;
end TESTBENCH_FOR_feedmode;
