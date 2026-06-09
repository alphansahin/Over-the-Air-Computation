----------------------------------------------------------------------------------
-- A good reference: https://blog.abbey1.org.uk/index.php/technology/adder-trees-pipelined-efficiently-by-recursion

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder_tree is
    generic (
        IS_PIPELINED        : boolean := FALSE;
        INPUT_DATA_WIDTH    : positive := 16;
        NUMBER_OF_SUMMANDS  : positive := 8;
        CLOG2_NUMBER_OF_SUMMANDS  : positive := 3
    );
    port (
        i_clk       : in std_logic;
        i_rst_n     : in std_logic;
        i_enable    : in std_logic;
        i_data      : in std_logic_vector(NUMBER_OF_SUMMANDS*INPUT_DATA_WIDTH - 1 downto 0);
        o_sum       : out std_logic_vector(INPUT_DATA_WIDTH + CLOG2_NUMBER_OF_SUMMANDS -1 downto 0)
    );
end entity;

architecture Behavioral of adder_tree is
    
    component adder_tree
        generic (
            IS_PIPELINED        : boolean;
            INPUT_DATA_WIDTH    : positive;
            NUMBER_OF_SUMMANDS  : positive;
            CLOG2_NUMBER_OF_SUMMANDS: positive
        );
        port (
            i_clk       : in std_logic;
            i_rst_n      : in std_logic;
            i_enable    : in std_logic;
            i_data      : in std_logic_vector(NUMBER_OF_SUMMANDS*INPUT_DATA_WIDTH - 1 downto 0);
            o_sum       : out std_logic_vector(INPUT_DATA_WIDTH + CLOG2_NUMBER_OF_SUMMANDS -1 downto 0)
        );
    end component;
    
    type signed_array_t is array (natural range <>) of signed;
    signal summands : signed_array_t(NUMBER_OF_SUMMANDS-1 downto 0)(0 to INPUT_DATA_WIDTH - 1);
    
begin
    -- Input stage: Copy inputs to the first stage of the adder tree
    generate_summands: for i in 0 to NUMBER_OF_SUMMANDS - 1 generate
        summands(i) <= signed(i_data( (i+1)*INPUT_DATA_WIDTH - 1 downto i*INPUT_DATA_WIDTH ));
    end generate generate_summands;
    
    
    GEN_RECURSIVE1 : if NUMBER_OF_SUMMANDS = 1 generate
        PIPED : if IS_PIPELINED = TRUE generate
            process(i_clk,i_rst_n)
            begin
                if (i_rst_n = '0') then
                    o_sum <= (others => '0');
                elsif rising_edge(i_clk) then
                    if i_enable = '1' then
                        o_sum <= std_logic_vector(summands(0));
                    end if;
                end if;
            end process;
        end generate PIPED;
        NOT_PIPED : if IS_PIPELINED = FALSE generate
            o_sum <=  std_logic_vector(summands(0)); -- No resize as log2(1) = 0 additional bits on the output.
        end generate NOT_PIPED;
    end generate GEN_RECURSIVE1;

    GEN_RECURSIVE2 : if NUMBER_OF_SUMMANDS = 2 generate
        PIPED : if IS_PIPELINED = TRUE generate
            process(i_clk,i_rst_n)
            begin
                if (i_rst_n = '0') then
                    o_sum <= (others => '0');
                elsif rising_edge(i_clk) then
                    if i_enable = '1' then
                        o_sum <= std_logic_vector(resize(summands(0), o_sum'length) + resize(summands(1), o_sum'length));
                    end if;
                end if;
            end process;
        end generate PIPED;
        NOT_PIPED : if IS_PIPELINED = FALSE generate
            o_sum <= std_logic_vector(resize(summands(0), o_sum'length) + resize(summands(1), o_sum'length));
        end generate NOT_PIPED;

    end generate GEN_RECURSIVE2;
    GEN_RECURSIVEN : if NUMBER_OF_SUMMANDS > 2 generate
        constant NUMBER_OF_SUMMANDS_PART1 : natural :=  positive((NUMBER_OF_SUMMANDS / 2));
        signal r_sum_left   : std_logic_vector(INPUT_DATA_WIDTH + CLOG2_NUMBER_OF_SUMMANDS-1 downto 0);
        signal r_sum_right  : std_logic_vector(INPUT_DATA_WIDTH + CLOG2_NUMBER_OF_SUMMANDS-1 downto 0);
    begin
        adder_left : component adder_tree
            generic map (
                IS_PIPELINED        => IS_PIPELINED,
                NUMBER_OF_SUMMANDS  => NUMBER_OF_SUMMANDS_PART1,
                INPUT_DATA_WIDTH    => INPUT_DATA_WIDTH,
                CLOG2_NUMBER_OF_SUMMANDS => CLOG2_NUMBER_OF_SUMMANDS
            )
            port map (
                i_clk    => i_clk,
                i_rst_n   => i_rst_n,
                i_enable => i_enable,
                i_data   => i_data(NUMBER_OF_SUMMANDS_PART1*INPUT_DATA_WIDTH-1 downto 0),
                o_sum    => r_sum_left
            );

        adder_right : component adder_tree
            generic map (
                IS_PIPELINED        => IS_PIPELINED,
                NUMBER_OF_SUMMANDS  => NUMBER_OF_SUMMANDS - NUMBER_OF_SUMMANDS_PART1,
                INPUT_DATA_WIDTH    => INPUT_DATA_WIDTH,
                CLOG2_NUMBER_OF_SUMMANDS => CLOG2_NUMBER_OF_SUMMANDS
            )
            port map (
                i_clk    => i_clk,
                i_rst_n  => i_rst_n,
                i_enable => i_enable,
                i_data   => i_data(NUMBER_OF_SUMMANDS*INPUT_DATA_WIDTH-1 downto NUMBER_OF_SUMMANDS_PART1*INPUT_DATA_WIDTH),
                o_sum    => r_sum_right
            );

        PIPED : if IS_PIPELINED = TRUE generate
            process(i_clk,i_rst_n)
            begin
                if (i_rst_n = '0') then
                    o_sum <= (others => '0');
                elsif rising_edge(i_clk) then
                    if i_enable = '1' then
                        o_sum <= resize(r_sum_left, o_sum'length) + resize(r_sum_right, o_sum'length);
                    end if;
                end if;
            end process;
        end generate PIPED;
        NOT_PIPED : if IS_PIPELINED = FALSE generate
            o_sum <= resize(r_sum_left, o_sum'length) + resize(r_sum_right, o_sum'length);
        end generate NOT_PIPED;

    end;
    end generate GEN_RECURSIVEN;
end Behavioral;
