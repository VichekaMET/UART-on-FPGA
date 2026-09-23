----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2026
-- Design Name: 
-- Module Name: an_generator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
--
-- Cycles through the 8 digit-select lines (AN0..AN7) for the 7-segment
-- display multiplexer. Nexys A7's display is common-anode with the anode
-- enables inverted, so exactly one bit of AN_out is driven LOW at a time
-- (the currently active digit) -- everything else stays HIGH (off).
--
-- Refresh timing: switches digit every REFRESH_DIV clock cycles. At the
-- default 100MHz clock and REFRESH_DIV=100,000, that's a 1kHz per-digit
-- switch rate, giving a ~125Hz full 8-digit refresh -- comfortably above
-- the ~60Hz flicker-fusion threshold.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity an_generator is
    Port ( clk: in std_logic;
        rst : in std_logic;
        AN_out : out std_logic_vector(7 downto 0)
     );
end an_generator;

architecture Behavioral of an_generator is

    constant REFRESH_DIV : integer := 100_000;

    signal refresh_cnt : unsigned(16 downto 0);
    signal digit_sel    : unsigned(2 downto 0);

begin

    process(clk, rst)
    begin
        if rst = '1' then
            refresh_cnt <= (others => '0');
            digit_sel   <= (others => '0');
        elsif rising_edge(clk) then
            if refresh_cnt = to_unsigned(REFRESH_DIV - 1, refresh_cnt'length) then
                refresh_cnt <= (others => '0');
                digit_sel   <= digit_sel + 1;
            else
                refresh_cnt <= refresh_cnt + 1;
            end if;
        end if;
    end process;

    -- one-hot, active-low: only the selected digit's bit goes low.
    -- digit_sel=0 -> AN_out(0) active, matching bcd0=units=rightmost digit
    -- convention used throughout the rest of this project
    AN_out <= "11111110" when digit_sel = "000" else
              "11111101" when digit_sel = "001" else
              "11111011" when digit_sel = "010" else
              "11110111" when digit_sel = "011" else
              "11101111" when digit_sel = "100" else
              "11011111" when digit_sel = "101" else
              "10111111" when digit_sel = "110" else
              "01111111" when digit_sel = "111" else
              "11111111";

end Behavioral;