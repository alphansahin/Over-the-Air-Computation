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
        o_read_data : out std_logic;
        i_coefficients : in std_logic_vector(NUMBER_OF_TAPS*COEFF_WIDTH-1 downto 0);
        i_data : in std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
        o_data : out std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+integer(ceil(log2(real(NUMBER_OF_TAPS))))-1 downto 0)
    );
end FIR_architecture1;

architecture Behavioral of FIR_architecture1 is
    constant CLOG2_NUMBER_OF_TAPS: integer := integer(ceil(log2(real(NUMBER_OF_TAPS))));
    constant CLOG2_TDM_RATE: integer :=integer(ceil(log2(real(TDM_RATE))));
    constant NUMBER_OF_PARALLEL_MACS : integer := NUMBER_OF_TAPS/TDM_RATE;
    constant MAC_WIDTH : integer := COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_TDM_RATE;
    constant OUTPUT_DATA_WIDTH : integer := COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS;

    signal tdm_counter_r : integer range 0 to TDM_RATE-1 := TDM_RATE-1;
    signal en_slow: std_logic;

    type signed_array1_t is array (natural range <>) of signed(MAC_WIDTH-1 downto 0);
    signal macs_r : signed_array1_t(0 to NUMBER_OF_PARALLEL_MACS-1);
    signal macs_r_pre : signed_array1_t(0 to NUMBER_OF_PARALLEL_MACS-1);
    signal macs_adderTree_r : std_logic_vector(NUMBER_OF_PARALLEL_MACS*MAC_WIDTH-1 downto 0);
    
    type signed_array2_t is array (natural range <>) of signed(INPUT_DATA_WIDTH-1 downto 0);
    signal delay_line_r : signed_array2_t(0 to NUMBER_OF_TAPS-1) := (others => (others => '0'));
    
    type signed_array1_2d_t is array (0 to TDM_RATE-1,0 to NUMBER_OF_PARALLEL_MACS-1) of signed(COEFF_WIDTH-1 downto 0);
    signal coefficients : signed_array1_2d_t;
    
    
    attribute use_dsp : string;
    attribute use_dsp of macs_r : signal is "YES";


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
    adder_tree_i: component adder_tree_nonrecursive
        generic map(
            INPUT_DATA_WIDTH    => MAC_WIDTH,
            NUMBER_OF_SUMMANDS  => NUMBER_OF_PARALLEL_MACS
        )
        port map(
            i_clk    => i_clk,
            i_rst_n   => i_rst_n,
            i_enable => en_slow,
            i_data   => macs_adderTree_r,
            o_sum    => o_data
        );
    -- Ordering filter coefficients
    process(i_coefficients)
    begin
        for i in 0 to TDM_RATE-1 loop
            for j in 0 to NUMBER_OF_PARALLEL_MACS-1 loop
                coefficients(i, j) <= signed(i_coefficients( (j*TDM_RATE + i)*COEFF_WIDTH +  COEFF_WIDTH-1 downto (j*TDM_RATE + i)*COEFF_WIDTH)); -- Initialize all elements to '00'
            end loop;
        end loop;
    end process;

    o_read_data <= en_slow;
    en_slow <= '1' when tdm_counter_r = TDM_RATE-1 else '0';


    process(i_clk,i_rst_n)
    begin
        if (i_rst_n = '0') then
            -- TDM scheduler
            tdm_counter_r <= TDM_RATE-1;

            -- Main delay line
            delay_line_r <= (others=>(others=>'0'));

        elsif rising_edge(i_clk) then
            -- TDM scheduler
            if tdm_counter_r = TDM_RATE-1 then
                tdm_counter_r <= 0;
            else
                tdm_counter_r <= tdm_counter_r+1;
            end if;

            -- Main delay line
            if tdm_counter_r = TDM_RATE-1 then
                for i in 0 to NUMBER_OF_TAPS-1 loop
                    if i = 0 then
                        delay_line_r(i) <= signed(i_data);
                    else
                        delay_line_r(i) <= delay_line_r(i-1);
                    end if;
                end loop;
            end if;
        end if;
    end process;


    GEN_MACS: for j in 0 to NUMBER_OF_PARALLEL_MACS-1 generate
        macs_r(j) <= resize(coefficients(tdm_counter_r, j)*delay_line_r(j*TDM_RATE + tdm_counter_r) + macs_r_pre(j),MAC_WIDTH);
        macs_adderTree_r(j*MAC_WIDTH+   MAC_WIDTH-1 downto j*MAC_WIDTH) <= std_logic_vector(macs_r(j));
    end generate GEN_MACS;

    process(i_clk,i_rst_n)
    begin
        if (i_rst_n = '0') then
            -- Products stored
            macs_r_pre <= (others => (others => '0'));
        elsif rising_edge(i_clk) then
            for j in 0 to NUMBER_OF_PARALLEL_MACS-1 loop
                if tdm_counter_r = TDM_RATE-1 then
                    macs_r_pre(j) <= (others => '0');
                else
                    macs_r_pre(j) <= macs_r(j);
                end if;
            end loop;
        end if;
    end process;

end Behavioral;
