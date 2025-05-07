library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevel_tb is
end TopLevel_tb;

architecture Behavioral of TopLevel_tb is

    -- Clock and Reset
    signal clk_1hz        : std_logic := '0';
    signal compclock      : std_logic := '0';
    signal reset          : std_logic := '0';

    -- Inputs
    signal sw_maint       : std_logic := '0';
    signal test_mode      : std_logic := '0';
    signal S1ATO_override : std_logic := '1';
    signal S2ATO_override : std_logic := '0';
    signal CurrentTemp_override : unsigned(12 downto 0) := to_unsigned(408, 13);

    signal btn_time             : std_logic := '0';
    signal btn_hour             : std_logic := '0';
    signal btn_min              : std_logic := '0';
    signal btn_time_lights_on   : std_logic := '0';
    signal btn_time_lights_of   : std_logic := '0';
    signal btn_light_hour       : std_logic := '0';
    signal btn_light_min        : std_logic := '0';
    signal btn_change_temp      : std_logic := '0';
    signal btn_temp_up          : std_logic := '0';
    signal btn_temp_down        : std_logic := '0';

    -- Outputs
    signal heater_out     : std_logic;
    signal light_out      : std_logic;
    signal ato_pump_out   : std_logic;

    signal min_on_out     : unsigned(5 downto 0);
    signal hour_on_out    : unsigned(4 downto 0);
    signal min_off_out    : unsigned(5 downto 0);
    signal hour_off_out   : unsigned(4 downto 0);
    signal tempuser_out   : unsigned(12 downto 0);

    signal light_on_off   : std_logic;
    signal ATO_ERROR      : std_logic;
    signal TempError      : std_logic;
    signal sec_out_debug  : unsigned(5 downto 0);
    signal min_out_debug  : unsigned(5 downto 0);
    signal hour_out_debug : unsigned(4 downto 0);
    signal tempuser_debug : unsigned(12 downto 0);
    signal tempmax_debug  : unsigned(12 downto 0);
    signal tempmin_debug  : unsigned(12 downto 0);
    signal min_on_debug   : unsigned(5 downto 0);
    signal hour_on_debug  : unsigned(4 downto 0);
    signal min_off_debug  : unsigned(5 downto 0);
    signal hour_off_debug : unsigned(4 downto 0);

    signal Feed : std_logic := '0';
    signal Skimmer : std_logic;
    signal Pumps : std_logic;

begin

    uut: entity work.TopLevel
    port map (
        clk_1hz => clk_1hz,
        compclock => compclock,
        reset => reset,
        sw_maint => sw_maint,
        heater_out => heater_out,
        light_out => light_out,
        ato_pump_out => ato_pump_out,
        min_on_out => min_on_out,
        hour_on_out => hour_on_out,
        min_off_out => min_off_out,
        hour_off_out => hour_off_out,
        tempuser_out => tempuser_out,
        light_on_off => light_on_off,
        ATO_ERROR => ATO_ERROR,
        TempError => TempError,
        sec_out_debug => sec_out_debug,
        min_out_debug => min_out_debug,
        hour_out_debug => hour_out_debug,
        tempuser_debug => tempuser_debug,
        tempmax_debug => tempmax_debug,
        tempmin_debug => tempmin_debug,
        min_on_debug => min_on_debug,
        hour_on_debug => hour_on_debug,
        min_off_debug => min_off_debug,
        hour_off_debug => hour_off_debug,
        
        S1ATO_override => S1ATO_override,
        S2ATO_override => S2ATO_override,
        CurrentTemp_override => CurrentTemp_override,
        btn_time => btn_time,
        btn_hour => btn_hour,
        btn_min => btn_min,
        btn_time_lights_on => btn_time_lights_on,
        btn_time_lights_of => btn_time_lights_of,
        btn_light_hour => btn_light_hour,
        btn_light_min => btn_light_min,
        btn_change_temp => btn_change_temp,
        btn_temp_up => btn_temp_up,
        btn_temp_down => btn_temp_down,
        Feed => Feed,
        Skimmer => Skimmer,
        pumps => pumps
    );

    -- "Simulated" 1Hz clock (1 ms period)
    clk1hz_proc: process
    begin
        loop
            clk_1hz <= '0';
            wait for 0.5 ms;
            clk_1hz <= '1';
            wait for 0.5 ms;
        end loop;
    end process;

    -- 100 MHz system clock (10 ns period)
    compclock_proc: process
    begin
        loop
            compclock <= '0';
            wait for 5 ns;
            compclock <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Stimulus process
    stimulus_proc: process
    begin
        
        reset <= '1'; -- initial reset
        wait for 1 ms;
        reset <= '0';

        --RTC time input
        btn_time <= '1'; --change time to 8:29
        wait for 1 ms;
        for i in 1 to 8 loop
            btn_hour <= '1'; wait for 1 ms; btn_hour <= '0'; wait for 1 ms;
        end loop;
        for i in 1 to 29 loop
            btn_min <= '1'; wait for 1 ms; btn_min <= '0'; wait for 1 ms;
        end loop;
        btn_time <= '0';
        wait for 2 ms;
