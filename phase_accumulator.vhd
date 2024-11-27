----------------------------------------------------------------------------------
-- Engineer: Vraj Patel
-- Create Date: 11/09/2024 01:34:51 PM
-- Module Name: phase_accumulator - Behavioral
-- Description: Phase Accumulator
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PhaseAccumulator is
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        sample_rate : in  STD_LOGIC;
        phase_out   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end PhaseAccumulator;

architecture Behavioral of PhaseAccumulator is
    signal phase : unsigned(7 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            phase <= (others => '0');
        elsif rising_edge(clk) then
            if sample_rate = '1' then
                phase <= phase + 1;
            end if;
        end if;
    end process;

    phase_out <= std_logic_vector(phase);
end Behavioral;
