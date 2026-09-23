----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2026
-- Design Name: 
-- Module Name: UART_RECEIVE_DISPLAY - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
--
-- Top-level module: receives a byte over UART, stores it, converts it to
-- BCD, and displays its decimal value on the 8-digit display.
-- Pipeline: UART_RECEIVE -> Data_Storage -> bin_to_bcd16 -> display_module_for8.
-- 
-- Dependencies: UART_RECEIVE, uart_rx_byte, Data_Storage, bin_to_bcd16,
-- display_module_for8, an_generator, bcd_decoder, data_controller_for8
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_RECEIVE_DISPLAY is
Generic (
            CLKS_PER_BIT : integer := 868 -- For 115200 baudrate
);
  Port (
    clk : in std_logic;
    rst : in std_logic;

    rx_line : in std_logic;

    -- BCD 7-segment display outputs
    dp_out  : out std_logic;
    bcd_out : out std_logic_vector(6 downto 0);
    AN_out  : out std_logic_vector(7 downto 0)
    );
end UART_RECEIVE_DISPLAY;

architecture Behavioral of UART_RECEIVE_DISPLAY is

component UART_RECEIVE is
Generic (
            CLKS_PER_BIT : integer := 868
);
  Port (
    clk : in std_logic;
    rst : in std_logic;
    rx_line : in std_logic;
    data_out  : out std_logic_vector(7 downto 0);
    new_byte  : out std_logic;
    match_ok  : out std_logic
    );
end component;

component Data_Storage is
  Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        data_in  : in  std_logic_vector(7 downto 0);
        store_en : in  std_logic;
        data_out : out std_logic_vector(7 downto 0)
  );
end component;

component bin_to_bcd16 is
    Port(
        clk: in std_logic;
        rst: in std_logic;
        start: in std_logic;
        bin_value: in std_logic_vector(15 downto 0);
        done: out std_logic;
        digit_ten_k: out std_logic_vector(3 downto 0);
        digit_th: out std_logic_vector(3 downto 0);
        digit_h: out std_logic_vector(3 downto 0);
        digit_t: out std_logic_vector(3 downto 0);
        digit_u: out std_logic_vector(3 downto 0)
    );
end component;

component display_module_for8 is
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
end component;

signal rx_data   : std_logic_vector(7 downto 0);
signal new_byte  : std_logic;
signal match_ok  : std_logic;

-- stored copy of the received byte, and a delayed start pulse to match
-- its 1-cycle registered latency
signal stored_data : std_logic_vector(7 downto 0);
signal new_byte_d1 : std_logic;

-- zero-extended 16-bit version of stored_data, as its own signal (VHDL-93
-- port map actuals must be a plain signal name, not an expression)
signal bin_value_ext : std_logic_vector(15 downto 0);

signal digit_ten_k : std_logic_vector(3 downto 0);
signal digit_th    : std_logic_vector(3 downto 0);
signal digit_h     : std_logic_vector(3 downto 0);
signal digit_t     : std_logic_vector(3 downto 0);
signal digit_u     : std_logic_vector(3 downto 0);
signal bcd_done    : std_logic;

signal disp_ten_k : std_logic_vector(3 downto 0) := (others => '0');
signal disp_th    : std_logic_vector(3 downto 0) := (others => '0');
signal disp_h     : std_logic_vector(3 downto 0) := (others => '0');
signal disp_t     : std_logic_vector(3 downto 0) := (others => '0');
signal disp_u     : std_logic_vector(3 downto 0) := (others => '0');

begin

UART_RECEIVE_1 : UART_RECEIVE
    Generic map ( CLKS_PER_BIT => CLKS_PER_BIT )
    port map (
        clk      => clk,
        rst      => rst,
        rx_line  => rx_line,
        data_out => rx_data,
        new_byte => new_byte,
        match_ok => match_ok
    );

Data_Storage_1 : Data_Storage
    port map (
        clk      => clk,
        rst      => rst,
        data_in  => rx_data,
        store_en => new_byte,
        data_out => stored_data
    );

-- delay the start trigger by 1 cycle so it lines up with stored_data
-- actually holding the newly captured byte
process(clk, rst)
begin
    if rst = '1' then
        new_byte_d1 <= '0';
    elsif rising_edge(clk) then
        new_byte_d1 <= new_byte;
    end if;
end process;

bin_value_ext <= "00000000" & stored_data;   -- zero-extend 8 bits to 16

bin_to_bcd16_1 : bin_to_bcd16
    port map (
        clk         => clk,
        rst         => rst,
        start       => new_byte_d1,
        bin_value   => bin_value_ext,
        done        => bcd_done,
        digit_ten_k => digit_ten_k,
        digit_th    => digit_th,
        digit_h     => digit_h,
        digit_t     => digit_t,
        digit_u     => digit_u
    );

-- latch stable digits for the display once conversion is done
process(clk, rst)
begin
    if rst = '1' then
        disp_ten_k <= (others => '0');
        disp_th    <= (others => '0');
        disp_h     <= (others => '0');
        disp_t     <= (others => '0');
        disp_u     <= (others => '0');
    elsif rising_edge(clk) then
        if bcd_done = '1' then
            disp_ten_k <= digit_ten_k;
            disp_th    <= digit_th;
            disp_h     <= digit_h;
            disp_t     <= digit_t;
            disp_u     <= digit_u;
        end if;
    end if;
end process;

display_1 : display_module_for8
    port map (
        bcd0      => disp_u,
        bcd1      => disp_t,
        bcd2      => disp_h,
        bcd3      => disp_th,
        bcd4      => disp_ten_k,
        bcd5      => "0000",
        bcd6      => "0000",
        bcd7      => "0000",
        rst       => rst,
        dp_vector => "0000",
        clk       => clk,
        dp_out    => dp_out,
        bcd_out   => bcd_out,
        AN_out    => AN_out
    );

end Behavioral;