--
--        btn_time_lights_on <= '1'; --change light on to 8:30
--        wait for 1 ms;
--        for i in 1 to 8 loop
--            btn_light_hour <= '1'; wait for 1 ms; btn_light_hour <= '0'; wait for 1 ms;
--        end loop;
--        for i in 1 to 30 loop
--            btn_light_min <= '1'; wait for 1 ms; btn_light_min <= '0'; wait for 1 ms;
--        end loop;
--        btn_time_lights_on <= '0';
--        wait for 2 ms;
--
--        --Lighting time input    
--        btn_time_lights_of <= '1'; --change lights off time to 4 pm / 16:00
--        wait for 1 ms;
--        for i in 1 to 8 loop
--            btn_light_hour <= '1'; wait for 1 ms; btn_light_hour <= '0'; wait for 1 ms;
--        end loop;
--        for i in 1 to 30 loop
--            btn_light_min <= '1'; wait for 1 ms; btn_light_min <= '0'; wait for 1 ms;
--        end loop;
--        btn_time_lights_on <= '0';
--        btn_time_lights_of <= '0';
--        wait for 2 ms;
		  btn_time_lights_on <= '1'; -- Set light on time mode
wait for 10 ns;

for i in 1 to 8 loop
    btn_light_hour <= '1'; wait for 10 ns;
    btn_light_hour <= '0'; wait for 10 ns;
end loop;

for i in 1 to 30 loop
    btn_light_min <= '1'; wait for 10 ns;
    btn_light_min <= '0'; wait for 10 ns;
end loop;

btn_time_lights_on <= '0';
wait for 20 ns;

-- Lighting OFF time input
btn_time_lights_of <= '1'; -- Set lights off to 16:00
wait for 10 ns;

for i in 1 to 16 loop
    btn_light_hour <= '1'; wait for 10 ns;
    btn_light_hour <= '0'; wait for 10 ns;
end loop;
btn_time_lights_of <= '0'; wait for 65 ms;




        --lighting test
        btn_time <= '1'; --advance time to watch lights go out
        wait for 1 ms;
        for i in 1 to 7 loop
            btn_hour <= '1'; wait for 1 ms; btn_hour <= '0'; wait for 1 ms;
        end loop;
        for i in 1 to 27 loop
            btn_min <= '1'; wait for 1 ms; btn_min <= '0'; wait for 1 ms;
        end loop;
        btn_time <= '0';
        wait for 1 ms;

        --temp tests
        CurrentTemp_override <= to_unsigned(392, 13); --set temp low to view heater behavior in maintenance mode
        wait for 2 ms;
        sw_maint <= '1';
        wait for 5 ms;
        sw_maint <= '0';
        wait for 5 ms;
        CurrentTemp_override <= to_unsigned(408, 13); --set temp to expected temp
        wait for 2 ms;

        btn_change_temp <= '1';--test max, user, min temps
        wait for 2 ms;
        btn_temp_up <= '1'; wait for 1 ms; btn_temp_up <= '0';
        wait for 2 ms;
        btn_change_temp <= '0';
        wait for 1 ms;
        btn_change_temp <= '1';
        wait for 2 ms;
        btn_temp_down <= '1'; wait for 1 ms; btn_temp_down <= '0';
        wait for 2 ms;
        btn_change_temp <= '0';
        wait for 1 ms;

        CurrentTemp_override <= to_unsigned(350, 13); --set temp low and wait for heater timeout
        wait for 2 ms;

        --ATO tests/Maintenance test
        S1ATO_override <= '0'; S2ATO_override <= '0'; wait for 5 ms;--ato testing
        S1ATO_override <= '1'; wait for 5 ms;--test if ato activates
        S1ATO_override <= '0'; wait for 8 ms;
        sw_maint <= '1'; wait for 5 ms; --reset/ test maint mode/ skimmer, heater, ato pumps
        sw_maint <= '0'; wait for 5 ms;
        S1ATO_override <= '1'; S2ATO_override <= '1'; wait for 5 ms; --test ato error overflow
        S2ATO_override <= '1'; wait for 2 ms;
        sw_maint <= '1'; wait for 5 ms; --reset ato error
        sw_maint <= '0'; wait for 5 ms;
        S1ATO_override <= '0'; 
        S2ATO_override <= '1'; wait for 5 ms;--test ato sensor error
        sw_maint <= '1'; wait for 5 ms; --reset
        sw_maint <= '0'; wait for 5 ms; 
        S1ATO_override <= '1'; --test ato timeout
        S2ATO_override <= '0'; 
        wait for 10 ms;
        sw_maint <= '1'; wait for 5 ms; --reset
        sw_maint <= '0'; wait for 5 ms;
		 S1ATO_override <= '0'; -- wait for timeout
        
            
        --Feed mode test    
        Feed <= '1'; --test feed mode// wait to make sure pumps/ skimmer come back on
        wait for 5 ms;
        Feed <= '0'; 

        wait;
    end process;

end Behavioral;
