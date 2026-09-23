----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 09/16/2026
-- Design Name:
-- Module Name: Flip_Flop - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: Synchronizer + Switch Debouncer
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Flip_Flop is
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        signal_in   : in  std_logic;
        sync_signal : out std_logic
    );
end Flip_Flop;

architecture Behavioral of Flip_Flop is

    -- 2 flip-flop synchronizer
    signal Q1 : std_logic := '0';
    signal Q2 : std_logic := '0';

    -- Debouncer
    signal sw_state : std_logic := '0';
    signal counter  : unsigned(20 downto 0) := (others => '0');

    constant DEBOUNCE_COUNT : unsigned(20 downto 0) :=
        to_unsigned(2_000_000 - 1, 21);

begin

    process(clk, rst)
    begin

        if rst = '1' then

            Q1      <= '0';
            Q2      <= '0';
            sw_state <= '0';
            counter <= (others => '0');

        elsif rising_edge(clk) then
            Q1 <= signal_in;
            Q2 <= Q1;

            if Q2 = sw_state then

                counter <= (others => '0');

            else

                if counter = DEBOUNCE_COUNT then

                    sw_state <= Q2;
                    counter  <= (others => '0');

                else

                    counter <= counter + 1;

                end if;

            end if;

        end if;

    end process;

    sync_signal <= sw_state;

end Behavioral;