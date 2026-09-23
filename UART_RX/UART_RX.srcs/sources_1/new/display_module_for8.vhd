----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2026 11:19:13 AM
-- Design Name: 
-- Module Name: display_module_for8 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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
entity display_module_for8 is
    Port(  
        bcd0: in std_logic_vector(3 downto 0);
        bcd1: in std_logic_vector(3 downto 0);
        bcd2: in std_logic_vector(3 downto 0);
        bcd3: in std_logic_vector(3 downto 0);
        bcd4: in std_logic_vector(3 downto 0);
        bcd5: in std_logic_vector(3 downto 0);
        bcd6: in std_logic_vector(3 downto 0);
        bcd7: in std_logic_vector(3 downto 0);
        rst : in std_logic;
        dp_vector: in std_logic_vector(3 downto 0);
        clk : in std_logic;
        dp_out : out std_logic;
        bcd_out: out std_logic_vector(6 downto 0);
        AN_out : out  std_logic_vector(7 downto 0)
    );
end display_module_for8;
architecture Behavioral of display_module_for8 is
component  data_controller_for8 is
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
      end component ;
      
component bcd_decoder is
    port (  data: in std_logic_vector(3 downto 0);
            dp_int: in std_logic;
            dp_out : out std_logic;
            bcd_out: out std_logic_vector(6 downto 0) 
    );   
end component ;
component an_generator is
    Port ( clk: in std_logic;
        rst : in std_logic;
        AN_out : out std_logic_vector(7 downto 0)
     );
end component ;
--internal signals for the mux
signal dp_int_bcd : std_logic;
signal data_int_bcd : std_logic_vector(3 downto 0);
signal an_for_data_controller:std_logic_vector(7 downto 0); 
begin
AN_out<=an_for_data_controller;
-- an generator       
an_generator_1: an_generator port map(
    clk=>clk,
    rst=>rst,
    AN_out=>an_for_data_controller);
-- data controller 
data_controller_1:  data_controller_for8 port map(
    bcd0=> bcd0,
    bcd1=> bcd1,
    bcd2=> bcd2,
    bcd3=> bcd3,
    bcd4=> bcd4,
    bcd5=> bcd5,
    bcd6=> bcd6,
    bcd7=> bcd7,
    dp_vector=>dp_vector,
    data_out=>data_int_bcd,
    AN=>an_for_data_controller,
    dp_out=>dp_int_bcd);           
           
-- bcd decoder
bcd_decoder_1: bcd_decoder port map (
    data=>data_int_bcd,
    dp_int=>dp_int_bcd,
    dp_out=>dp_out,
    bcd_out=>bcd_out);
end Behavioral;