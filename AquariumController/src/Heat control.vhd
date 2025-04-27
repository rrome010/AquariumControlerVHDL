library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Heat_control is
    Port (
        Hold_Heat       : in std_logic;
        compclock       : in std_logic;
        reset_heat      : in std_logic;
        btn_change_temp : in std_logic;
        btn_temp_up     : in std_logic;
        btn_temp_down   : in std_logic;
        CurrentTemp     : in unsigned(12 downto 0);
        min_out         : in unsigned(5 downto 0);
        tempmax         : out unsigned(12 downto 0);
        tempuser        : out unsigned(12 downto 0);
        tempmin         : out unsigned(12 downto 0);
        heater          : out std_logic;
        TempError       : out std_logic
    );
end Heat_control;

architecture behavioral of Heat_control is
    type state_type is (NORMAL, UNDER_TEMP, ERROR);
    signal current_state : state_type := NORMAL;

    signal set_usr     : unsigned(12 downto 0) := to_unsigned(408, 13); -- 25.5°C
    signal set_min     : unsigned(12 downto 0);
    signal set_max     : unsigned(12 downto 0);
    signal heater_on   : std_logic := '0';
    signal min_start   : unsigned(5 downto 0) := (others => '0');
    signal time_active : std_logic := '0';
begin

    process(compclock, reset_heat)
    begin
        if reset_heat = '1' then
            set_usr       <= to_unsigned(408, 13); -- Reset to 25.5°C
            heater_on     <= '0';
            current_state <= NORMAL;
            min_start     <= (others => '0');
            time_active   <= '0';
            TempError     <= '0';

        elsif rising_edge(compclock) then
            if Hold_Heat = '1' then
                heater_on <= '0'; -- Maintenance mode: heater always OFF
            else
                -- Button-based setpoint adjustment
                if btn_change_temp = '1' then
                    if btn_temp_up = '1' then
                        set_usr <= set_usr + 8;
                    elsif btn_temp_down = '1' then
                        set_usr <= set_usr - 8;
                    end if;
                end if;

                -- Always update min/max relative to set_usr
                set_min <= set_usr - 8;
                set_max <= set_usr + 8;

                -- State machine
                case current_state is
                    when NORMAL =>
                        TempError <= '0'; -- Clear error in normal operation
                        if CurrentTemp > set_max then
                            heater_on    <= '0';
                            TempError    <= '1';
                            current_state <= ERROR; -- Immediate error if overheated
                        elsif CurrentTemp < set_min then
                            heater_on    <= '1';
                            min_start    <= min_out;
                            time_active  <= '1';
                            current_state <= UNDER_TEMP;
                        else
                            heater_on    <= '0';
                            time_active  <= '0';
                        end if;

                    when UNDER_TEMP =>
                        TempError <= '0'; -- Clear error
                        if CurrentTemp >= set_usr then
                            heater_on    <= '0';
                            time_active  <= '0';
                            current_state <= NORMAL;
                        elsif time_active = '1' and (min_out - min_start >= to_unsigned(59, 6)) then
                            TempError    <= '1';
                            heater_on    <= '0';
                            current_state <= ERROR; -- Timeout: heater stuck ON too long
                        else
                            heater_on <= '1';
                        end if;

                    when ERROR =>
                        TempError <= '1'; -- Stay in error
                        heater_on <= '0';
                        -- Stay here until reset

                    when others =>
                        TempError <= '0';
                        heater_on <= '0';
                        current_state <= NORMAL;
                end case;
            end if;
        end if;
    end process;

    -- Output assignments
    tempuser <= set_usr;
    tempmax  <= set_max;
    tempmin  <= set_min;
    heater   <= heater_on;

end behavioral;
