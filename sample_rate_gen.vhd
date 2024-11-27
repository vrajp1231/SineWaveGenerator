----------------------------------------------------------------------------------
-- Engineer: Vraj Patel
-- Create Date: 11/09/2024 01:33:52 PM
-- Module Name: sample_rate_gen - Behavioral
-- Description: Sample Rate Generator
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SampleRateGenerator is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        rate_ctrl : in  STD_LOGIC_VECTOR(2 downto 0);
        gen_out   : out STD_LOGIC
    );
end SampleRateGenerator;

architecture Behavioral of SampleRateGenerator is
    signal counter : unsigned(15 downto 0) := (others => '0');
    signal max_count : unsigned(15 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');
            gen_out <= '0';
        elsif rising_edge(clk) then
            if rate_ctrl = "000" then
                -- Special case: 0 Hz (DC), keep gen_out low
                gen_out <= '0';
                counter <= (others => '0');
            else
                -- Increment the counter
                if counter >= max_count then
                    counter <= (others => '0');
                    gen_out <= '1';
                else
                    counter <= counter + 1;
                    gen_out <= '0';
                end if;
            end if;
        end if;
    end process;

    process(rate_ctrl)
    begin
        case rate_ctrl is
            when "001" => max_count <= to_unsigned(391, 16);  -- 500 Hz
            when "010" => max_count <= to_unsigned(195, 16);  -- 1000 Hz
            when "011" => max_count <= to_unsigned(130, 16);  -- 1500 Hz
            when "100" => max_count <= to_unsigned(98, 16);   -- 2000 Hz
            when "101" => max_count <= to_unsigned(78, 16);   -- 2500 Hz
            when "110" => max_count <= to_unsigned(65, 16);   -- 3000 Hz
            when "111" => max_count <= to_unsigned(56, 16);   -- 3500 Hz
            when others => max_count <= to_unsigned(1000, 16);
        end case;
    end process;

end Behavioral;
