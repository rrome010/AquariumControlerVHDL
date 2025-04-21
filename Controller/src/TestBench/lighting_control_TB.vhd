library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

entity lighting_control_tb is
end lighting_control_tb;

architecture TB_ARCHITECTURE of lighting_control_tb is

    -- Component declaration of the tested unit
    component lighting_control
        port(
            compclock : in STD_LOGIC;
            reset_lights : in STD_LOGIC;
            btn_time_lights_on : in STD_LOGIC;
            btn_time_lights_of : in STD_LOGIC;
            btn_hour : in STD_LOGIC;
            btn_min : in STD_LOGIC;
            min_out : in UNSIGNED(5 downto 0);
            hour_out : in UNSIGNED(4 downto 0);
            min_on : out UNSIGNED(5 downto 0);
            hour_on : out UNSIGNED(4 downto 0);
            min_off : out UNSIGNED(5 downto 0);
            hour_off : out UNSIGNED(4 downto 0);
            Light_on_off : out BIT
        );
    end component;

    -- Stimulus signals - input
    signal compclock           : STD_LOGIC := '0';
    signal reset_lights        : STD_LOGIC := '0';
    signal btn_time_lights_on  : STD_LOGIC := '0';
    signal btn_time_lights_of  : STD_LOGIC := '0';
    signal btn_hour            : STD_LOGIC := '0';
    signal btn_min             : STD_LOGIC := '0';
    signal min_out             : UNSIGNED(5 downto 0) := (others => '0');
    signal hour_out            : UNSIGNED(4 downto 0) := (others => '0');

    -- Observed signals - output
    signal min_on              : UNSIGNED(5 downto 0);
    signal hour_on             : UNSIGNED(4 downto 0);
    signal min_off             : UNSIGNED(5 downto 0);
    signal hour_off            : UNSIGNED(4 downto 0);
    signal Light_on_off        : BIT;

begin

    -- Unit Under Test port map
    UUT : lighting_control
        port map (
            compclock => compclock,
            reset_lights => reset_lights,
            btn_time_lights_on => btn_time_lights_on,
            btn_time_lights_of => btn_time_lights_of,
            btn_hour => btn_hour,
            btn_min => btn_min,
            min_out => min_out,
            hour_out => hour_out,
            min_on => min_on,
            hour_on => hour_on,
            min_off => min_off,
            hour_off => hour_off,
            Light_on_off => Light_on_off
        );

    -- 10 ns clock generation (200 MHz)
    clk_process : process
    begin
        while true loop
            compclock <= '0';
            wait for 5 ns;
            compclock <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- Reset
        reset_lights <= '1';
        wait for 20 ns;
        reset_lights <= '0';
        wait for 20 ns;

        -- Set ON time: 01:05
        btn_hour <= '1'; wait for 10 ns; btn_hour <= '0';  -- hour = 1
        wait for 10 ns;
        for i in 1 to 5 loop
            btn_min <= '1'; wait for 10 ns; btn_min <= '0';
            wait for 10 ns;
        end loop;
        btn_time_lights_on <= '1'; wait for 10 ns; btn_time_lights_on <= '0';
        wait for 30 ns;

        -- Set OFF time: 03:10
        for i in 1 to 2 loop
            btn_hour <= '1'; wait for 10 ns; btn_hour <= '0';
            wait for 10 ns;
        end loop;
        for i in 1 to 5 loop
            btn_min <= '1'; wait for 10 ns; btn_min <= '0';
            wait for 10 ns;
        end loop;
        btn_time_lights_of <= '1'; wait for 10 ns; btn_time_lights_of <= '0';
        wait for 30 ns;

        -- Simulate current time & test output
        -- Before ON time
        hour_out <= to_unsigned(0, 5); min_out <= to_unsigned(59, 6); wait for 20 ns;

        -- Exactly ON time
        hour_out <= to_unsigned(1, 5); min_out <= to_unsigned(5, 6); wait for 20 ns;

        -- Between ON and OFF
        hour_out <= to_unsigned(2, 5); min_out <= to_unsigned(30, 6); wait for 20 ns;

        -- Exactly OFF time
        hour_out <= to_unsigned(3, 5); min_out <= to_unsigned(10, 6); wait for 20 ns;

        -- After OFF time
        hour_out <= to_unsigned(4, 5); min_out <= to_unsigned(0, 6); wait for 20 ns;

        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_lighting_control of lighting_control_tb is
    for TB_ARCHITECTURE
        for UUT : lighting_control
            use entity work.lighting_control(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_lighting_control;
