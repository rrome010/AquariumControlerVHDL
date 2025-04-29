library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevel is
    Port (
        clk_1hz        : in std_logic;
        compclock      : in std_logic;
        reset          : in std_logic;
        btn_feed       : in std_logic;
        sw_maint       : in std_logic;
		
		Feed : in std_logic;
		Skimmer : out std_logic;
		Pumps : out std_logic;
		
        heater_out     : out std_logic;
        light_out      : out std_logic;
        ato_pump_out   : out std_logic;
        Hold_Heat      : out std_logic;
		
		

        -- Debug outputs
        min_on_out     : out unsigned(5 downto 0);
        hour_on_out    : out unsigned(4 downto 0);
        min_off_out    : out unsigned(5 downto 0);
        hour_off_out   : out unsigned(4 downto 0);
        tempuser_out   : out unsigned(12 downto 0);

        light_on_off   : out std_logic;
        ATO_ERROR      : out std_logic;
        TempError      : out std_logic;
        sec_out_debug  : out unsigned(5 downto 0);
        min_out_debug  : out unsigned(5 downto 0);
        hour_out_debug : out unsigned(4 downto 0);
        tempuser_debug : out unsigned(12 downto 0);
        tempmax_debug  : out unsigned(12 downto 0);
        tempmin_debug  : out unsigned(12 downto 0);
        min_on_debug   : out unsigned(5 downto 0);
        hour_on_debug  : out unsigned(4 downto 0);
        min_off_debug  : out unsigned(5 downto 0);
        hour_off_debug : out unsigned(4 downto 0);

        -- Test/Override inputs
        test_mode            : in std_logic := '0';
        S1ATO_override       : in std_logic := '0';
        S2ATO_override       : in std_logic := '0';
        CurrentTemp_override : in unsigned(12 downto 0) := (others => '0');
        btn_time             : in std_logic := '0';
        btn_hour             : in std_logic := '0';
        btn_min              : in std_logic := '0';
        btn_time_lights_on   : in std_logic := '0';
        btn_time_lights_of   : in std_logic := '0';
        btn_light_hour       : in std_logic := '0';
        btn_light_min        : in std_logic := '0';
        btn_change_temp      : in std_logic := '0';
        btn_temp_up          : in std_logic := '0';
        btn_temp_down        : in std_logic := '0'
    );
end TopLevel;

architecture Behavioral of TopLevel is

    -- Internal signals
    signal maintenance_in       : std_logic := '0';
    signal maintenance_holdheat : std_logic := '0';
	signal maint_pumps : std_logic;
	signal feed_pumps  : std_logic;

	
	signal Feed_in : std_logic := '0';

    signal feed_active      : std_logic := '0';
    signal feed_start_min   : unsigned(5 downto 0) := (others => '0');

    signal ato_pump_signal  : std_logic := '0';
    signal heater_signal    : std_logic := '0';
    signal light_signal     : std_logic := '0';

    signal sec_out          : unsigned(5 downto 0);
    signal min_out          : unsigned(5 downto 0);
    signal hour_out         : unsigned(4 downto 0);

    signal light_on_off_sig : bit;

    signal min_on_sig       : unsigned(5 downto 0);
    signal hour_on_sig      : unsigned(4 downto 0);
    signal min_off_sig      : unsigned(5 downto 0);
    signal hour_off_sig     : unsigned(4 downto 0);

    signal tempuser_sig     : unsigned(12 downto 0);
    signal tempmax_sig      : unsigned(12 downto 0) := (others => '0');
    signal tempmin_sig      : unsigned(12 downto 0) := (others => '0');

	signal ato_error_signal : std_logic;
	
	-- Function to convert BIT to STD_LOGIC
    function to_stdlogic(b: bit) return std_logic is
    begin
        if b = '0' then
            return '0';
        else
            return '1';
        end if;
    end;

begin

    -- Instantiation of RTC
    RTC_Inst: entity work.RTC
        port map (
            clk_1hz    => clk_1hz,
            rst        => reset,
            btn_time   => btn_time,
            btn_hour   => btn_hour,
            btn_min    => btn_min,
            sec_out    => sec_out,
            min_out    => min_out,
            hour_out   => hour_out
        );

    -- Instantiation of Lighting control
    LightController: entity work.Lighting_Control
        port map (
            compclock           => compclock,
            reset_lights        => reset,
            btn_time_lights_on  => btn_time_lights_on,
            btn_time_lights_of  => btn_time_lights_of,
            btn_hour            => btn_light_hour,
            btn_min             => btn_light_min,
            min_out             => min_out,
            hour_out            => hour_out,
            min_on              => min_on_sig,
            hour_on             => hour_on_sig,
            min_off             => min_off_sig,
            hour_off            => hour_off_sig,
            Light_on_off        => light_on_off_sig
        );

    -- Instantiation of Heat control
    HeaterController: entity work.Heat_control
        port map (
            Hold_Heat       => maintenance_holdheat, -- <<< connects internal signal
            compclock       => compclock,
            reset_heat      => reset,
            btn_change_temp => btn_change_temp,
            btn_temp_up     => btn_temp_up,
            btn_temp_down   => btn_temp_down,
            CurrentTemp     => CurrentTemp_override,
            min_out         => min_out,
            tempmax         => tempmax_sig,
            tempuser        => tempuser_sig,
            tempmin         => tempmin_sig,
            heater          => heater_signal,
            temperror       => TempError
        );

    -- Instantiation of maintenance mode
    MaintenanceController: entity work.maintenance
        port map (
            compclock => compclock,
            swmaint   => sw_maint,
            holdheat  => maintenance_holdheat,
			maint_pumps    => maint_pumps
        );
-- Instantiation of feed mode
    FeedMode_Inst : entity work.feedmode
    port map (
        compclock => compclock,
        clk_1hz   => clk_1hz,
        feed_mode => Feed, 
        feed_pumps => feed_pumps,
        skimmer   => Skimmer
    );
	-- Instantiation of ATO
	ATOController: entity work.ATO
    port map (
        clk_1hz        => clk_1hz,
        compclock      => compclock,
        ATO_RESET      => reset,
        maintenance_in => maintenance_in,
        S1ATO          => S1ATO_override,
        S2ATO          => S2ATO_override,
        ATO_PUMP       => ato_pump_signal,
        ATO_ERROR      => ato_error_signal
    );


    -- Outputs mapping
    heater_out    <= heater_signal;
    light_out     <= to_stdlogic(light_on_off_sig);
    ato_pump_out  <= ato_pump_signal;
    Hold_Heat     <= maintenance_holdheat; 
   	Pumps <=  (maint_pumps or feed_pumps);
    min_on_out    <= min_on_sig;
    hour_on_out   <= hour_on_sig;
    min_off_out   <= min_off_sig;
    hour_off_out  <= hour_off_sig;
    tempuser_out  <= tempuser_sig;
	ato_pump_out <= ato_pump_signal;
	ATO_ERROR    <= ato_error_signal;


    -- Debug outputs
    light_on_off   <= to_stdlogic(light_on_off_sig);
    ATO_ERROR      <= '0'; 
    sec_out_debug  <= sec_out;
    min_out_debug  <= min_out;
    hour_out_debug <= hour_out;
    tempuser_debug <= tempuser_sig;
    tempmax_debug  <= tempmax_sig;
    tempmin_debug  <= tempmin_sig;
    min_on_debug   <= min_on_sig;
    hour_on_debug  <= hour_on_sig;
    min_off_debug  <= min_off_sig;
    hour_off_debug <= hour_off_sig;

end Behavioral;
