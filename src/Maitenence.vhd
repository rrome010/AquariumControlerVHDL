library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity maintenance is
    Port (
        compclock : in std_logic;
        swmaint   : in std_logic;
        holdheat  : out std_logic;
		maint_pumps  : out std_logic
    );
end maintenance;

architecture Behavioral of maintenance is

    
    type state_type is (normal, maint);
    signal current_state : state_type := normal;

begin

    process (compclock)
    begin
        if rising_edge(compclock) then
            case current_state is
                when normal =>
                    if swmaint = '1' then
                        current_state <= maint;
                    else
                        holdheat <= '0';
						maint_pumps <= '0';
                    end if;

                when maint =>
                    if swmaint = '0' then
                        current_state <= normal;
                    else
                        holdheat <= '1';
						maint_pumps <= '1';
                    end if;
                    
                when others =>
                    current_state <= normal;
            end case;
        end if;
    end process;

end Behavioral;
