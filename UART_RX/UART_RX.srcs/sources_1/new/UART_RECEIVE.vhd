library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_RECEIVE is
Generic (
            CLKS_PER_BIT : integer := 868 -- For 115200 baudrate
);
  Port (
    clk : in std_logic;
    rst : in std_logic;

    rx_line : in std_logic;

    data_out  : out std_logic_vector(7 downto 0); -- last byte received
    new_byte  : out std_logic;                     -- 1-cycle pulse on new byte
    match_ok  : out std_logic                      -- '1' while last byte = 00011100
    );
end UART_RECEIVE;

architecture Behavioral of UART_RECEIVE is

component uart_rx_byte is
  Generic ( CLKS_PER_BIT : integer := 868 );
  Port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    rx_line  : in  std_logic;
    data_out : out std_logic_vector(7 downto 0);
    rx_valid : out std_logic
  );
end component;

signal rx_byte  : std_logic_vector(7 downto 0);
signal rx_valid : std_logic;

begin

uart_rx_byte_1 : uart_rx_byte
    generic map ( CLKS_PER_BIT => CLKS_PER_BIT )
    port map (
        clk      => clk,
        rst      => rst,
        rx_line  => rx_line,
        data_out => rx_byte,
        rx_valid => rx_valid
    );

data_out <= rx_byte;
new_byte <= rx_valid;
match_ok <= '1' when rx_byte = "00011100" else '0';

end Behavioral;