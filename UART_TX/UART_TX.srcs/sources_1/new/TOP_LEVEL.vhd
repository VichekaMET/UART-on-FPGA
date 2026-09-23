----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2026 05:36:00 PM
-- Design Name: 
-- Module Name: TOP_LEVEL - Behavioral
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

entity TOP_LEVEL is
Generic (
            CLKS_PER_BIT : integer := 868 -- For 115200 baudrate
);
  Port ( 
        clk : in std_logic;
        rst : in std_logic;
        sw_in : in std_logic_vector(7 downto 0);
        TX_line : out std_logic;
        BTN : in std_logic
        
  );
end TOP_LEVEL;

architecture Behavioral of TOP_LEVEL is



component Flip_Flop is
  Port (    
        clk : in std_logic;
        rst : in std_logic;
        signal_in : in std_logic;
        sync_signal : out std_logic
  
  );
end component;

component UART_SEND is
Generic (
            CLKS_PER_BIT : integer := 868 -- For 115200 baudrate
);
  Port ( 
    clk : in std_logic;
    rst : in std_logic;
    send_trigger : in std_logic;
    data_to_send : in std_logic_vector(7 downto 0);  -- the byte to transmit

    tx_line : out std_logic;
    tx_busy : out std_logic);
end component;

component Data_TB_Send is
  Port ( 
        clk : in std_logic;
        rst : in std_logic;
        sw_in : in std_logic_vector(7 downto 0);
        Data_out : out std_logic_vector (7 downto 0)
  );
end component;



signal BTN_Sync_sig : std_logic;

signal data_sig : std_logic_vector (7 downto 0);
signal tx_busy_sig : std_logic;

begin

Sync_signal : Flip_Flop
port map (    
        clk => clk,
        rst => rst,
        signal_in => BTN,
        sync_signal => BTN_Sync_sig
  );
  
  DATA_SEND : Data_TB_Send 
  Port map ( 
        clk => clk,
        rst => rst,
        sw_in => sw_in,
        Data_out => data_sig
  );

UART_SEND_DATA : UART_SEND
generic map ( CLKS_PER_BIT => CLKS_PER_BIT )
  Port map ( 
    clk  => clk,
    rst  => rst,
    send_trigger => BTN_Sync_sig,
    data_to_send => data_sig,
    tx_line => TX_line,
    tx_busy => tx_busy_sig
);




end Behavioral;
