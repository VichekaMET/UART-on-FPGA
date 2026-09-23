----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2026
-- Design Name: 
-- Module Name: data_controller_for8 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
--
-- Selects which of the 8 BCD digits (bcd0..bcd7) should be shown on THIS
-- scan cycle, based on which AN line an_generator currently has active
-- (one-hot, active-low). Also selects whether that digit's decimal point
-- should be lit.
--
-- ASSUMPTION (not confirmed against the real frequency meter top-level):
-- dp_vector's 4 bits map one-hot to digits 0-3 only (the low four digits).
-- Digits 4-7 never show a decimal point. This fits an 8-digit / 3-decimal-
-- place display, where the point only ever needs to land somewhere in the
-- lower half -- but if the real intended layout differs, this is the part
-- of the file to revisit; everything else here follows directly from the
-- given port list with no ambiguity.
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

entity data_controller_for8 is
    port( bcd0: in std_logic_vector(3 downto 0);
      bcd1: in std_logic_vector(3 downto 0);
      bcd2: in std_logic_vector(3 downto 0);
      bcd3: in std_logic_vector(3 downto 0);
      bcd4: in std_logic_vector(3 downto 0);
      bcd5: in std_logic_vector(3 downto 0);
      bcd6: in std_logic_vector(3 downto 0);
      bcd7: in std_logic_vector(3 downto 0);
      dp_vector: in std_logic_vector(3 downto 0);
      data_out: out  std_logic_vector(3 downto 0);
      AN:in  std_logic_vector(7 downto 0);
      dp_out:out  std_logic
      );
end data_controller_for8;

architecture Behavioral of data_controller_for8 is
begin

    -- which digit's BCD value is active this scan cycle
    with AN select
        data_out <= bcd0 when "11111110",
                    bcd1 when "11111101",
                    bcd2 when "11111011",
                    bcd3 when "11110111",
                    bcd4 when "11101111",
                    bcd5 when "11011111",
                    bcd6 when "10111111",
                    bcd7 when "01111111",
                    "0000" when others;

    -- which digit's decimal point is active this scan cycle -- see
    -- ASSUMPTION above
    with AN select
        dp_out <= dp_vector(0) when "11111110",  -- digit0
                  dp_vector(1) when "11111101",  -- digit1
                  dp_vector(2) when "11111011",  -- digit2
                  dp_vector(3) when "11110111",  -- digit3
                  '0' when others;                -- digits 4-7: never

end Behavioral;