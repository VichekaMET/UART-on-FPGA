----------------------------------------------------------------------------
-- UART_SEND TESTBENCH (VHDL-93 compatible -- no to_string, no 2008-only &)
--
-- 1. Instantiate the DUT (UART_SEND)
-- 2. Generate a free-running clock
-- 3. Apply and release reset
-- 4. For each test value: set data_to_send, click send_trigger, bit-bang
--    decode the byte straight off tx_line, and check it matches
-- 5. Repeat across several distinct byte values, including edge cases
--
-- NOTE: an earlier version of this testbench used to_string() and
-- string & std_logic_vector concatenation in the report lines -- both of
-- those need VHDL-2008. Since this project compiles simulation sources
-- under the default (older) VHDL setting, this version replaces those
-- with a small hand-written byte_to_str function instead, so it compiles
-- without changing any project settings.
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_uart_send_generic is
end entity tb_uart_send_generic;

architecture sim of tb_uart_send_generic is

    constant CLK_PERIOD   : time := 10 ns;
    constant CLKS_PER_BIT : integer := 868;
    constant BIT_PERIOD   : time := CLKS_PER_BIT * CLK_PERIOD;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal send_trigger : std_logic := '0';
    signal data_to_send : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_line : std_logic;
    signal tx_busy : std_logic;

    signal sim_done : boolean := false;

    -- hand-written 8-bit vector -> string helper (no to_string needed)
    function byte_to_str(v : std_logic_vector(7 downto 0)) return string is
        variable result : string(1 to 8);
    begin
        for i in 0 to 7 loop
            if v(7 - i) = '1' then
                result(i + 1) := '1';
            else
                result(i + 1) := '0';
            end if;
        end loop;
        return result;
    end function;

begin

    dut : entity work.UART_SEND
        generic map ( CLKS_PER_BIT => CLKS_PER_BIT )
        port map (
            clk => clk, rst => rst,
            send_trigger => send_trigger,
            data_to_send => data_to_send,
            tx_line => tx_line, tx_busy => tx_busy
        );

    clk_gen : process
    begin
        while not sim_done loop
            clk <= '0'; wait for CLK_PERIOD / 2;
            clk <= '1'; wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    stim : process

        -- bit-bang receiver: decodes one byte straight off tx_line, the
        -- same way a real external UART device would see it
        procedure uart_receive(variable byte_out : out std_logic_vector(7 downto 0)) is
        begin
            wait until tx_line = '0';       -- start bit begins
            wait for BIT_PERIOD / 2;        -- move to start bit's centre
            wait for BIT_PERIOD;            -- move to bit 0's centre
            for i in 0 to 7 loop
                byte_out(i) := tx_line;     -- LSB first
                wait for BIT_PERIOD;
            end loop;
        end procedure;

        -- helper: set a value, click send_trigger, verify the byte that
        -- actually comes out on the wire
        procedure click_and_check(val : std_logic_vector(7 downto 0); name : string) is
            variable rx_byte : std_logic_vector(7 downto 0);
        begin
            data_to_send <= val;
            wait for 2 * CLK_PERIOD;
            send_trigger <= '1';

            uart_receive(rx_byte);
            if rx_byte = val then
                report name & " PASSED: correctly sent " & byte_to_str(val);
            else
                report name & " FAILED: expected " & byte_to_str(val) &
                    " got " & byte_to_str(rx_byte)
                    severity error;
            end if;

            wait until tx_busy = '0';
            send_trigger <= '0';
            wait for 10 * CLK_PERIOD;
        end procedure;

    begin
        -- STEP 3: reset
        rst <= '1';
        wait for 5 * CLK_PERIOD;
        rst <= '0';
        wait for 5 * CLK_PERIOD;

        -- STEP 4-5: test vectors
        click_and_check("00011100", "TEST 1 (28 decimal)");
        click_and_check("11111111", "TEST 2 (255, all ones)");
        click_and_check("00000000", "TEST 3 (0, all zeros)");
        click_and_check("10101010", "TEST 4 (alternating)");
        click_and_check("01111111", "TEST 5 (127)");

        report "ALL TESTS COMPLETE";
        sim_done <= true;
        wait;
    end process;

end architecture sim;