----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2026
-- Design Name: 
-- Module Name: bcd_decoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
--
-- Converts a 4-bit BCD digit (0-9) into the 7 segment drive signals for one
-- digit of the display. Nexys A7's segments are active-LOW (a segment lights
-- when driven '0'), so every pattern here is the inverse of the familiar
-- active-high 7-segment truth table.
--
-- bcd_out bit order matches the CA..CG pin assignment used throughout this
-- project's XDC files: bcd_out(6)=CA (segment a) ... bcd_out(0)=CG (segment g).
--
-- Any BCD code outside 0-9 (10-15) blanks the digit (all segments off).
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

entity bcd_decoder is
    port (  data: in std_logic_vector(3 downto 0);
            dp_int: in std_logic;
            dp_out : out std_logic;
            bcd_out: out std_logic_vector(6 downto 0) 
    );   
end bcd_decoder;

architecture Behavioral of bcd_decoder is
begin

    -- bcd_out(6 downto 0) = (a, b, c, d, e, f, g), active-low
    with data select
        bcd_out <= "0000001" when "0000",  -- 0
                   "1001111" when "0001",  -- 1
                   "0010010" when "0010",  -- 2
                   "0000110" when "0011",  -- 3
                   "1001100" when "0100",  -- 4
                   "0100100" when "0101",  -- 5
                   "0100000" when "0110",  -- 6
                   "0001111" when "0111",  -- 7
                   "0000000" when "1000",  -- 8
                   "0000100" when "1001",  -- 9
                   "1111111" when others;  -- blank (invalid BCD code)

    -- dp_int is active-high ('1' = show the decimal point); the physical
    -- pin is active-low like the segments, so invert it here
    dp_out <= not dp_int;

end Behavioral;