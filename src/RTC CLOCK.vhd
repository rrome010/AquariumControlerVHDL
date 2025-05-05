library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RTC is
    Port (
        clk_1hz     : in  STD_LOGIC;        -- 1 Hz clock
        rst         : in  STD_LOGIC;        -- Reset signal
        btn_time    : in  STD_LOGIC;        -- Enter time set mode
        btn_hour    : in  STD_LOGIC;        -- Increment hour
        btn_min     : in  STD_LOGIC;        -- Increment minute
        sec_out     : out UNSIGNED(5 downto 0);
        min_out     : out UNSIGNED(5 downto 0);
        hour_out    : out UNSIGNED(4 downto 0)
    );
end RTC;

architecture Behavioral of RTC is
    signal seconds : UNSIGNED(5 downto 0) := (others => '0');  -- 0–59
    signal minutes : UNSIGNED(5 downto 0) := (others => '0');  -- 0–59
    signal hours   : UNSIGNED(4 downto 0) := (others => '0');  -- 0–23
begin

    process(clk_1hz, rst)
    begin
        if rst = '1' then
            seconds <= (others => '0');
            minutes <= (others => '0');
            hours   <= (others => '0');

        elsif rising_edge(clk_1hz) then
            if btn_time = '1' then
                -- Time set mode
                if btn_hour = '1' then
                    if hours = to_unsigned(23, 5) then
                        hours <= (others => '0');
                    else
                        hours <= hours + 1;
                    end if;
                elsif btn_min = '1' then
                    if minutes = to_unsigned(59, 6) then
                        minutes <= (others => '0');
                    else
                        minutes <= minutes + 1;
                    end if;
                end if;

            else
                -- Normal clock operation
                seconds <= seconds + 1;
                if seconds = to_unsigned(59, 6) then
                    seconds <= (others => '0');
                    minutes <= minutes + 1;
                    if minutes = to_unsigned(59, 6) then
                        minutes <= (others => '0');
                        if hours = to_unsigned(23, 5) then
                            hours <= (others => '0');
                        else
                            hours <= hours + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Output assignments
    sec_out  <= seconds;
    min_out  <= minutes;
    hour_out <= hours;
end Behavioral;
