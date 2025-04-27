library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

entity heat_control_tb is
end heat_control_tb;

architecture TB_ARCHITECTURE of heat_control_tb is
    -- Component declaration of the tested unit
    component heat_control
        port(
            Hold_Heat       : in STD_LOGIC;
            compclock       : in STD_LOGIC;
            reset_heat      : in STD_LOGIC;
            btn_change_temp : in STD_LOGIC;
            btn_temp_up     : in STD_LOGIC;
            btn_temp_down   : in STD_LOGIC;
            CurrentTemp     : in UNSIGNED(12 downto 0);
            min_out         : in UNSIGNED(5 downto 0);
            tempmax         : out UNSIGNED(12 downto 0);
            tempuser        : out UNSIGNED(12 downto 0);
            tempmin         : out UNSIGNED(12 downto 0);
            heater          : out STD_LOGIC;
            TempError       : out STD_LOGIC
        );
    end component;

    -- Stimulus signals
    signal Hold_Heat       : STD_LOGIC := '0';
    signal compclock       : STD_LOGIC := '0';
    signal reset_heat      : STD_LOGIC := '0';
    signal btn_change_temp : STD_LOGIC := '0';
    signal btn_temp_up     : STD_LOGIC := '0';
    signal btn_temp_down   : STD_LOGIC := '0';
    signal CurrentTemp     : UNSIGNED(12 downto 0) := to_unsigned(408,13); -- Start at 25.5°C
    signal min_out         : UNSIGNED(5 downto 0) := (others => '0');

    -- Observed signals
    signal tempmax         : UNSIGNED(12 downto 0);
    signal tempuser        : UNSIGNED(12 downto 0);
    signal tempmin         : UNSIGNED(12 downto 0);
    signal heater          : STD_LOGIC;
    signal TempError       : STD_LOGIC;

begin

    -- Unit Under Test port map
    UUT : heat_control
        port map (
            Hold_Heat       => Hold_Heat,
            compclock       => compclock,
            reset_heat      => reset_heat,
            btn_change_temp => btn_change_temp,
            btn_temp_up     => btn_temp_up,
            btn_temp_down   => btn_temp_down,
            CurrentTemp     => CurrentTemp,
            min_out         => min_out,
            tempmax         => tempmax,
            tempuser        => tempuser,
            tempmin         => tempmin,
            heater          => heater,
            TempError       => TempError
        );

    -- 1kHz compclock generation
    compclock_process : process
    begin
        while true loop
            compclock <= '0';
            wait for 500000 ns;
            compclock <= '1';
            wait for 500000 ns;
        end loop;
    end process;

    -- Simulate min_out as time counter
    min_out_process : process
    begin
        while true loop
            wait for 1 sec;
            min_out <= min_out + 1;
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- Initial reset
        reset_heat <= '1';
        wait for 2 ms;
        reset_heat <= '0';
        wait for 5 ms;

        -- Normal heating: simulate under-temp
        CurrentTemp <= to_unsigned(396,13); -- 24.75°C
        wait for 5 sec;

        -- Reaching normal temp
        CurrentTemp <= to_unsigned(409,13); -- 25.56°C
        wait for 5 sec;

        -- Simulate overheating (should trigger ERROR immediately)
        CurrentTemp <= to_unsigned(420,13); -- 26.25°C
        wait for 5 sec;

        -- Cooling down (should still stay in ERROR state)
        CurrentTemp <= to_unsigned(407,13); -- 25.43°C
        wait for 5 sec;

        -- Apply reset to clear ERROR
        reset_heat <= '1';
        wait for 2 ms;
        reset_heat <= '0';
        wait for 5 sec;

        -- Test increasing temp setpoint
        btn_change_temp <= '1';
        btn_temp_up <= '1';
        wait for 2 ms;
        btn_change_temp <= '0';
        btn_temp_up <= '0';
        wait for 5 sec;

        -- Test decreasing temp setpoint
        btn_change_temp <= '1';
        btn_temp_down <= '1';
        wait for 2 ms;
        btn_change_temp <= '0';
        btn_temp_down <= '0';
        wait for 5 sec;

        -- Enter maintenance mode
        Hold_Heat <= '1';
        wait for 5 sec;

        -- During Hold: simulate temp drop (heater should stay OFF)
        CurrentTemp <= to_unsigned(390,13); -- 24.375°C
        wait for 5 sec;

        -- Exit maintenance mode
        Hold_Heat <= '0';
        wait for 5 sec;

        -- After maintenance: simulate temp low again (heater ON)
        CurrentTemp <= to_unsigned(396,13);
        wait for 5 sec;

        wait; -- End simulation
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_heat_control of heat_control_tb is
    for TB_ARCHITECTURE
        for UUT : heat_control
            use entity work.heat_control(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_heat_control;
