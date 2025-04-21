library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ATO is
    Port (
        clk_1hz    : in  STD_LOGIC;
        compclock  : in  STD_LOGIC;
        ATO_RESET  : in  STD_LOGIC;
        S1ATO      : in  STD_LOGIC;
        S2ATO      : in  STD_LOGIC;
        ATO_PUMP   : out STD_LOGIC;
        ATO_ERROR  : out STD_LOGIC
    );
end ATO;

architecture Behavioral of ATO is
    type STATE_TYPE is (IDLE, FILL, ERROR);
    signal state : STATE_TYPE := IDLE;

    signal seconds_counter : UNSIGNED(7 downto 0) := (others => '0');
    signal clk_1hz_prev    : STD_LOGIC := '0';
begin

    process(compclock, ATO_RESET)
    begin
        if ATO_RESET = '1' then
            state <= IDLE;
            ATO_PUMP <= '0';
            ATO_ERROR <= '0';
            seconds_counter <= (others => '0');
            clk_1hz_prev <= '0';

        elsif rising_edge(compclock) then
            if clk_1hz = '1' and clk_1hz_prev = '0' then  -- rising edge detection
                case state is

                    when IDLE =>
                        ATO_PUMP <= '0';
                        ATO_ERROR <= '0';
                        seconds_counter <= (others => '0');

                        if S1ATO = '0' and S2ATO = '1' then
                            state <= ERROR;
                        elsif S1ATO = '0' and S2ATO = '0' then
                            state <= FILL;
                        end if;

                    when FILL =>
                        ATO_PUMP <= '1';																								 	
                        seconds_counter <= seconds_counter + 1;

                        
                        if S2ATO = '1' then -- give error if top sensor senses water level
                            state <= ERROR;
                        elsif S1ATO = '1' then
                            state <= IDLE;
                        elsif seconds_counter = to_unsigned(120, 8) then
                            state <= ERROR;
                        end if;

                    when ERROR =>
                        ATO_PUMP <= '0';
                        ATO_ERROR <= '1';
                end case;
            end if;

            clk_1hz_prev <= clk_1hz;
        end if;
    end process;

end Behavioral;
