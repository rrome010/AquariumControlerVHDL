library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SimHeatADC_tb is
end SimHeatADC_tb;

architecture TB_ARCHITECTURE of SimHeatADC_tb is

    -- Component declaration of the tested unit
    component SimHeatADC
        port(
            clk_1mhz         : in  std_logic;
            one_wire         : out std_logic;
            currentTempsim   : out unsigned(11 downto 0)
        );
    end component;

    -- Stimulus signals
    signal clk_1mhz         : std_logic := '0';
    signal one_wire         : std_logic;
    signal currentTempsim   : unsigned(11 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT : SimHeatADC
        port map (
            clk_1mhz         => clk_1mhz,
            one_wire         => one_wire,
            currentTempsim   => currentTempsim
        );

    -- Clock process to generate 1 MHz clock (1 us period)
    clk_process : process
    begin
        while now < 3 sec loop
            clk_1mhz <= '0';
            wait for 500 ns;
            clk_1mhz <= '1';
            wait for 500 ns;
        end loop;
        wait;
    end process;

end TB_ARCHITECTURE;


configuration TESTBENCH_FOR_SimHeatADC of SimHeatADC_tb is
    for TB_ARCHITECTURE
        for UUT : SimHeatADC
            use entity work.SimHeatADC(behavior);
        end for;
    end for;
end TESTBENCH_FOR_SimHeatADC;
