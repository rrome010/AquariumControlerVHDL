library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ATO is
    Port (
        clk_1hz     : in  STD_LOGIC;
        compclock   : in  STD_LOGIC;
        ATO_RESET   : in  STD_LOGIC;
        maintenance_in : in  STD_LOGIC;
        S1ATO       : in  STD_LOGIC;  -- Water Level Sensor 1
        S2ATO       : in  STD_LOGIC;  -- Water Level Sensor 2
        ATO_PUMP    : out STD_LOGIC;
        ATO_ERROR   : out STD_LOGIC
    );
end ATO;

architecture Behavioral of ATO is
    -- States based on flowchart
    type STATE_TYPE is (IDLE, FILL, ERROR_STATE, MAINTENANCE);
    signal state : STATE_TYPE := IDLE;
    signal seconds_counter : UNSIGNED(7 downto 0) := (others => '0');
    signal clk_1hz_prev    : STD_LOGIC := '0';
begin
    process(compclock, ATO_RESET)
    begin
        if ATO_RESET = '1' then
            -- Reset - go to IDLE state per flowchart
            state <= IDLE;
            ATO_PUMP <= '0';
            ATO_ERROR <= '0';
            seconds_counter <= (others => '0');
            clk_1hz_prev <= '0';
        elsif rising_edge(compclock) then
            -- Update previous clock state for edge detection
            clk_1hz_prev <= clk_1hz;
            
            -- Default output assignments
            ATO_PUMP <= '0';
            ATO_ERROR <= '0';
            
            -- State machine logic
            case state is
                when IDLE =>
                    if maintenance_in = '1' then
                        state <= MAINTENANCE;
                    elsif clk_1hz = '1' and clk_1hz_prev = '0' then  -- 1Hz clock tick
                    seconds_counter <= (others => '0');
                        
                        -- Check sensor conditions
                        if (S1ATO = '0' and S2ATO = '1') or (S1ATO = '1' and S2ATO = '1')
							then
                            -- Invalid sensor state
                            state <= ERROR_STATE;
                        elsif S1ATO = '0' and S2ATO = '0' then
                            -- Water level low, start filling
                            state <= FILL;
                        end if;
                    end if;
                    
                when FILL =>
                    -- In FILL state
                    ATO_PUMP <= '1';  -- Pump is ON in FILL state
                    
                    if maintenance_in = '1' then
                        state <= MAINTENANCE;
                    
					elsif clk_1hz = '1' and clk_1hz_prev = '0' then  -- 1Hz clock tick
                        -- Increment timer while filling
                        seconds_counter <= seconds_counter + 1;
                        -- Check sensor conditions
                        if S2ATO = '1' then
                            state <= ERROR_STATE;
                        elsif (S1ATO = '1' and S2ATO = '0') then
                            state <= IDLE;
                        elsif seconds_counter = to_unsigned(120, 8) then
                            -- Timeout after 2 minutes
                            state <= ERROR_STATE;
                        end if;
                    end if;
                    
                when ERROR_STATE =>
                    -- In ERROR state
                    ATO_ERROR <= '1';  -- Error is ON in ERROR state
                    
                    -- Can only exit ERROR via maintenance or reset
                    if maintenance_in = '1' then
                        state <= MAINTENANCE;
                    end if;
                    
                when MAINTENANCE =>
                    if maintenance_in = '0' then
                        state <= IDLE;
                        seconds_counter <= (others => '0');
                    end if;
                    
                when others =>
                    state <= IDLE;
            end case;
            
            -- Override output values based on state (ensures outputs are consistent)
            case state is
                when IDLE =>
                    ATO_PUMP <= '0';
                    ATO_ERROR <= '0';
                when FILL =>
                    ATO_PUMP <= '1';
                    ATO_ERROR <= '0';
                when ERROR_STATE =>
                    ATO_PUMP <= '0';
                    ATO_ERROR <= '1';
                when MAINTENANCE =>
                    ATO_PUMP <= '0';
                    ATO_ERROR <= '0';
                when others =>
                    ATO_PUMP <= '0';
                    ATO_ERROR <= '0';
            end case;
        end if;
    end process;
end Behavioral;