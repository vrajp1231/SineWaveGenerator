----------------------------------------------------------------------------------
-- Engineer: Vraj Patel
-- Create Date: 11/09/2024 01:27:46 PM
-- Module Name: lab7_top - Behavioral
-- Description: Lab 7 Top Module
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lab7_top is
    Port (
        CLK100MHZ      : in  STD_LOGIC;
        BTNC           : in  STD_LOGIC;                         -- Reset
        SW             : in  STD_LOGIC_VECTOR(15 downto 0);
        AUD_PWM        : out STD_LOGIC;
        AUD_SD         : out STD_LOGIC;                         -- Amp On/Off
        AN             : out STD_LOGIC_VECTOR(7 downto 0);
        SEG7_CATH      : out STD_LOGIC_VECTOR(6 downto 0)
    );
end lab7_top;

architecture Behavioral of lab7_top is

    -- Internal Signals
    signal sample_rate      : STD_LOGIC;                        -- SampleRateGen to PhaseAccumulator
    signal theta            : STD_LOGIC_VECTOR(7 downto 0);     -- PhaseAccumulator to Sine LUT DDS
    signal sine_out         : STD_LOGIC_VECTOR(15 downto 0);    -- Sine LUT DDS to Volume Shifter
    signal sine_shifted     : STD_LOGIC_VECTOR(15 downto 0);    -- Volume Shifter to PWM Generator
    
    signal char0, char1, char2, char3 : STD_LOGIC_VECTOR(3 downto 0);   -- Lower 4 for Frequency
    signal char4, char5, char6, char7 : STD_LOGIC_VECTOR(3 downto 0);   -- Upper 4 for Volume
    
    -- DDS Instantiation
    COMPONENT dds_compiler_0
        PORT (
            aclk : in std_logic;
            s_axis_phase_tvalid : in std_logic;
            s_axis_phase_tdata : in std_logic_vector (7 downto 0);  --8 bit PHASE resolution
            m_axis_data_tvalid : out std_logic;
            m_axis_data_tdata : out std_logic_vector (15 downto 0)  --16 bit SINE LUT (dropped to 10 for PWM)
        );
    END COMPONENT;

begin

    -- Instantiate Sample Rate Generator (enable puslse with specific period to increment an 8 bit phase counter)
    SampleRateGen: entity work.SampleRateGenerator
        port map (
            clk       => CLK100MHZ,
            rst       => BTNC,
            rate_ctrl => SW(2 downto 0),
            gen_out   => sample_rate
        );

    -- Instantiate Phase Accumulator (establish phase of the sine wave)
    PhaseAcc: entity work.PhaseAccumulator
        port map (
            clk         => CLK100MHZ,
            rst         => BTNC,
            sample_rate => sample_rate,
            phase_out   => theta
        );

    -- DDS Instantiation
    sine_lut_dds_inst: dds_compiler_0
        port map (
            aclk                => CLK100MHZ,
            s_axis_phase_tvalid => '1',
            s_axis_phase_tdata  => theta,
            -- m_axis_data_tvalid  => dds_valid,
            m_axis_data_tdata   => sine_out(15 downto 0)
        );

    -- Instantiate Volume Level Shifter (shift sine_out to the right by its inverse)
    VolShift: entity work.VolumeLevelShifter
        port map (
            sine_out        => sine_out,
            vol_ctrl        => SW(5 downto 3),
            sine_shifted    => sine_shifted
        );

    -- Instantiate PWM Generator
    PWMGen: entity work.PWMGenerator
        port map (
            clk        => CLK100MHZ,
            rst        => BTNC,
            duty_cycle => sine_shifted(15 downto 6),
            pwm_out    => AUD_PWM
        );
        
    Seg7Driver: entity work.seg7_driver
        port map (
            clk50       => CLK100MHZ,
            rst         => BTNC,
            char0       => char0,
            char1       => char1,
            char2       => char2,
            char3       => char3,
            char4       => char4,
            char5       => char5,
            char6       => char6,
            char7       => char7,
            anodes      => AN,
            encodedChar => SEG7_CATH
        );
        
    -- Frequency
    process(SW)
    begin
        case SW(2 downto 0) is
            when "000" =>  -- 0
                char3 <= "0000";
                char2 <= "0000";
                char1 <= "0000";
                char0 <= "0000";
            when "001" =>  -- 500
                char3 <= "0000";
                char2 <= "0101";
                char1 <= "0000";
                char0 <= "0000";
            when "010" =>  -- 1000
                char3 <= "0001";
                char2 <= "0000";
                char1 <= "0000";
                char0 <= "0000";
            when "011" =>  -- 1500
                char3 <= "0001";
                char2 <= "0101";
                char1 <= "0000";
                char0 <= "0000";
            when "100" =>  -- 2000
                char3 <= "0010";
                char2 <= "0000";
                char1 <= "0000";
                char0 <= "0000";
            when "101" =>  -- 2500
                char3 <= "0010";
                char2 <= "0101";
                char1 <= "0000";
                char0 <= "0000";
            when "110" =>  -- 3000
                char3 <= "0011";
                char2 <= "0000";
                char1 <= "0000";
                char0 <= "0000";
            when others =>  -- 3500
                char3 <= "0011";
                char2 <= "0101";
                char1 <= "0000";
                char0 <= "0000";
        end case;
    end process;
    
    -- Volume
    process(SW)
    begin
        case SW(5 downto 3) is
            when "000" =>  -- 0
                char7 <= "0000";
                char6 <= "0000";
                char5 <= "0000";
                char4 <= "0000";
            when "001" =>  -- 14
                char7 <= "0000";
                char6 <= "0000";
                char5 <= "0001";
                char4 <= "0100";
            when "010" =>  -- 29
                char7 <= "0000";
                char6 <= "0000";
                char5 <= "0010";
                char4 <= "1001";
            when "011" =>  -- 43
                char7 <= "0000";
                char6 <= "0000";
                char5 <= "0100";
                char4 <= "0011";
            when "100" =>  -- 57
                char7 <= "0000";
                char6 <= "0000";
                char5 <= "0101";
                char4 <= "0111";
            when "101" =>  -- 71
                char7 <= "0000";
                char6 <= "0000";
                char5 <= "0111";
                char4 <= "0001";
            when "110" =>  -- 86
                char7 <= "0000";
                char6 <= "0000";
                char5 <= "1000";
                char4 <= "0110";
            when others =>  -- 100
                char7 <= "0000";
                char6 <= "0001";
                char5 <= "0000";
                char4 <= "0000";
        end case;
    end process;

    -- Control Amplifier
    AUD_SD <= SW(15);  -- If SW(15) is '1', enable audio output, otherwise disable

end Behavioral;
