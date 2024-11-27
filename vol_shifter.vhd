----------------------------------------------------------------------------------
-- Engineer: Vraj Patel
-- Create Date: 11/09/2024 01:48:11 PM
-- Module Name: vol_shifter - Behavioral
-- Project Name: Lab 7
-- Description: Volume Level Shifter
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VolumeLevelShifter is
    Port (
        sine_out     : in  STD_LOGIC_VECTOR(15 downto 0);
        vol_ctrl : in  STD_LOGIC_VECTOR(2 downto 0);
        sine_shifted    : out STD_LOGIC_VECTOR(15 downto 0)
    );
end VolumeLevelShifter;

architecture Behavioral of VolumeLevelShifter is
    signal shift_value : integer;
begin
    process(vol_ctrl)
    begin
        case vol_ctrl is
            when "000" => shift_value <= 7;
            when "001" => shift_value <= 6;
            when "010" => shift_value <= 5;
            when "011" => shift_value <= 4;
            when "100" => shift_value <= 3;
            when "101" => shift_value <= 2;
            when "110" => shift_value <= 1;
            when "111" => shift_value <= 0;
            when others => shift_value <= 7;
        end case;
    end process;

    sine_shifted <= std_logic_vector(signed(sine_out) srl shift_value);
end Behavioral;
