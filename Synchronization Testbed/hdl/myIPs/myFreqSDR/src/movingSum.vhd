library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity moving_sum is
    generic (
        N : integer := 25;
        log2L : integer := 1 );
    port (
        -- input
        dataIn                    : in  std_logic_vector(N-1 downto 0);
        enable                    : in  std_logic;

        -- output
        dataOut                  : out std_logic_vector(N+log2L-1 downto 0);
        clk                      : in  std_logic;
        arstn                     : in  std_logic);
end moving_sum;

architecture rtl of moving_sum is

    type memory is array (0 to 2**log2L-1) of std_logic_vector(N-1 downto 0);

    signal memoryMoving   : memory;
    signal acc            : signed(N+log2L-1 downto 0):= (others => '0');  -- average accumulator
    signal diff           : signed(N downto 0):= (others => '0');  -- average accumulator

begin


    process(clk,arstn)
    begin
        if(arstn='0') then
            memoryMoving     <= (others=>(others=>'0'));
            dataOut          <= (others=>'0');
            acc          <= (others=>'0');
            diff             <= (others=>'0');
        elsif(rising_edge(clk)) then
            if(enable='1') then
                memoryMoving  <= dataIn & memoryMoving(0 to memoryMoving'length-2);
                diff <= resize(signed(dataIn),N+1) - resize(signed(memoryMoving(memoryMoving'length-1)), N+1);
                acc <= acc + resize(diff,N+log2L) ;
            end if;

            dataOut  <= std_logic_vector(acc);

        end if;
    end process;

end rtl;