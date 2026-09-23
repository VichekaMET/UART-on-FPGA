----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2026 06:02:42 PM
-- Design Name: 
-- Module Name: Data_TB_Send - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
--
-- Reads 8 slide switches and outputs their value as an 8-bit binary
-- number, registered on the clock (one clean synchronous stage between
-- the raw physical switches and whatever reads Data_out -- e.g. wire this
-- straight into UART_SEND's data_to_send port to pick the byte to send
-- with the switches).
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Data_TB_Send is
  Port ( 
        clk : in std_logic;
        rst : in std_logic;
        sw_in : in std_logic_vector(7 downto 0);
        Data_out : out std_logic_vector (7 downto 0)
  );
end Data_TB_Send;

architecture Behavioral of Data_TB_Send is

begin

    process(clk, rst)
    begin
        if rst = '1' then
            Data_out <= (others => '0');
        elsif rising_edge(clk) then
            Data_out <= sw_in;
        end if;
    end process;

end Behavioral;