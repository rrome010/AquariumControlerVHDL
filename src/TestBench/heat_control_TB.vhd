library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

entity heat_control_tb is
end heat_control_tb;

architecture TB_ARCHITECTURE of heat_control_tb is
    -- Component declaration
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

    -- Signals
    signal Hold_Heat       : STD_LOGIC := '0';
    signal compclock       : STD_LOGIC := '0';
    signal reset_heat      : STD_LOGIC := '0';
    signal btn_change_temp : STD_LOGIC := '0';
    signal btn_temp_up     : STD_LOGIC := '0';
    signal btn_temp_down   : STD_LOGIC := '0';
    signal CurrentTemp     : UNSIGNED(12 downto 0) := to_unsigned(408,13);
    signal min_out         : UNSIGNED(5 downto 0) := (others => '0');

    signal tempmax         : UNSIGNED(12 downto 0);
    signal tempuser        : UNSIGNED(12 downto 0);
    signal tempmin         : UNSIGNED(12 downto 0);
    signal heater          : STD_LOGIC;
    signal TempError       : STD_LOGIC;

begin

    -- Instantiate the Unit Under Test (UUT)
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

    -- 1kHz compclock (1 ms period)
    compclock_process : process
    begin
        while true loop
            compclock <= '0';
            wait for 0.5 ms;
            compclock <= '1';
            wait for 0.5 ms;
        end loop;
    end process;

    -- Simulated minute counter
min_out_process : process
begin
    while true loop
        wait for 1 sec;

        if min_out = to_unsigned(59, 6) then
            min_out <= to_unsigned(0, 6);
        else
            min_out <= min_out + 1;
        end if;
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


        -- NORMAL operation
        CurrentTemp <= to_unsigned(396,13); -- 24.75°C
        wait for 5 sec;


        -- Reach setpoint: heat off

        CurrentTemp <= to_unsigned(409,13); -- 25.56°C
        wait for 5 sec;


        -- Over-temp triggers ERROR
 
        CurrentTemp <= to_unsigned(420,13); -- 26.25°C
        wait for 5 sec;


        -- Cooling test error
        CurrentTemp <= to_unsigned(407,13);
        wait for 5 sec;


        -- Reset to clear ERROR
        reset_heat <= '1';
        wait for 2 ms;
        reset_heat <= '0';
        wait for 5 sec;


        -- Increase set temp
        btn_change_temp <= '1';
        btn_temp_up <= '1';
        wait for 2 ms;
        btn_change_temp <= '0';
        btn_temp_up <= '0';
        wait for 5 sec;

        -- Decrease set temp
        btn_change_temp <= '1';
        btn_temp_down <= '1';
        wait for 2 ms;
        btn_change_temp <= '0';
        btn_temp_down <= '0';
        wait for 5 sec;
		
		-- Enter MAINTENANCE mode (should disable heater & clear error)
        Hold_Heat <= '1';
        wait for 5 sec;

        -- undertemp
        CurrentTemp <= to_unsigned(390,13); -- 24.375°C
        wait for 5 sec;

        -- Exit MAINTENANCE
        Hold_Heat <= '0';
        wait for 5 sec;

        -- Trigger timeot
        wait for 60 sec;

        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_heat_control of heat_control_tb is
    for TB_ARCHITECTURE
        for UUT : heat_control
            use entity work.heat_control(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_heat_control;
