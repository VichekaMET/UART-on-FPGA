----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2026
-- Design Name: 
-- Module Name: Data_Storage - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
--
-- Captures data_in into a register whenever store_en pulses high for one
-- clock cycle, and holds that value steady on data_out afterward, no
-- matter how data_in changes in the meantime -- until the next store_en
-- pulse overwrites it. Useful for latching a received UART byte (or any
-- other momentary value) into something stable that downstream logic can
-- read at any time, not just during the single cycle it first arrives.
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

entity Data_Storage is
  Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        data_in  : in  std_logic_vector(7 downto 0);
        store_en : in  std_logic;   -- pulse high for one cycle to capture data_in
        data_out : out std_logic_vector(7 downto 0)
  );
end Data_Storage;

architecture Behavioral of Data_Storage is
begin

    process(clk, rst)
    begin
        if rst = '1' then
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            if store_en = '1' then
                data_out <= data_in;
            end if;
        end if;
    end process;

end Behavioral;