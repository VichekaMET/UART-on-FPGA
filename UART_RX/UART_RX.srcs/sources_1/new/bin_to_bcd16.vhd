----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2026 09:31:29 AM
-- Design Name: 
-- Module Name: bin_to_bcd16 - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity bin_to_bcd16 is
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
end bin_to_bcd16;

architecture Behavioral of bin_to_bcd16 is

    signal shift_reg: std_logic_vector(35 downto 0);
    signal bit_cnt: unsigned(4 downto 0);

    type conv_state_t is (ST_CONV_IDLE, ST_CONV_RUN, ST_CONV_DONE);
    signal conv_state: conv_state_t;

    signal digit0_c: std_logic_vector(3 downto 0);
    signal digit1_c: std_logic_vector(3 downto 0);
    signal digit2_c: std_logic_vector(3 downto 0);
    signal digit3_c: std_logic_vector(3 downto 0);
    signal digit4_c: std_logic_vector(3 downto 0);

    signal next_shift_reg: std_logic_vector(35 downto 0);

    signal digit_u_reg: std_logic_vector(3 downto 0);
    signal digit_t_reg: std_logic_vector(3 downto 0);
    signal digit_h_reg: std_logic_vector(3 downto 0);
    signal digit_th_reg: std_logic_vector(3 downto 0);
    signal digit_ten_k_reg: std_logic_vector(3 downto 0);
    signal done_reg: std_logic;

begin

    -- per-nibble "add 3 if >= 5" correction (double dabble)
    digit0_c <= std_logic_vector(unsigned(shift_reg(19 downto 16)) + 3)
                when unsigned(shift_reg(19 downto 16)) >= 5 else shift_reg(19 downto 16);

    digit1_c <= std_logic_vector(unsigned(shift_reg(23 downto 20)) + 3)
                when unsigned(shift_reg(23 downto 20)) >= 5 else shift_reg(23 downto 20);

    digit2_c <= std_logic_vector(unsigned(shift_reg(27 downto 24)) + 3)
                when unsigned(shift_reg(27 downto 24)) >= 5 else shift_reg(27 downto 24);

    digit3_c <= std_logic_vector(unsigned(shift_reg(31 downto 28)) + 3)
                when unsigned(shift_reg(31 downto 28)) >= 5 else shift_reg(31 downto 28);

    digit4_c <= std_logic_vector(unsigned(shift_reg(35 downto 32)) + 3)
                when unsigned(shift_reg(35 downto 32)) >= 5 else shift_reg(35 downto 32);

    next_shift_reg <= digit4_c & digit3_c & digit2_c & digit1_c & digit0_c
                       & shift_reg(15 downto 0);

    -- conversion FSM: load -> shift x16 -> latch digits
    process(clk, rst)
    begin
        if rst = '1' then
            conv_state <= ST_CONV_IDLE;
            shift_reg <= (others => '0');
            bit_cnt <= (others => '0');
            digit_u_reg <= (others => '0');
            digit_t_reg <= (others => '0');
            digit_h_reg <= (others => '0');
            digit_th_reg <= (others => '0');
            digit_ten_k_reg <= (others => '0');
            done_reg <= '0';
        elsif rising_edge(clk) then
            done_reg <= '0';

            case conv_state is
                when ST_CONV_IDLE =>
                    if start = '1' then
                        shift_reg <= (35 downto 16 => '0') & bin_value;
                        bit_cnt <= (others => '0');
                        conv_state <= ST_CONV_RUN;
                    end if;

                when ST_CONV_RUN =>
                    shift_reg <= next_shift_reg(34 downto 0) & '0';
                    if bit_cnt = to_unsigned(15, bit_cnt'length) then
                        conv_state <= ST_CONV_DONE;
                    else
                        bit_cnt <= bit_cnt + 1;
                    end if;

                when ST_CONV_DONE =>
                    digit_u_reg <= shift_reg(19 downto 16);
                    digit_t_reg <= shift_reg(23 downto 20);
                    digit_h_reg <= shift_reg(27 downto 24);
                    digit_th_reg <= shift_reg(31 downto 28);
                    digit_ten_k_reg <= shift_reg(35 downto 32);
                    done_reg <= '1';
                    conv_state <= ST_CONV_IDLE;

                when others =>
                    conv_state <= ST_CONV_IDLE;
            end case;
        end if;
    end process;

    done <= done_reg;
    digit_ten_k <= digit_ten_k_reg;
    digit_th <= digit_th_reg;
    digit_h <= digit_h_reg;
    digit_t <= digit_t_reg;
    digit_u <= digit_u_reg;

end Behavioral;