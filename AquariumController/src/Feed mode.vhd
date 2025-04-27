library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity feedmode is
    Port (
        compclock : in std_logic;
        clk_1hz   : in std_logic;
        feed_mode : in std_logic;
        pumps     : out std_logic;
        skimmer   : out std_logic
    );
end feedmode;

architecture Behavioral of feedmode is

    type state_type is (normal, feed);
    signal current_state : state_type := normal;
    
    -- Counter for feed mode timing
    signal feed_counter : unsigned(15 downto 0) := (others => '0');  -- Enough for > 4 hours in seconds

begin

    process (compclock)
    begin
        if rising_edge(compclock) then
            case current_state is
                when normal =>
                    pumps   <= '1';
                    skimmer <= '1';
                    feed_counter <= (others => '0');  -- Reset counter
                    
                    if feed_mode = '1' then
                        current_state <= feed;
                    end if;

                when feed =>
                    -- Count seconds in feed mode
                    if rising_edge(clk_1hz) then
                        feed_counter <= feed_counter + 1;
                    end if;
                    
                    if feed_counter > to_unsigned(600, feed_counter'length) then
                        pumps   <= '1';   -- Pumps ON during first 600 seconds
                        skimmer <= '0';
                    else
                        pumps <= '0';     -- Pumps OFF after 600 seconds
                        if feed_counter >= to_unsigned(14400, feed_counter'length) then
                            skimmer <= '1';  -- Skimmer ON after 4 hours
                            current_state <= normal;
                        else
                            skimmer <= '0';  -- Skimmer stays OFF before 4 hours
                        end if;
                    end if;

                when others =>
                    current_state <= normal;
            end case;
        end if;
    end process;

end Behavioral;
