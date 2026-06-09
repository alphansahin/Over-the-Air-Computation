-- Entity Declaration
library IEEE;
use IEEE.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIR_architecture1 is
    generic (
        TDM_RATE            : integer;
        INPUT_DATA_WIDTH    : integer;
        COEFF_WIDTH         : integer;
        NUMBER_OF_TAPS      : integer
    );
    port (
        i_clk : in  std_logic;
        i_rst_n : in  std_logic;
        i_newData: in  std_logic;
        i_coefficientsParellel : in std_logic_vector(integer(NUMBER_OF_TAPS/TDM_RATE*COEFF_WIDTH)-1 downto 0);
        i_dataParellel : in std_logic_vector(NUMBER_OF_TAPS/TDM_RATE*INPUT_DATA_WIDTH-1 downto 0);
        o_valid: out std_logic;
        o_data : out std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+integer(ceil(log2(real(NUMBER_OF_TAPS))))-1 downto 0)
    );
end FIR_architecture1;

architecture Behavioral of FIR_architecture1 is
    constant CLOG2_NUMBER_OF_TAPS: integer := integer(ceil(log2(real(NUMBER_OF_TAPS))));
    constant CLOG2_TDM_RATE: integer :=integer(ceil(log2(real(TDM_RATE))));
    constant NUMBER_OF_PARALLEL_MACS : integer := NUMBER_OF_TAPS/TDM_RATE;
    constant MAC_WIDTH : integer := COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_TDM_RATE;
    constant OUTPUT_DATA_WIDTH : integer := COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS;
    
    constant LATENCY_PIPELINE : integer := 3;


    signal ready: std_logic;

    type std_logic_vector_array1_t is array (natural range <>) of std_logic_vector(MAC_WIDTH-1 downto 0);
    signal product_r : std_logic_vector_array1_t(0 to NUMBER_OF_PARALLEL_MACS-1);

    signal mac_r : std_logic_vector_array1_t(0 to NUMBER_OF_PARALLEL_MACS-1);
    signal mac_r_pre : std_logic_vector_array1_t(0 to NUMBER_OF_PARALLEL_MACS-1);
    signal macs_adderTree_r : std_logic_vector(NUMBER_OF_PARALLEL_MACS*MAC_WIDTH-1 downto 0);

    type std_logic_vector_array2_t is array (natural range <>) of std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal din_r : std_logic_vector_array2_t(0 to NUMBER_OF_PARALLEL_MACS-1) := (others => (others => '0'));

    type std_logic_vector_array3_t is array (0 to NUMBER_OF_PARALLEL_MACS-1) of std_logic_vector(COEFF_WIDTH-1 downto 0);
    signal coefficient_r : std_logic_vector_array3_t;
    
    signal r_dout : std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+integer(ceil(log2(real(NUMBER_OF_TAPS))))-1 downto 0);

    attribute use_dsp : string;
    attribute use_dsp of mac_r : signal is "YES";
    attribute use_dsp of product_r : signal is "YES";

    signal r_newData: std_logic_vector(0 downto 0);
    signal r_newData_delayed: std_logic;

    component zLine is
        generic (
            DELAY_CYCLES : integer ;  -- The 'k' in z^(-k)
            DATA_WIDTH   : positive   -- Arbitrary data width
        );
        port (
            i_clk  : in  std_logic;
            i_rst_n  : in  std_logic;
            i_enable: in std_logic;
            i_data : in  std_logic_vector;
            o_data:  out std_logic_vector
        );
    end component zLine;

    component adder_tree_nonrecursive
        generic (
            INPUT_DATA_WIDTH    : positive;
            NUMBER_OF_SUMMANDS  : positive
        );
        port (
            i_clk       : in std_logic;
            i_rst_n      : in std_logic;
            i_enable    : in std_logic;
            i_data      : in std_logic_vector;
            o_sum       : out std_logic_vector
        );
    end component adder_tree_nonrecursive;
begin
     r_newData(0) <= i_newData;

    z_readData: component zLine
    generic map(
        DELAY_CYCLES => LATENCY_PIPELINE,
        DATA_WIDTH   => 1   -- Arbitrary data width
    )
    port map(
        i_clk  => i_clk,
        i_rst_n  => i_rst_n,
        i_enable => '1',
        i_data => r_newData,
        o_data(0) => r_newData_delayed
    );


    GEN_COEF_DATA_MAC: for i in 0 to NUMBER_OF_PARALLEL_MACS-1 generate
        coefficient_r(i) <= i_coefficientsParellel( i*COEFF_WIDTH +  COEFF_WIDTH-1 downto i*COEFF_WIDTH); -- Initialize all elements to '00'
        din_r(i) <= i_dataParellel(i*INPUT_DATA_WIDTH+ INPUT_DATA_WIDTH -1 downto i*INPUT_DATA_WIDTH);
        mac_r(i) <= std_logic_vector(resize(signed(product_r(i)) + signed(mac_r_pre(i)),MAC_WIDTH));
        macs_adderTree_r(i*MAC_WIDTH+   MAC_WIDTH-1 downto i*MAC_WIDTH) <= mac_r(i);        
    end generate;

    process(i_clk,i_rst_n)
    begin
        if (i_rst_n = '0') then
            mac_r_pre <= (others => (others => '0'));
            product_r <= (others=>(others=>'0'));
        elsif rising_edge(i_clk) then
            for j in 0 to NUMBER_OF_PARALLEL_MACS-1 loop
                if r_newData_delayed = '1' then
                    mac_r_pre(j) <= (others => '0');
                else
                    mac_r_pre(j) <= mac_r(j);
                end if;
                
                product_r(j) <= std_logic_vector(resize(signed(coefficient_r(j))* signed(din_r(j)),MAC_WIDTH));
            end loop;
        end if;
    end process;

    adder_tree_i: component adder_tree_nonrecursive
        generic map(
            INPUT_DATA_WIDTH    => MAC_WIDTH,
            NUMBER_OF_SUMMANDS  => NUMBER_OF_PARALLEL_MACS
        )
        port map(
            i_clk    => i_clk,
            i_rst_n   => i_rst_n,
            i_enable => r_newData_delayed,
            i_data   => macs_adderTree_r,
            o_sum    => r_dout
        );
        
    o_valid <= r_newData_delayed;
    o_data  <= r_dout;
--    z_o_data: component zLine -- to adjust the output with i_newData cycles
--    generic map(
--        DELAY_CYCLES => TDM_RATE-(LATENCY_PIPELINE mod TDM_RATE),
--        DATA_WIDTH   => r_dout'length   -- Arbitrary data width
--    )
--    port map(
--        i_clk  => i_clk,
--        i_rst_n  => i_rst_n,
--        i_enable => '1',
--        i_data => r_dout,
--        o_data => o_data
--    );        

end Behavioral;
