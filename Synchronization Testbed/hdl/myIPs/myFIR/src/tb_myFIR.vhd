library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;

entity tb_myFIR is
    generic (
        FIR_ARCHITECTURE    : integer := 1;
        TDM_RATE            : integer := 8;
        INPUT_DATA_WIDTH    : integer := 12;
        COEFF_WIDTH         : integer := 8;
        NUMBER_OF_TAPS      : integer := 64
    );
end tb_myFIR;

architecture Behavioral of tb_myFIR is
    component myFIR
        generic (
            FIR_ARCHITECTURE    : integer;
            TDM_RATE            : integer;
            INPUT_DATA_WIDTH    : integer;
            COEFF_WIDTH         : integer;
            NUMBER_OF_TAPS      : integer;
            CLOG2_NUMBER_OF_TAPS : integer
        );
        port (
            i_clk : in  std_logic;
            i_rst_n : in  std_logic;
            o_read_data : out std_logic;
            i_coefficients : in std_logic_vector(NUMBER_OF_TAPS*COEFF_WIDTH-1 downto 0);
            i_data : in std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
            o_data: out std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+integer(ceil(log2(real(NUMBER_OF_TAPS))))-1 downto 0)
        );
    end component myFIR;

    constant clk_period : time := 1ns;
    signal clk : STD_LOGIC:='1';
    signal arstn : STD_LOGIC;
    
    signal r_data : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
begin

    myFIR_i : component myFIR
        generic map(
            FIR_ARCHITECTURE    => FIR_ARCHITECTURE         ,
            TDM_RATE            => TDM_RATE         ,
            INPUT_DATA_WIDTH    => INPUT_DATA_WIDTH ,
            COEFF_WIDTH         => COEFF_WIDTH      ,
            NUMBER_OF_TAPS      => NUMBER_OF_TAPS,
            CLOG2_NUMBER_OF_TAPS => integer(ceil(log2(real(NUMBER_OF_TAPS))))
        )
        port map(
            i_clk               =>  clk            ,
            i_rst_n             =>  arstn          ,
            o_read_data         =>  open           ,
            i_coefficients      =>  X"FFFFFFFF0C0B0A090807060504030201FFFFFFFF0C0B0A090807060504030201FFFFFFFF0C0B0A090807060504030201FFFFFFFF0C0B0A090807060504030201" ,
            i_data              =>  r_data ,
            o_data              =>  open
        );

    --generate clock
    clk_generation: process
    begin
        wait for clk_period/2;
        clk <= not clk; --toggle clock when half of clk_period is over
    end process;

    process
    begin
        -- hold reset state for 100 ns.
        arstn           <= '0';
        r_data          <=  X"001";
        wait for 20 ns;
        arstn           <= '1';
        wait for 32 ns;
        r_data          <=  X"000";
        wait;
    end process;
end Behavioral;
