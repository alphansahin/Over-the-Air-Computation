----------------------------------------------------------------------------------
-- A good reference: https://blog.abbey1.org.uk/index.php/technology/adder-trees-pipelined-efficiently-by-recursion

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

entity adder_tree_nonrecursive is
    generic (
        INPUT_DATA_WIDTH    : positive := 16;
        NUMBER_OF_SUMMANDS  : positive := 8
    );
    port (
        i_clk       : in std_logic;
        i_rst_n     : in std_logic;
        i_enable    : in std_logic;
        i_data      : in std_logic_vector(NUMBER_OF_SUMMANDS*INPUT_DATA_WIDTH - 1 downto 0);
        o_sum       : out std_logic_vector(INPUT_DATA_WIDTH + integer(ceil(log2(real(NUMBER_OF_SUMMANDS)))) -1 downto 0)
    );
end entity;

architecture Behavioral of adder_tree_nonrecursive is
    constant CLOG2_NUMBER_OF_SUMMANDS  : integer := integer(ceil(log2(real(NUMBER_OF_SUMMANDS))));
    constant NUMBER_OF_INTERMEDIATE_SUMS_REGS : integer := 2**(CLOG2_NUMBER_OF_SUMMANDS+1)-1;
    constant OUTPUT_DATA_WIDTH : integer := CLOG2_NUMBER_OF_SUMMANDS + INPUT_DATA_WIDTH;

    type std_vector_array_t is array (natural range <>) of std_logic_vector(OUTPUT_DATA_WIDTH-1 downto 0) ;
    signal intermediate_sums : std_vector_array_t(NUMBER_OF_INTERMEDIATE_SUMS_REGS - 1 downto 0);
    
    
    attribute use_dsp : string;
    attribute use_dsp of intermediate_sums : signal is "YES";

begin
    process(i_clk,i_rst_n)
    begin
        if (i_rst_n = '0') then
            intermediate_sums <= (others=>(others => '0'));
        elsif rising_edge(i_clk) then
            if i_enable = '1' then
                for indLevel in 0 to CLOG2_NUMBER_OF_SUMMANDS loop
                    for indAdder in 0 to (2**indLevel) - 1 loop
                        if indLevel = CLOG2_NUMBER_OF_SUMMANDS then
                            intermediate_sums(2**indLevel -1 + indAdder)(INPUT_DATA_WIDTH-1 downto 0)           <= std_logic_vector(signed(i_data( (indAdder+1)*INPUT_DATA_WIDTH - 1 downto indAdder*INPUT_DATA_WIDTH )));
                        else
                            intermediate_sums(2**indLevel -1 + indAdder)(OUTPUT_DATA_WIDTH-indLevel-1 downto 0) <= std_logic_vector(resize(signed(intermediate_sums(2**(indLevel+1)-1 + 2*indAdder)(OUTPUT_DATA_WIDTH-indLevel-2 downto 0)),OUTPUT_DATA_WIDTH-indLevel) + resize(signed(intermediate_sums(2**(indLevel+1)-1 + 2*indAdder+1)(OUTPUT_DATA_WIDTH-indLevel-2 downto 0)),OUTPUT_DATA_WIDTH-indLevel));
                        end if;
                    end loop;
                end loop;
            end if;
        end if;
    end process;

    -- Output stage: Assign the final sum
    o_sum <= std_logic_vector(intermediate_sums(0));

end Behavioral;
