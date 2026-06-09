-- Entity Declaration
library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;


entity myFIR is
    generic (
        FIR_ARCHITECTURE    : integer := 1;
        TDM_RATE            : integer := 8;
        INPUT_DATA_WIDTH    : integer := 12;
        COEFF_WIDTH         : integer := 8;
        NUMBER_OF_TAPS      : integer := 64;
        CLOG2_NUMBER_OF_TAPS : integer := 6
    );
    port (
        i_clk : in  std_logic;
        i_rst_n : in  std_logic;
        o_read_data : out std_logic;
        i_coefficients : in std_logic_vector(NUMBER_OF_TAPS*COEFF_WIDTH-1 downto 0);
        i_data : in std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
        o_data: out std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS-1 downto 0)
    );
end myFIR;

architecture Behavioral of myFIR is
    component FIR_architecture1
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
            o_data: out std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+integer(ceil(log2(real(NUMBER_OF_TAPS))))-1 downto 0)
        );
    end component FIR_architecture1;
begin
    FIR_arch1:if FIR_ARCHITECTURE = 1 generate
        inst : component FIR_architecture1
            generic map(
                TDM_RATE            => TDM_RATE         ,
                INPUT_DATA_WIDTH    => INPUT_DATA_WIDTH ,
                COEFF_WIDTH         => COEFF_WIDTH      ,
                NUMBER_OF_TAPS      => NUMBER_OF_TAPS  
            )
            port map(
                i_clk               =>  i_clk         ,
                i_rst_n             =>  i_rst_n       ,
                o_read_data         =>  o_read_data   ,
                i_coefficients      =>  i_coefficients,
                i_data              =>  i_data        ,
                o_data              =>  o_data
            );
    end generate FIR_arch1;


end Behavioral;
