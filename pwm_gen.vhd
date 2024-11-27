----------------------------------------------------------------------------------
-- Engineer: Vraj Patel
-- Create Date: 11/09/2024 01:36:03 PM
-- Module Name: pwm_gen - Behavioral
-- Description: PWM Generator
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWMGenerator is
    Port (
        clk          : in  STD_LOGIC;
        rst          : in  STD_LOGIC;
        duty_cycle   : in  STD_LOGIC_VECTOR(9 downto 0);
        pwm_out      : out STD_LOGIC
    );
end PWMGenerator;

architecture Behavioral of PWMGenerator is
    signal counter : unsigned(9 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');
            pwm_out <= '0';
        elsif rising_edge(clk) then
            if counter = "1111111111" then
                counter <= (others => '0');
                pwm_out <= '0';
            else
                counter <= counter + 1;
                if counter < unsigned(duty_cycle) then
                    pwm_out <= '1';
                else
                    pwm_out <= '0';
                end if;
            end if;
        end if;
    end process;
end Behavioral;
