-- Entity Declaration
library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
Library xpm;
use xpm.vcomponents.all;

entity mySequenceEnergy is
    generic (
        TDM_RATE            : integer := 8;
        INPUT_DATA_WIDTH    : integer := 12;
        COEFF_WIDTH         : integer := 8;
        NUMBER_OF_TAPS      : integer := 64;
        CLOG2_NUMBER_OF_TAPS : integer := 6
    );
    port (
        IQ_realImag_in :  in std_logic_vector(2*INPUT_DATA_WIDTH-1 downto 0);
        FIR_realImag_in :  in std_logic_vector(2*(COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS+1)-1 downto 0);
        dout_FIRreal:  out std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS downto 0);
        dout_FIRimag:  out std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS downto 0);        
        dout_xcorrSquareUnsigned:  out std_logic_vector(2*(COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS+1)-1 downto 0);
        dout_normSquareUnsigned:  out std_logic_vector(2*INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS-1 downto 0);


        i_clk : in  std_logic;
        i_rst_n : in  std_logic
    );
end mySequenceEnergy;

architecture Behavioral of mySequenceEnergy is
    --use UNISIM.VComponents.all;

    component normSquare is
        generic(
            inputLength: integer
        );
        port (
            real_signed_i : in std_logic_vector(inputLength-1 downto 0);
            imag_signed_i : in std_logic_vector(inputLength-1 downto 0);
            real_signed_o : out std_logic_vector(inputLength-1 downto 0);
            imag_signed_o : out std_logic_vector(inputLength-1 downto 0);
            norm_unsigned_o : out std_logic_vector(2*inputLength-1 downto 0);
            enable: in std_logic;
            clk: in std_logic;
            arstn: in std_logic
        );
    end component normSquare;

    component  moving_sum is
        generic (
            N : integer;
            log2L : integer );
        port (
            -- input
            dataIn                    : in  std_logic_vector(N-1 downto 0);
            enable                    : in  std_logic;
            -- output
            dataOut                  : out std_logic_vector(N+log2L-1 downto 0);
            clk                      : in  std_logic;
            arstn                     : in  std_logic);
    end component  moving_sum;

    component delay_line is
        generic (
            DELAY_CYCLES : integer ;  -- The 'k' in z^(-k)
            DATA_WIDTH   : positive   -- Arbitrary data width
        );
        port (
            i_clk  : in  std_logic;
            i_rst_n  : in  std_logic;
            i_enable: in std_logic;
            i_data : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            o_data:  out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component delay_line;

    signal norm_unsigned_r: std_logic_vector(2*INPUT_DATA_WIDTH-1 downto 0);
    signal IQ_realImag_delayed: std_logic_vector(2*INPUT_DATA_WIDTH-1 downto 0);
    
    
begin


    delayLine_IQ: component delay_line
        generic map(
            DELAY_CYCLES => 13,
            DATA_WIDTH   => IQ_realImag_in'length   -- Arbitrary data width
        )
        port map(
            i_clk  => i_clk,
            i_rst_n  =>i_rst_n,
            i_enable => '1',
            i_data => IQ_realImag_in,
            o_data => IQ_realImag_delayed
        );

    energy_normSquare: component normSquare 
        generic map(
            inputLength => IQ_realImag_in'length/2 
        )
        port map(
            real_signed_i => IQ_realImag_delayed(INPUT_DATA_WIDTH-1 downto 0),
            imag_signed_i => IQ_realImag_delayed(2*INPUT_DATA_WIDTH-1 downto INPUT_DATA_WIDTH),
            real_signed_o => open,
            imag_signed_o => open,
            norm_unsigned_o => norm_unsigned_r,
            enable => '1',
            clk => i_clk,
            arstn => i_rst_n
        );

    energy_moving_sum: component  moving_sum
        generic map(
            N => 2*INPUT_DATA_WIDTH,
            log2L => integer(ceil(log2(real(NUMBER_OF_TAPS))))
            )
        port map (
            -- input
            dataIn => norm_unsigned_r,
            enable => '1',
            -- output
            dataOut => dout_normSquareUnsigned,
            clk => i_clk,
            arstn => i_rst_n
            );

    -- 
    FIR_normSquare: component normSquare 
        generic map(
            inputLength => FIR_realImag_in'length/2
        )
        port map(
            real_signed_i => FIR_realImag_in(FIR_realImag_in'length/2-1 downto 0),
            imag_signed_i => FIR_realImag_in(FIR_realImag_in'length-1 downto FIR_realImag_in'length/2),
            real_signed_o => open,
            imag_signed_o => open,
            norm_unsigned_o => dout_xcorrSquareUnsigned,
            enable => '1',
            clk => i_clk,
            arstn => i_rst_n
        );    
        
    
   -- 

    FIR_real_delayLine: component delay_line
        generic map(
            DELAY_CYCLES => 2,
            DATA_WIDTH   => dout_FIRreal'length   -- Arbitrary data width
        )
        port map(
            i_clk  => i_clk,
            i_rst_n  =>i_rst_n,
            i_enable => '1',
            i_data => FIR_realImag_in(FIR_realImag_in'length/2-1 downto 0),
            o_data => dout_FIRreal
        );
    

    FIR_imag_delayLine: component delay_line
        generic map(
            DELAY_CYCLES => 2,
            DATA_WIDTH   => dout_FIRimag'length   -- Arbitrary data width
        )
        port map(
            i_clk  => i_clk,
            i_rst_n  =>i_rst_n,
            i_enable => '1',
            i_data => FIR_realImag_in(FIR_realImag_in'length-1 downto FIR_realImag_in'length/2),
            o_data => dout_FIRimag
        );
    
    
end Behavioral;
