library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_SEND is
    Generic (
        CLKS_PER_BIT : integer := 868
    );
    Port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        send_trigger : in  std_logic;
        data_to_send : in  std_logic_vector(7 downto 0);

        tx_line      : out std_logic;
        tx_busy      : out std_logic
    );
end UART_SEND;

architecture Behavioral of UART_SEND is

    component UART_TX_BYTE is
        Generic (
            CLKS_PER_BIT : integer := 868
        );
        Port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            tx_start : in  std_logic;
            data_in  : in  std_logic_vector(7 downto 0);
            tx_line  : out std_logic;
            tx_busy  : out std_logic
        );
    end component;

    type state_type is (
        ST_IDLE,
        ST_SEND_STAT,
        ST_CONFIRM_BUSY,
        ST_WAIT_STAT
    );

    signal state : state_type := ST_IDLE;

    signal byte_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal byte_start : std_logic := '0';
    signal byte_busy  : std_logic;

    signal send_trigger_d : std_logic := '0';

begin

    tx_busy <= '0' when state = ST_IDLE else '1';

    uart_tx_byte_1 : UART_TX_BYTE
        generic map (
            CLKS_PER_BIT => CLKS_PER_BIT
        )
        port map (
            clk      => clk,
            rst      => rst,
            tx_start => byte_start,
            data_in  => byte_data,
            tx_line  => tx_line,
            tx_busy  => byte_busy
        );

    process(clk, rst)
    begin
        if rst = '1' then

            state          <= ST_IDLE;
            byte_start     <= '0';
            byte_data      <= (others => '0');
            send_trigger_d <= '0';

        elsif rising_edge(clk) then

            byte_start     <= '0';
            send_trigger_d <= send_trigger;

            case state is

                when ST_IDLE =>
                    if send_trigger = '1' and send_trigger_d = '0' then
                        state <= ST_SEND_STAT;
                    end if;

                when ST_SEND_STAT =>
                    byte_data  <= data_to_send;
                    byte_start <= '1';
                    state      <= ST_CONFIRM_BUSY;

                when ST_CONFIRM_BUSY =>
                    if byte_busy = '1' then
                        state <= ST_WAIT_STAT;
                    end if;

                when ST_WAIT_STAT =>
                    if byte_busy = '0' then
                        state <= ST_IDLE;
                    end if;

                when others =>
                    state <= ST_IDLE;

            end case;

        end if;
    end process;

end Behavioral;