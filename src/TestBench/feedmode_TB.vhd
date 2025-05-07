library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity feedmode_tb is
end feedmode_tb;

architecture TB_ARCHITECTURE of feedmode_tb is
    -- Component declaration of the tested unit
    component feedmode
    port(
        compclock  : in  STD_LOGIC;
        clk_1hz    : in  STD_LOGIC;
        feed_mode  : in  STD_LOGIC;
        Feed_Pumps : out STD_LOGIC;  
        skimmer    : out STD_LOGIC
    );
    end component;

    -- Stimulus signals
    signal compclock  : STD_LOGIC := '0';
    signal clk_1hz    : STD_LOGIC := '0';
    signal feed_mode  : STD_LOGIC := '0';
    signal Feed_Pumps : STD_LOGIC;   
    signal skimmer    : STD_LOGIC;

begin

    -- Unit Under Test port map
    UUT : feedmode
        port map (
            compclock  => compclock,
            clk_1hz    => clk_1hz,
            feed_mode  => feed_mode,
            Feed_Pumps => Feed_Pumps,
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

    -- fake 1hz clock
    clk1hz_proc : process
    begin
        loop
            clk_1hz <= '0';
            wait for 0.5 ms;
            clk_1hz <= '1';
            wait for 0.5 ms;
        end loop;
    end process;

    -- Stimulus Process
    stimulus : process
    begin
        
        wait for 2 ms;

        -- Trigger feed mode
        feed_mode <= '1';
        wait for 1 ms;
        feed_mode <= '0';

        wait for 20 ms; 

        -- End simulation
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