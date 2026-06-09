-- Entity Declaration
library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
Library xpm;
use xpm.vcomponents.all;

entity myFIR is
    generic (
        COEFRAM_ADDRB_WIDTH     : integer ;
        TDM_RATE                : integer ;
        INPUT_DATA_WIDTH        : integer ;
        COEFF_WIDTH             : integer ;
        NUMBER_OF_TAPS          : integer ;
        CLOG2_NUMBER_OF_TAPS    : integer
    );
    port (
        i_sequenceSel                       : in STD_LOGIC;
        i_accumulator_reset                 : in STD_LOGIC;
        
        o_FIRcoef_addr                      : out std_logic_vector(COEFRAM_ADDRB_WIDTH-1 downto 0);
        i_coefficientsParellel_real         : in std_logic_vector(COEFF_WIDTH*NUMBER_OF_TAPS/TDM_RATE-1 downto 0);
        i_coefficientsParellel_imag         : in std_logic_vector(COEFF_WIDTH*NUMBER_OF_TAPS/TDM_RATE-1 downto 0);

        i_valid                             : in std_logic;
        i_FIR_din_real                      : in std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
        i_FIR_din_imag                      : in std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);

        o_valid                             : out std_logic;
        o_FIR_dout_real                     : out std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS downto 0);
        o_FIR_dout_imag                     : out std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS downto 0);
        o_sequenceNormSquare                : out std_logic_vector(2*INPUT_DATA_WIDTH+2+CLOG2_NUMBER_OF_TAPS-1 downto 0);
        i_clk                               : in std_logic;
        i_rstn                              : in std_logic
    );
end myFIR;

architecture Behavioral of myFIR is

    constant NUMBER_OF_PARALLEL_MACS : integer := NUMBER_OF_TAPS/TDM_RATE;                                          -- e.g., 64/8 = 8
    constant DOUT_FIR_REAL_WIDTH : integer := COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS;                    -- e.g., 8 + 12 + 6 = 26 bits
    constant DOUT_FIR_COMPLEX_WIDTH : integer := DOUT_FIR_REAL_WIDTH+1;                                             -- e.g., 26 + 1 = 27 bits
    constant ADDRB_BASE_WIDTH : integer := integer(ceil(log2(real(TDM_RATE))));                                     -- e.g., 1 + log2(8) = 4 bits
    constant COEFFICIENTS_READ_PARALLEL_WIDTH : integer := NUMBER_OF_PARALLEL_MACS*COEFF_WIDTH;                     -- e.g., 8 par * 8 bits = 64 signal
    constant DATA_READ_PARALLEL_WIDTH : integer := NUMBER_OF_PARALLEL_MACS*INPUT_DATA_WIDTH;                        -- e.g., 8 par * 12 bits = 96 bits
    constant NORM_SQUARE_WIDTH : integer := 2*INPUT_DATA_WIDTH+2+CLOG2_NUMBER_OF_TAPS;                              -- e.g., 2*12+2+6 = 24+8 = 32 bits

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
            i_newData: in std_logic;
            i_coefficientsParellel : in std_logic_vector(COEFFICIENTS_READ_PARALLEL_WIDTH-1 downto 0);
            i_dataParellel : in std_logic_vector(DATA_READ_PARALLEL_WIDTH-1 downto 0);
            o_valid: out std_logic;
            o_data : out std_logic_vector(DOUT_FIR_REAL_WIDTH-1 downto 0)
        );
    end component FIR_architecture1;


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

    component myAccumulator is
        generic (
            N       : integer;
            log2L   : integer
        );
        port (
            -- input
            i_acc_dinPlus               : in  std_logic_vector(N-1 downto 0);
            i_acc_dinMinus              : in  std_logic_vector(N-1 downto 0);
            i_enable                    : in  std_logic;
            i_accumulator_reset         : in  std_logic;            
            o_acc_dout                  : out std_logic_vector(N+log2L+1 - 1  downto 0);
            i_clk                       : in  std_logic;
            i_arstn                     : in  std_logic);
    end component myAccumulator;

    component normSquare is
        generic(
            inputLength: integer
        );
        port (
            i_real_signed   : in std_logic_vector(inputLength-1 downto 0);
            i_imag_signed   : in std_logic_vector(inputLength-1 downto 0);
            o_norm          : out std_logic_vector(2*inputLength downto 0);
            i_enable        : in std_logic;
            i_clk           : in std_logic;
            i_arstn         : in std_logic
        );
    end component normSquare;

    signal r_tdm_counter : integer range 0 to TDM_RATE-1;
    signal r_holdData_counter : integer range 0 to TDM_RATE-1;
    signal r_TDM_beats: std_logic;

    signal r_FIR_din_real : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal r_FIR_din_imag : std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);

    signal r_dataParallel_real: std_logic_vector(INPUT_DATA_WIDTH*NUMBER_OF_PARALLEL_MACS-1 downto 0);
    signal r_dataParallel_imag: std_logic_vector(INPUT_DATA_WIDTH*NUMBER_OF_PARALLEL_MACS-1 downto 0);

    signal r_dout_realCoef_realData: std_logic_vector(DOUT_FIR_REAL_WIDTH-1 downto 0);
    signal r_dout_realCoef_imagData: std_logic_vector(DOUT_FIR_REAL_WIDTH-1 downto 0);
    signal r_dout_imagCoef_realData: std_logic_vector(DOUT_FIR_REAL_WIDTH-1 downto 0);
    signal r_dout_imagCoef_imagData: std_logic_vector(DOUT_FIR_REAL_WIDTH-1 downto 0);

