library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Lighting_Control is
    Port (
        compclock            : in  STD_LOGIC;
        reset_lights         : in  STD_LOGIC;
        btn_time_lights_on   : in  STD_LOGIC;
        btn_time_lights_of   : in  STD_LOGIC;
        btn_hour             : in  STD_LOGIC;
        btn_min              : in  STD_LOGIC;
        min_out              : in  UNSIGNED(5 downto 0);
        hour_out             : in  UNSIGNED(4 downto 0);
        min_on               : out UNSIGNED(5 downto 0);
        hour_on              : out UNSIGNED(4 downto 0);
        min_off              : out UNSIGNED(5 downto 0);
        hour_off             : out UNSIGNED(4 downto 0);
        Light_on_off         : out BIT
    );
end Lighting_Control;

architecture Behavioral of Lighting_Control is

    signal set_min   : UNSIGNED(5 downto 0) := (others => '0');
    signal set_hour  : UNSIGNED(4 downto 0) := (others => '0');
    signal reg_min_on  : UNSIGNED(5 downto 0) := (others => '0');
    signal reg_hour_on : UNSIGNED(4 downto 0) := (others => '0');
    signal reg_min_off : UNSIGNED(5 downto 0) := (others => '0');
    signal reg_hour_off: UNSIGNED(4 downto 0) := (others => '0');

begin

    process(compclock, reset_lights)
    begin
        if reset_lights = '1' then
            set_min      <= (others => '0');
            set_hour     <= (others => '0');
            reg_min_on   <= (others => '0');
            reg_hour_on  <= (others => '0');
            reg_min_off  <= (others => '0');
            reg_hour_off <= (others => '0');
        elsif rising_edge(compclock) then
            -- Hour/Minute setting
            if btn_hour = '1' then
                if set_hour = to_unsigned(23, 5) then
                    set_hour <= (others => '0');
                else
                    set_hour <= set_hour + 1;
                end if;
            elsif btn_min = '1' then
                if set_min = to_unsigned(59, 6) then
                    set_min <= (others => '0');
                else
                    set_min <= set_min + 1;
                end if;
            end if;

            -- Save to ON time
            if btn_time_lights_on = '1' then
                reg_hour_on <= set_hour;
                reg_min_on  <= set_min;
            end if;

            -- Save to OFF time
            if btn_time_lights_of = '1' then
                reg_hour_off <= set_hour;
                reg_min_off  <= set_min;
            end if;
        end if;
    end process;

    -- Output assignments
    min_on  <= reg_min_on;
    hour_on <= reg_hour_on;
    min_off <= reg_min_off;
    hour_off <= reg_hour_off;

    -- Compare RTC time with on/off time
    process(min_out, hour_out, reg_min_on, reg_hour_on, reg_min_off, reg_hour_off)
    begin
        if ((hour_out > reg_hour_on) or (hour_out = reg_hour_on and min_out >= reg_min_on)) and
           ((hour_out < reg_hour_off) or (hour_out = reg_hour_off and min_out < reg_min_off)) then
            Light_on_off <= '1';
        else
            Light_on_off <= '0';
        end if;
    end process;

end Behavioral;
