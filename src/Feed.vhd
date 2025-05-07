library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity feedmode is
    Port (
        compclock  : in std_logic;
        clk_1hz    : in std_logic;
        feed_mode  : in std_logic;
        Feed_Pumps : out std_logic;
        skimmer    : out std_logic
    );
end feedmode;

architecture Behavioral of feedmode is

    type state_type is (normal, feed);
    signal current_state : state_type := normal;
    
    signal feed_counter   : unsigned(15 downto 0) := (others => '0'); -- to track time
    signal clk_1hz_prev   : std_logic := '0'; -- For edge detection

begin

    process(compclock)
    begin
        if rising_edge(compclock) then

            -- Detect rising edge of clk_1hz for counting seconds
            clk_1hz_prev <= clk_1hz;

            case current_state is

                when normal =>
                    Feed_Pumps <= '1';
                    skimmer    <= '1';
                    feed_counter <= (others => '0');  -- Reset counter in normal mode

                    if feed_mode = '1' then
                        current_state <= feed;
                    end if;

                when feed =>
                    if (clk_1hz_prev = '0') and (clk_1hz = '1') then
                        feed_counter <= feed_counter + 1;
                    end if;

                    if feed_counter <= to_unsigned(100, 16) then
                        Feed_Pumps <= '0';  -- Pumps OFF during first 600 seconds (sped up for simulation)
                        skimmer    <= '0';
                    elsif feed_counter > to_unsigned(100, 16) and feed_counter < to_unsigned(200, 16) then
                        Feed_Pumps <= '1';  -- short time for sim
                        skimmer    <= '0';
                    else -- feed_counter >= 14400
                        skimmer    <= '1';  -- Skimmer ON (short time for sim)
                        current_state <= normal;
                    end if;

                when others =>
                    current_state <= normal;

            end case;
        end if;
    end process;

end Behavioral;