--    signal r_valid_realCoef_realData: std_logic;
--    signal r_valid_realCoef_imagData: std_logic;
--    signal r_valid_imagCoef_realData: std_logic;
    signal r_valid_imagCoef_imagData: std_logic;
    signal r_valid: std_logic;

    signal r_counterSuppress : integer range 0 to NUMBER_OF_TAPS-1;

    signal r_FIR_dout_real: std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
    signal r_FIR_dout_imag: std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);

    attribute use_dsp : string;
    attribute use_dsp of r_FIR_dout_real : signal is "YES";
    attribute use_dsp of r_FIR_dout_imag : signal is "YES";


    type t_std_logic_vector_array2 is array (natural range <>) of std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal r_delay_line_real : t_std_logic_vector_array2(0 to NUMBER_OF_TAPS-1) := (others => (others => '0'));
    signal r_delay_line_imag : t_std_logic_vector_array2(0 to NUMBER_OF_TAPS-1) := (others => (others => '0'));
    signal r_mux_dout_real : t_std_logic_vector_array2(0 to NUMBER_OF_PARALLEL_MACS-1) := (others => (others => '0'));
    signal r_mux_dout_imag : t_std_logic_vector_array2(0 to NUMBER_OF_PARALLEL_MACS-1) := (others => (others => '0'));
    signal r_mux_dout_real_in : t_std_logic_vector_array2(0 to NUMBER_OF_PARALLEL_MACS-1) := (others => (others => '0'));
    signal r_mux_dout_imag_in : t_std_logic_vector_array2(0 to NUMBER_OF_PARALLEL_MACS-1) := (others => (others => '0'));

    signal r_sampleAbsSquarePlus: std_logic_vector(2*INPUT_DATA_WIDTH downto 0);
    signal r_sampleAbsSquareMinus: std_logic_vector(2*INPUT_DATA_WIDTH downto 0);
    signal r_dinMinus_real: std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal r_dinMinus_imag: std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);

    signal r_sequenceNormSquare:  std_logic_vector(NORM_SQUARE_WIDTH-1 downto 0);
    signal r_sequenceNormSquare_delayed:  std_logic_vector(NORM_SQUARE_WIDTH-1 downto 0);

    --    signal r_FIR_dout_real_delayed: std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
    --    signal r_FIR_dout_imag_delayed: std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);

