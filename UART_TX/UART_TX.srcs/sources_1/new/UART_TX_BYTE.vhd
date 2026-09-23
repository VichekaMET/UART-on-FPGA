library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TX_BYTE is
    Generic (
        CLKS_PER_BIT : integer := 868
    );
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        tx_start : in  std_logic;
        data_in  : in  std_logic_vector(7 downto 0);
        tx_line  : out std_logic;
        LED_state : out std_logic_vector(3 downto 0);
        tx_busy  : out std_logic
    );
end UART_TX_BYTE;

architecture Behavioral of UART_TX_BYTE is

    type state_t is (ST_IDLE, ST_START, ST_DATA, ST_STOP);
    signal state : state_t := ST_IDLE;

    signal clk_cnt : integer range 0 to CLKS_PER_BIT - 1 := 0;
    signal bit_idx : integer range 0 to 7 := 0;
    signal data_reg : std_logic_vector(7 downto 0) := (others => '0');

begin

    tx_busy <= '0' when state = ST_IDLE else '1';
    led_state <= "0001" when state = ST_IDLE  else
                 "0010" when state = ST_START else
                 "0100" when state = ST_DATA  else
                 "1000" when state = ST_STOP  else
                 "0000";
    process(clk, rst)
    begin
        if rst = '1' then
            state    <= ST_IDLE;
            tx_line  <= '1';
            clk_cnt  <= 0;
            bit_idx  <= 0;
            data_reg <= (others => '0');

        elsif rising_edge(clk) then

            case state is

                when ST_IDLE =>
                    tx_line <= '1';
                    clk_cnt <= 0;
                    bit_idx <= 0;

                    if tx_start = '1' then
                        data_reg <= data_in;
                        state <= ST_START;
                    end if;

                when ST_START =>
                    tx_line <= '0';

                    if clk_cnt = CLKS_PER_BIT - 1 then
                        clk_cnt <= 0;
                        bit_idx <= 0;
                        state <= ST_DATA;
                    else
                        clk_cnt <= clk_cnt + 1;
                    end if;

                when ST_DATA =>
                    tx_line <= data_reg(bit_idx);

                    if clk_cnt = CLKS_PER_BIT - 1 then
                        clk_cnt <= 0;

                        if bit_idx = 7 then
                            state <= ST_STOP;
                        else
                            bit_idx <= bit_idx + 1;
                        end if;
                    else
                        clk_cnt <= clk_cnt + 1;
                    end if;

                when ST_STOP =>
                    tx_line <= '1';

                    if clk_cnt = CLKS_PER_BIT - 1 then
                        clk_cnt <= 0;
                        state <= ST_IDLE;
                    else
                        clk_cnt <= clk_cnt + 1;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;