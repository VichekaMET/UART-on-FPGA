library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx_byte is
  Generic ( CLKS_PER_BIT : integer := 868 );
  Port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    rx_line  : in  std_logic;
    data_out : out std_logic_vector(7 downto 0);
    led_state  : out std_logic_vector(3 downto 0);
    rx_valid : out std_logic  
  );
end uart_rx_byte;

architecture Behavioral of uart_rx_byte is

    constant OVERSAMPLE_DIV : integer := CLKS_PER_BIT / 16;

    type state_type is (ST_IDLE, ST_START, ST_DATA, ST_STOP);
    signal state : state_type;

    signal rx_sync0, rx_sync1 : std_logic;

    signal over_cnt    : integer range 0 to OVERSAMPLE_DIV - 1;
    signal over_tick   : std_logic;
    signal sample_cnt  : integer range 0 to 15;
    signal bit_idx     : integer range 0 to 7;
    signal shift_reg   : std_logic_vector(7 downto 0);

begin

    led_state <= "0001" when state = ST_IDLE  else
                 "0010" when state = ST_START else
                 "0100" when state = ST_DATA  else
                 "1000" when state = ST_STOP  else
                 "0000";
    process(clk, rst)
    begin
        if rst = '1' then
            rx_sync0 <= '1';
            rx_sync1 <= '1';
        elsif rising_edge(clk) then
            rx_sync0 <= rx_line;
            rx_sync1 <= rx_sync0;
        end if;
    end process;

    -- 16 ticks per bit period
    process(clk, rst)
    begin
        if rst = '1' then
            over_cnt <= 0;
        elsif rising_edge(clk) then
            if state = ST_IDLE then
                over_cnt <= 0;
            elsif over_cnt = OVERSAMPLE_DIV - 1 then
                over_cnt <= 0;
            else
                over_cnt <= over_cnt + 1;
            end if;
        end if;
    end process;

    over_tick <= '1' when over_cnt = OVERSAMPLE_DIV - 1 else '0';

    process(clk, rst)
    begin
        if rst = '1' then
            state      <= ST_IDLE;
            sample_cnt <= 0;
            bit_idx    <= 0;
            shift_reg  <= (others => '0');
            rx_valid   <= '0';
        elsif rising_edge(clk) then
            rx_valid <= '0';

            case state is
                when ST_IDLE =>
                    sample_cnt <= 0;
                    if rx_sync1 = '0' then
                        state <= ST_START;
                    end if;

                when ST_START =>
                    if over_tick = '1' then
                        if sample_cnt = 7 then
                            if rx_sync1 = '0' then
                                state      <= ST_DATA;
                                sample_cnt <= 0;
                                bit_idx    <= 0;
                            else
                                state <= ST_IDLE;  -- glitch, not a real start bit
                            end if;
                        else
                            sample_cnt <= sample_cnt + 1;
                        end if;
                    end if;

                when ST_DATA =>
                    if over_tick = '1' then
                        if sample_cnt = 15 then
                            sample_cnt <= 0;
                            shift_reg  <= rx_sync1 & shift_reg(7 downto 1);
                            if bit_idx = 7 then
                                state <= ST_STOP;
                            else
                                bit_idx <= bit_idx + 1;
                            end if;
                        else
                            sample_cnt <= sample_cnt + 1;
                        end if;
                    end if;

                when ST_STOP =>
                    if over_tick = '1' then
                        if sample_cnt = 15 then
                            state    <= ST_IDLE;
                            rx_valid <= '1';
                        else
                            sample_cnt <= sample_cnt + 1;
                        end if;
                    end if;

                when others =>
                    state <= ST_IDLE;
            end case;
        end if;
    end process;

    data_out <= shift_reg;

end Behavioral;