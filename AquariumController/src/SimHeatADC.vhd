library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Not synthesizable: simulation-only DS18B20 interface
entity SimHeatADC is
    port (
        clk_1mhz         : in  std_logic;
        one_wire       : out std_logic;
        currentTempsim : out unsigned(11 downto 0)
    );
end entity;

architecture behavior of SimHeatADC is
    signal timer        : integer := 0;
    signal state        : integer := 0;
    signal bit_cnt      : integer := 0;
    signal ow           : std_logic := '1';
    signal temp_data    : std_logic_vector(11 downto 0) := "011000110000"; -- 25.0°C
    signal temp_latched : unsigned(11 downto 0) := (others => '0');

    constant cmd_44     : std_logic_vector(7 downto 0) := "00100010"; -- 44h LSB first convert command
    constant cmd_BE     : std_logic_vector(7 downto 0) := "01111101"; -- BEh LSB first read command
begin
    one_wire <= ow;
    currentTempsim <= temp_latched;	 --to 'save' incoming data

    process(clk_1mhz)
    begin
        if rising_edge(clk_1mhz) then

            case state is

                when 0 =>				  --high for 500 us
                    ow <= '0';
                    if timer = 500 then
                        timer <= 0;
                        ow <= '1';
                        state <= 1;
                    else
                        timer <= timer + 1;
                    end if;

                when 1 =>
                    if timer = 500 then	   --low for 500 ua
                        timer <= 0;
                        state <= 2;
                    else
                        timer <= timer + 1;
                    end if;

                when 2 =>					--presence 
                    ow <= '0';
                    if timer = 100 then
                        timer <= 0;
                        ow <= '1';
                        state <= 3;
                    else
                        timer <= timer + 1;
                    end if;

                when 3 =>										  --convert command
                    if bit_cnt < 8 then
                        if (cmd_44(bit_cnt) = '0' and timer < 60) or
                           (cmd_44(bit_cnt) = '1' and timer < 15) then
                            if timer = 0 then
                                ow <= '0';
                            end if;
                            timer <= timer + 1;
                        else
                            ow <= '1';
                            timer <= 0;
                            bit_cnt <= bit_cnt + 1;
                        end if;
                    else
                        bit_cnt <= 0;
                        timer <= 0;
                        state <= 4;
                    end if;
																  --wait until done converting
                when 4 =>
                    ow <= '1';
                    if timer = 750000 then
                        timer <= 0;
                        state <= 5;
                    else
                        timer <= timer + 1;
                    end if;

                when 5 =>											-- read command
                    if bit_cnt < 8 then
                        if (cmd_BE(bit_cnt) = '0' and timer < 60) or
                           (cmd_BE(bit_cnt) = '1' and timer < 15) then
                            if timer = 0 then
                                ow <= '0';
                            end if;
                            timer <= timer + 1;
                        else
                            ow <= '1';
                            timer <= 0;
                            bit_cnt <= bit_cnt + 1;
                        end if;
                    else
                        bit_cnt <= 0;
                        timer <= 0;
                        state <= 6;
                    end if;
																	 --recieve input
                when 6 =>
                    if bit_cnt < 12 then
                        if timer = 0 then
                            ow <= temp_data(bit_cnt);
                        end if;
                        if timer < 60 then
                            timer <= timer + 1;
                        else
                            ow <= '1';
                            timer <= 0;
                            bit_cnt <= bit_cnt + 1;
                        end if;
                    else
                        temp_latched <= unsigned(temp_data);

                        -- fake data because no real input
                        if temp_data = "011000110000" then
                            temp_data <= "011010000000";  -- 26.0°C
                        elsif temp_data = "011010000000" then
                            temp_data <= "010101010101";  -- ~21.3°C
                        else
                            temp_data <= "011000110000";  -- 25.0°C
                        end if;

                        timer <= 0;
                        bit_cnt <= 0;
                        state <= 7;
                    end if;

                when 7 =>  -- wait 350 ms to approximate temp poll of once a second
    ow <= '1';
    if timer >= 350000 then
        timer <= 0;
        state <= 0;
    else
        timer <= timer + 1;
    end if;


                when others =>
                    ow <= '1';
            end case;
        end if;
    end process;
end architecture;