begin
    register_input: process(i_clk,i_rstn)
    begin
        if(i_rstn = '0') then
            r_FIR_din_real   <= (others=>'0');
            r_FIR_din_imag   <= (others=>'0');
        elsif(rising_edge(i_clk)) then
            if r_holdData_counter = 0 then
                if i_valid = '1' then
                    r_FIR_din_real <= i_FIR_din_real;
                    r_FIR_din_imag <= i_FIR_din_imag;
                    r_holdData_counter <= r_holdData_counter+1;
                else
                    r_FIR_din_real  <= (others=>'0');
                    r_FIR_din_imag  <= (others=>'0');
                end if;
            else
                if r_holdData_counter = TDM_RATE-1 then
                    r_holdData_counter <= 0;
                else
                    r_holdData_counter <= r_holdData_counter+1;
                end if;
            end if;
        end if;
    end process;


    FIR_beats: process(i_clk,i_rstn)
    begin
        if(i_rstn = '0') then
            -- TDM scheduler
            r_tdm_counter <= 0;--TDM_RATE-1;
        elsif(rising_edge(i_clk)) then
            -- TDM scheduler
            if r_tdm_counter = TDM_RATE-1 then
                r_tdm_counter <= 0;
            else
                r_tdm_counter <= r_tdm_counter+1;
            end if;
        end if;
    end process;
    r_TDM_beats  <= '1' when r_tdm_counter = TDM_RATE-1 else '0';


    main_delay_line: process(i_clk,i_rstn)
    begin
        if (i_rstn = '0') then
            -- Main delay line
            r_delay_line_real <= (others=>(others=>'0'));
            r_delay_line_imag <= (others=>(others=>'0'));
            r_dinMinus_real   <= (others=>'0');
            r_dinMinus_imag   <= (others=>'0');

        elsif rising_edge(i_clk) then
            -- Main delay line
            if r_TDM_beats = '1' then
                for i in 0 to NUMBER_OF_TAPS-1 loop
                    if i = 0 then
                        r_delay_line_real(i) <= r_FIR_din_real;
                        r_delay_line_imag(i) <= r_FIR_din_imag;
                    else
                        r_delay_line_real(i) <= r_delay_line_real(i-1);
                        r_delay_line_imag(i) <= r_delay_line_imag(i-1);
                    end if;
                end loop;
                r_dinMinus_real   <= r_delay_line_real(NUMBER_OF_TAPS-1);
                r_dinMinus_imag   <= r_delay_line_imag(NUMBER_OF_TAPS-1);
            end if;
        end if;
    end process;
    z_real_imag_dataMux: for j in 0 to NUMBER_OF_PARALLEL_MACS-1 generate
        r_mux_dout_real_in(j) <= r_delay_line_real(j*TDM_RATE + r_tdm_counter);
        r_mux_dout_imag_in(j) <= r_delay_line_imag(j*TDM_RATE + r_tdm_counter);

        z_inst_real: component zLine
            generic map(
                DELAY_CYCLES => 2,
                DATA_WIDTH   => INPUT_DATA_WIDTH   -- Arbitrary data width
            )
            port map(
                i_clk   => i_clk,
                i_rst_n => i_rstn,
                i_enable=> '1',
                i_data  => r_mux_dout_real_in(j),
                o_data  => r_mux_dout_real(j)
            );

        r_dataParallel_real(j*INPUT_DATA_WIDTH+INPUT_DATA_WIDTH-1 downto j*INPUT_DATA_WIDTH) <= r_mux_dout_real(j);

        z_inst_imag: component zLine
            generic map(
                DELAY_CYCLES => 2,
                DATA_WIDTH   => INPUT_DATA_WIDTH   -- Arbitrary data width
            )
            port map(
                i_clk   => i_clk,
                i_rst_n => i_rstn,
                i_enable=> '1',
                i_data  => r_mux_dout_imag_in(j),
                o_data  => r_mux_dout_imag(j)
            );

        r_dataParallel_imag(j*INPUT_DATA_WIDTH+INPUT_DATA_WIDTH-1 downto j*INPUT_DATA_WIDTH) <= r_mux_dout_imag(j);
    end generate z_real_imag_dataMux;


    o_FIRcoef_addr <= i_sequenceSel & std_logic_vector(to_unsigned(r_tdm_counter,ADDRB_BASE_WIDTH));

    FIR_realCoef_realData: component FIR_architecture1
        generic map(
            TDM_RATE            => TDM_RATE         ,
            INPUT_DATA_WIDTH    => INPUT_DATA_WIDTH ,
            COEFF_WIDTH         => COEFF_WIDTH      ,
            NUMBER_OF_TAPS      => NUMBER_OF_TAPS
        )
        port map(
            i_clk                       =>  i_clk         ,
            i_rst_n                     =>  i_rstn       ,
            i_newData                   =>  r_TDM_beats ,
            i_coefficientsParellel      =>  i_coefficientsParellel_real,
            i_dataParellel              =>  r_dataParallel_real        ,
            o_valid                     =>  open,
            o_data                      =>  r_dout_realCoef_realData
        );

    FIR_realCoef_imagData: component FIR_architecture1
        generic map(
            TDM_RATE            => TDM_RATE         ,
            INPUT_DATA_WIDTH    => INPUT_DATA_WIDTH ,
            COEFF_WIDTH         => COEFF_WIDTH      ,
            NUMBER_OF_TAPS      => NUMBER_OF_TAPS
        )
        port map(
            i_clk                       =>  i_clk         ,
            i_rst_n                     =>  i_rstn       ,
            i_newData                   =>  r_TDM_beats ,
            i_coefficientsParellel      =>  i_coefficientsParellel_real,
            i_dataParellel              =>  r_dataParallel_imag        ,
            o_valid                     =>  open,
            o_data                      =>  r_dout_realCoef_imagData
        );

    FIR_imagCoef_realData: component FIR_architecture1
        generic map(
            TDM_RATE            => TDM_RATE         ,
            INPUT_DATA_WIDTH    => INPUT_DATA_WIDTH ,
            COEFF_WIDTH         => COEFF_WIDTH      ,
            NUMBER_OF_TAPS      => NUMBER_OF_TAPS
        )
        port map(
            i_clk                       =>  i_clk         ,
            i_rst_n                     =>  i_rstn       ,
            i_newData                   =>  r_TDM_beats ,
            i_coefficientsParellel      =>  i_coefficientsParellel_imag,
            i_dataParellel              =>  r_dataParallel_real        ,
            o_valid                     =>  open,
            o_data                      =>  r_dout_imagCoef_realData
        );


    FIR_imagCoef_imagData: component FIR_architecture1
        generic map(
            TDM_RATE            => TDM_RATE         ,
            INPUT_DATA_WIDTH    => INPUT_DATA_WIDTH ,
            COEFF_WIDTH         => COEFF_WIDTH      ,
            NUMBER_OF_TAPS      => NUMBER_OF_TAPS
        )
        port map(
            i_clk                       =>  i_clk         ,
            i_rst_n                     =>  i_rstn       ,
            i_newData                   =>  r_TDM_beats ,
            i_coefficientsParellel      =>  i_coefficientsParellel_imag,
            i_dataParellel              =>  r_dataParallel_imag        ,
            o_valid                     =>  r_valid_imagCoef_imagData,
            o_data                      =>  r_dout_imagCoef_imagData
        );


    FIR_logic: process(i_clk,i_rstn)
    begin
        if(i_rstn = '0') then
            r_FIR_dout_real   <= (others=>'0');
            r_FIR_dout_imag   <= (others=>'0');
            r_valid <= '0';
        elsif(rising_edge(i_clk)) then
            if r_valid_imagCoef_imagData = '1' then
                r_FIR_dout_real <= std_logic_vector(resize(signed(r_dout_realCoef_realData),DOUT_FIR_COMPLEX_WIDTH) - resize(signed(r_dout_imagCoef_imagData),DOUT_FIR_COMPLEX_WIDTH));
                r_FIR_dout_imag <= std_logic_vector(resize(signed(r_dout_realCoef_imagData),DOUT_FIR_COMPLEX_WIDTH) + resize(signed(r_dout_imagCoef_realData),DOUT_FIR_COMPLEX_WIDTH));
                r_valid <= '1';
            else
                r_valid <= '0';
            end if;
        end if;
    end process;


    -- Norm square calculation
    sampleAbsSquarePlus: component normSquare
        generic map(
            inputLength => INPUT_DATA_WIDTH
        )
        port map(
            i_real_signed     => r_delay_line_real(0),
            i_imag_signed     => r_delay_line_imag(0),
            o_norm            => r_sampleAbsSquarePlus,
            i_enable          => r_TDM_beats,
            i_clk             => i_clk,
            i_arstn           => i_rstn
        );

    sampleAbsSquareMinus: component normSquare
        generic map(
            inputLength => INPUT_DATA_WIDTH
        )
        port map(
            i_real_signed     => r_dinMinus_real,
            i_imag_signed     => r_dinMinus_imag,
            o_norm            => r_sampleAbsSquareMinus,
            i_enable          => r_TDM_beats,
            i_clk             => i_clk,
            i_arstn           => i_rstn
        );

    accumulator_normSequence: component myAccumulator
        generic map(
            N                   => 2*INPUT_DATA_WIDTH+1,
            log2L               => CLOG2_NUMBER_OF_TAPS
        )
        port map(
            -- input
            i_acc_dinPlus       => r_sampleAbsSquarePlus,
            i_acc_dinMinus      => r_sampleAbsSquareMinus,
            i_enable            => r_TDM_beats,
            i_accumulator_reset => i_accumulator_reset,
            o_acc_dout          => r_sequenceNormSquare,
            i_clk               => i_clk,
            i_arstn             => i_rstn
        );


    z_sequenceNorm: component zLine
        generic map(
            DELAY_CYCLES => 2, -- needs to be calculated....
            DATA_WIDTH   => r_sequenceNormSquare'length   -- Arbitrary data width
        )
        port map(
            i_clk  => i_clk,
            i_rst_n  => i_rstn,
            i_enable => r_valid_imagCoef_imagData,
            i_data => r_sequenceNormSquare,
            o_data => r_sequenceNormSquare_delayed
        );

    o_sequenceNormSquare    <= r_sequenceNormSquare_delayed;
    o_FIR_dout_real         <= r_FIR_dout_real;
    o_FIR_dout_imag         <= r_FIR_dout_imag;
    o_valid                 <= r_valid;
end Behavioral;
