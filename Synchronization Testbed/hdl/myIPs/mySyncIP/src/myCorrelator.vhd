-- Entity Declaration
library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
Library xpm;
use xpm.vcomponents.all;

entity myCorrelator is
    generic (
        NUM_STATUS_REGS             : integer := 11;
        TDM_RATE                    : integer := 8;
        INPUT_DATA_WIDTH            : integer := 12;
        COEFF_WIDTH                 : integer := 8;
        NUMBER_OF_TAPS              : integer := 64;
        CLOG2_NUMBER_OF_TAPSi       : integer := 6
    );
    port (
        -- slow domain
        i_FIRcoef_wr            : in std_logic;
        i_FIRcoef_addr          : in std_logic_vector(31 DOWNTO 0);
        i_FIRcoef_realValues_wr : in std_logic_vector(31 DOWNTO 0);
        i_FIRcoef_imagValues_wr : in std_logic_vector(31 DOWNTO 0);
        i_FIRcoef_realValues_rd : out std_logic_vector(31 DOWNTO 0);
        i_FIRcoef_imagValues_rd : out std_logic_vector(31 DOWNTO 0);
        i_sequenceSel           : in std_logic;


        i_IQdata                : in std_logic_vector(2*INPUT_DATA_WIDTH-1 downto 0);
        i_IQdata_wr             : in std_logic;

        i_clk                   : in std_logic;
        i_rstn                  : in std_logic;

        -- fast domain
        o_status_myDetector     : out std_logic_vector (NUM_STATUS_REGS*32-1 downto 0);

        o_FIRdata_real_detected : out std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPSi downto 0);
        o_FIRdata_imag_detected : out std_logic_vector(COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPSi downto 0);
        o_detected              : out std_logic;

        i_clk_fast              : in std_logic;
        i_rstn_fast             : in std_logic
    );
end myCorrelator;

architecture Behavioral of myCorrelator is
    constant CLOG2_NUMBER_OF_TAPS: integer := integer(ceil(log2(real(NUMBER_OF_TAPS))));                             -- e.g., log2(64) = 6
    constant NUMBER_OF_PARALLEL_MACS : integer := NUMBER_OF_TAPS/TDM_RATE;                                           -- e.g., 64/8 = 8
    constant NUMBER_OF_COEF_SETS : integer := 2;                                                                     -- e.g., 2
    constant CLOG2_NUMBER_OF_COEF_SETS : integer :=  integer(ceil(log2(real(NUMBER_OF_COEF_SETS))));                 -- e.g., log2(2) = 1
    constant NUMBER_OF_BITS_PERCOEF_SETS : integer := NUMBER_OF_TAPS*COEFF_WIDTH;                                    -- e.g., 64*8 = 512 bits
    constant NUMBER_OF_BITS_ALLCOEF_SETS : integer := NUMBER_OF_BITS_PERCOEF_SETS*NUMBER_OF_COEF_SETS;               -- e.g., 512*2 = 1024 bits
    constant ADDRA_BASE_WIDTH : integer := CLOG2_NUMBER_OF_TAPS;                                                     -- e.g., log2(64) = 6 bits
    constant ADDRA_WIDTH : integer := integer(CLOG2_NUMBER_OF_COEF_SETS + ADDRA_BASE_WIDTH);                         -- e.g., 1 + 6 = 7 bits
    constant COEFFICIENTS_READ_PARALLEL_WIDTH : integer := NUMBER_OF_PARALLEL_MACS*COEFF_WIDTH;                      -- e.g., 8 par * 8 bits = 64 bits
    constant ADDRB_BASE_WIDTH : integer := integer(ceil(log2(real(TDM_RATE))));                                      -- e.g., 1 + log2(8) = 4 bits
    constant ADDRB_WIDTH : integer := integer(CLOG2_NUMBER_OF_COEF_SETS + ADDRB_BASE_WIDTH);                         -- e.g., 1 + log2(8) = 4 bits
    constant DOUT_FIR_REAL_WIDTH : integer := COEFF_WIDTH+INPUT_DATA_WIDTH+CLOG2_NUMBER_OF_TAPS;                     -- e.g., 8 + 12 + 6 = 26 bits
    constant DOUT_FIR_COMPLEX_WIDTH : integer := DOUT_FIR_REAL_WIDTH+1;                                              -- e.g., 26 + 1 = 27 signal

    constant CLOG2_NORMSQUARE_FILTER_COEFS : integer := (CLOG2_NUMBER_OF_TAPS + 2*(COEFF_WIDTH-1));                  -- e.g., chirps (6 + 2*(8-1)) = 20  
    constant LOG2_OF_1_OVER_THRESHOLD : integer := 2;                                                                -- e.g., 1/4 as threshold => log2(1 / 1/4) = 2
    constant CONSTANT_DIVISION : integer := (CLOG2_NORMSQUARE_FILTER_COEFS - LOG2_OF_1_OVER_THRESHOLD)/2;            -- e.g., (20-2)/2 = 9
    constant DOUT_FIR_COMPLEX_WIDTH_AFTER_DIVISION : integer := DOUT_FIR_COMPLEX_WIDTH - CONSTANT_DIVISION;          -- e.g., 27 - (20-2)/2 = 27-9=18
    constant XCORR_SQUARE_WIDTH_AFTER_DIVISION : integer :=2*DOUT_FIR_COMPLEX_WIDTH_AFTER_DIVISION+1;                -- e.g., 2*18+1 = 37
    constant NORM_SQUARE_WIDTH : integer := 2*INPUT_DATA_WIDTH+2+CLOG2_NUMBER_OF_TAPS;                               -- e.g., 2*12+2+6 = 32


    component myFIR is
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
    end component myFIR;

    component blk_mem_FIRcoef IS
        PORT (
            clka : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(ADDRA_WIDTH-1 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(COEFF_WIDTH-1 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(COEFF_WIDTH-1 DOWNTO 0);
            clkb : IN STD_LOGIC;
            web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addrb : IN STD_LOGIC_VECTOR(ADDRB_WIDTH-1 DOWNTO 0);
            dinb : IN STD_LOGIC_VECTOR(COEFFICIENTS_READ_PARALLEL_WIDTH-1 DOWNTO 0);
            doutb : OUT STD_LOGIC_VECTOR(COEFFICIENTS_READ_PARALLEL_WIDTH-1 DOWNTO 0)
        );
    END component blk_mem_FIRcoef;



    component fifo_generator_corr_din IS
        PORT (
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            valid : OUT STD_LOGIC;
            wr_rst_busy : OUT STD_LOGIC;
            rd_rst_busy : OUT STD_LOGIC
        );
    END component fifo_generator_corr_din;

    component fifo_generator_corr_dout IS
        PORT (
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(85 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(85 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            valid : OUT STD_LOGIC;
            wr_rst_busy : OUT STD_LOGIC;
            rd_rst_busy : OUT STD_LOGIC
        );
    END component fifo_generator_corr_dout;


    component detectorXcorr is
        Generic(
            DOUT_FIR_COMPLEX_WIDTH              : integer;
            XCORR_SQUARE_WIDTH_AFTER_DIVISION   : integer;
            NORM_SQUARE_WIDTH                   : integer;
            VAL_SUPPRESS                        : integer
        );
        Port (
            i_real_signed                   : in std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
            i_imag_signed                   : in std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
            i_xcorrSquareDivided            : in STD_LOGIC_VECTOR (XCORR_SQUARE_WIDTH_AFTER_DIVISION-1 downto 0);
            i_normSquare                    : in STD_LOGIC_VECTOR (NORM_SQUARE_WIDTH-1 downto 0);
            o_real_signed_detected          : out std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
            o_imag_signed_detected          : out std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
            o_normSquare_detected           : out std_logic_vector(NORM_SQUARE_WIDTH-1 downto 0);
            o_xcorrSquareDivided_detected   : out std_logic_vector(XCORR_SQUARE_WIDTH_AFTER_DIVISION-1 downto 0);
            i_suppressDetection             : in STD_LOGIC;
            o_detected                      : out STD_LOGIC;
            o_detected_toggle               : out STD_LOGIC;
            o_stateDetector                 : out STD_LOGIC;
            o_cntDetection                  : out std_logic_vector(15 downto 0);
            i_clk                           : in std_logic;
            i_arstn                         : in std_logic
        );
    end component;

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

    signal r_rst_fast: std_logic;

    signal r_tdm_counter_fast : integer range 0 to TDM_RATE-1;

    signal r_FIRcoef_addrb_converted: std_logic_vector(ADDRB_WIDTH-1 downto 0);
    signal r_coefficientsParellel_real: std_logic_vector(COEFF_WIDTH*NUMBER_OF_TAPS/TDM_RATE-1 downto 0);
    signal r_coefficientsParellel_imag: std_logic_vector(COEFF_WIDTH*NUMBER_OF_TAPS/TDM_RATE-1 downto 0);

    signal r_sequenceSel_fast: std_logic;
    signal r_accumulator_reset_fast: std_logic;
    signal r_state_fast: std_logic;
    signal r_FIRdata_valid_fast: std_logic;


    signal r_IQdata_fast: std_logic_vector(2*INPUT_DATA_WIDTH-1 downto 0);
    signal r_inPhase_fast: std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
    signal r_quadrature_fast: std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);

    signal r_sequenceNormSquare_fast:  std_logic_vector(NORM_SQUARE_WIDTH-1 downto 0);
    signal r_FIRdata_real_fast : std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
    signal r_FIRdata_imag_fast : std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);

    --==============================================================
    -- din fifo
    -->> slow clk
    signal r_IQdata_full: std_logic;
    -->> fast clk
    signal r_IQdata_empty_fast: std_logic;
    signal r_IQdata_valid_fast: std_logic;
    signal r_IQdata_rd_fast: std_logic;

    -- dout fifo
    -->> fast clk
    signal r_fifo_FIR_dout_empty: std_logic;
    signal r_fifo_FIR_dout_valid: std_logic;
    signal r_fifo_FIR_dout_full_fast: std_logic;
    signal r_fifo_FIR_dout_wr_fast: std_logic;
    signal r_fifo_FIR_dout_data_fast : std_logic_vector(2*(DOUT_FIR_COMPLEX_WIDTH)+NORM_SQUARE_WIDTH-1 downto 0);

    --attribute slow clk
    signal r_fifo_FIR_dout_data      : std_logic_vector(2*(DOUT_FIR_COMPLEX_WIDTH)+NORM_SQUARE_WIDTH-1 downto 0);
    signal r_fifo_FIR_dout_rd: std_logic;



    --==============================================================

    -- slow clk
    signal r_FIRcoef_wr: std_logic_vector(0 downto 0);

    signal r_FIRcoef_realValues_wr: std_logic_vector(COEFF_WIDTH-1 downto 0);
    signal r_FIRcoef_imagValues_wr: std_logic_vector(COEFF_WIDTH-1 downto 0);
    signal r_FIRcoef_realValues_rd: std_logic_vector(COEFF_WIDTH-1 downto 0);
    signal r_FIRcoef_imagValues_rd: std_logic_vector(COEFF_WIDTH-1 downto 0);
    signal r_FIRcoef_addra_converted: std_logic_vector(ADDRA_WIDTH-1 downto 0);
    type t_rom is array (0 to NUMBER_OF_TAPS-1) of std_logic_vector(ADDRA_BASE_WIDTH-1 downto 0) ;                                          -- This does the following remapping:
    function initROM return t_rom is                                                                                                        -- clear all
        variable ROM : t_rom;                                                                                                               -- close all
    begin                                                                                                                                   -- clc
        for r in 0 to TDM_RATE-1 loop                                                                                                       -- Nparallel =3;
            for k in 0 to NUMBER_OF_PARALLEL_MACS-1 loop                                                                                    -- Ntdm=4;
                ROM(k*TDM_RATE + r) := std_logic_vector(to_unsigned(r*NUMBER_OF_PARALLEL_MACS + k, ADDRA_BASE_WIDTH));
            end loop;                                                                                                                       -- n = [0:Ntdm*Nparallel-1]; % n = k*Ntdm+r
        end loop;                                                                                                                           -- r = mod(n,Ntdm);
        return ROM;                                                                                                                         -- k = (n-r)/Ntdm;
    end function;                                                                                                                           -- m = r*Nparallel+k;
    signal  reOrderedAddr : t_rom := initROM;                                                                                               -- disp([n;m])
    attribute rom_style : string;                                                                                                           --      0     1     2     3     4     5     6     7     8     9    10    11
    attribute rom_style of reOrderedAddr : signal is "distributed";                                                                         --      0     3     6     9     1     4     7    10     2     5     8    11


    signal r_sequenceSel_pre: std_logic;
    signal r_suppressDetection: std_logic;

    signal r_xcorrSquare_divided: std_logic_vector(XCORR_SQUARE_WIDTH_AFTER_DIVISION-1 downto 0);
    signal r_xcorrSquare_divided_delayed: std_logic_vector(XCORR_SQUARE_WIDTH_AFTER_DIVISION-1 downto 0);

    signal r_FIRdata_real : std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
    signal r_FIRdata_imag : std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
    signal r_FIRdata_real_delayed : std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
    signal r_FIRdata_imag_delayed : std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
    signal r_FIRdata_real_divided : std_logic_vector(DOUT_FIR_COMPLEX_WIDTH_AFTER_DIVISION-1 downto 0);
    signal r_FIRdata_imag_divided : std_logic_vector(DOUT_FIR_COMPLEX_WIDTH_AFTER_DIVISION-1 downto 0);

    signal r_FIRdata_real_detected : std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
    signal r_FIRdata_imag_detected : std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);

    signal r_sequenceNormSquare:  std_logic_vector(NORM_SQUARE_WIDTH-1 downto 0);
    signal r_sequenceNormSquare_delayed:  std_logic_vector(NORM_SQUARE_WIDTH-1 downto 0);

    constant VAL_SUPPRESS: integer := 16;
    signal r_counterSuppress : integer range 0 to VAL_SUPPRESS-1;

    signal r_counterSlow  : std_logic_vector(31 downto 0);
    signal r_counterFast  : std_logic_vector(31 downto 0);
    signal r_counterFast_slow  : std_logic_vector(31 downto 0);

    signal r_normSquare_detected : std_logic_vector(NORM_SQUARE_WIDTH-1 downto 0);
    signal r_xcorrSquareDivided_detected: std_logic_vector(XCORR_SQUARE_WIDTH_AFTER_DIVISION-1 downto 0);
    signal r_stateDetector: std_logic;
    signal r_cntDetection : std_logic_vector(15 downto 0 );

    constant ZERO : std_logic_vector(31 downto 0) := (others => '0');
    type std_logic_vector_array_t is array (natural range <>) of std_logic_vector(31 downto 0);
    signal r_status_myDetector : std_logic_vector_array_t(0 to NUM_STATUS_REGS-1);

begin
    -- Component Instantiations 
    -- src: clk, des: clk_fast -- FIR coefs are with clk_fast, that's why I use CDC
    cdc_sequenceSel: xpm_cdc_single
        generic map (
            DEST_SYNC_FF => 2,   -- DECIMAL; range: 2-10
            INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
            SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
            SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input
        )
        port map (
            dest_out => r_sequenceSel_fast,   -- 1-bit output: src_in synchronized to the destination clock domain. This output is registered.
            dest_clk => i_clk_fast,           -- 1-bit input: Clock signal for the destination clock domain.
            src_clk => i_clk,                 -- 1-bit input: optional; required when SRC_INPUT_REG = 1
            src_in => i_sequenceSel         -- 1-bit input: Input signal to be synchronized to dest_clk domain.
        );


    -- Example: For port A, the MSB of i_FIRcoef_addr selects the upper portion of the memory for second set of the FIR coefficients.
    --          A set: 64 taps each has an 8 bit representation = 512 bits in total, i.e., 32 bits x 16. 
    --          This set requires an address with 4 bits
    --          Hence, the memory address width is 4+1 = 5 bits, where the MSB of i_FIRcoef_addr selects the second set.           
    r_FIRcoef_addra_converted <= i_FIRcoef_addr(ADDRA_WIDTH-1 downto ADDRA_BASE_WIDTH) & reOrderedAddr(to_integer(unsigned(i_FIRcoef_addr(ADDRA_BASE_WIDTH-1 downto 0))));
    r_FIRcoef_realValues_wr <= i_FIRcoef_realValues_wr(COEFF_WIDTH-1 downto 0);
    r_FIRcoef_imagValues_wr <= i_FIRcoef_imagValues_wr(COEFF_WIDTH-1 downto 0);
    i_FIRcoef_realValues_rd(COEFF_WIDTH-1 downto 0) <= r_FIRcoef_realValues_rd;
    i_FIRcoef_realValues_rd(i_FIRcoef_realValues_rd'length-1 downto COEFF_WIDTH) <= (others => '0');
    i_FIRcoef_imagValues_rd(COEFF_WIDTH-1 downto 0) <= r_FIRcoef_imagValues_rd;
    i_FIRcoef_imagValues_rd(i_FIRcoef_imagValues_rd'length-1 downto COEFF_WIDTH) <= (others => '0');

    r_FIRcoef_wr(0) <= i_FIRcoef_wr;
    blk_mem_FIRcoef_real: component blk_mem_FIRcoef
        port map(
            clka    => i_clk,
            wea     => r_FIRcoef_wr,
            addra   => r_FIRcoef_addra_converted,
            dina    => r_FIRcoef_realValues_wr,
            douta   => r_FIRcoef_realValues_rd,

            clkb    => i_clk_fast,
            web     => "0",
            addrb   => r_FIRcoef_addrb_converted,
            dinb    => (others => '0'),
            doutb   => r_coefficientsParellel_real
        );

    blk_mem_FIRcoef_imag: component blk_mem_FIRcoef
        port map(
            clka    => i_clk,
            wea     => r_FIRcoef_wr,
            addra   => r_FIRcoef_addra_converted,
            dina    => r_FIRcoef_imagValues_wr,
            douta   => r_FIRcoef_imagValues_rd,

            clkb    => i_clk_fast,
            web     => "0",
            addrb   => r_FIRcoef_addrb_converted,
            dinb    => (others => '0'),
            doutb   => r_coefficientsParellel_imag
        );

    ------------------------------- FAST DOMAIN starts -------------------------
    r_rst_fast <= not i_rstn_fast;
    fifo_FIR_din: component fifo_generator_corr_din
        PORT map (
            rst     => r_rst_fast,
            wr_clk  => i_clk,
            rd_clk  => i_clk_fast,
            din     => i_IQdata,
            wr_en   => i_IQdata_wr,
            rd_en   => r_IQdata_rd_fast,
            dout    => r_IQdata_fast,
            full    => r_IQdata_full,
            valid   => r_IQdata_valid_fast,
            empty   => r_IQdata_empty_fast,
            wr_rst_busy => open,
            rd_rst_busy => open
        );


    process(i_clk_fast, i_rstn_fast)
    begin
        if(i_rstn_fast = '0') then
            r_tdm_counter_fast      <= 0;--TDM_RATE-1;
            r_IQdata_rd_fast <= '0';
            r_accumulator_reset_fast <= '0';
            r_state_fast <= '0';
        elsif(rising_edge(i_clk_fast)) then
            if r_state_fast = '0' then
                r_accumulator_reset_fast <= '1';
                r_state_fast <= '1';
            else
                r_accumulator_reset_fast <= '0';
                if r_tdm_counter_fast = 0 then
                    if r_IQdata_empty_fast = '0' then
                        r_IQdata_rd_fast <= '1';
                        r_tdm_counter_fast <= r_tdm_counter_fast+1;
                    end if;
                else
                    r_IQdata_rd_fast <= '0';
                    if r_tdm_counter_fast = TDM_RATE-1 then
                        r_tdm_counter_fast <= 0;
                    else
                        r_tdm_counter_fast <= r_tdm_counter_fast+1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    r_inPhase_fast          <= r_IQdata_fast(INPUT_DATA_WIDTH-1 downto 0);
    r_quadrature_fast       <= r_IQdata_fast(2*INPUT_DATA_WIDTH-1 downto INPUT_DATA_WIDTH);

    myFIR_inst: component myFIR
        generic map(
            COEFRAM_ADDRB_WIDTH             => ADDRB_WIDTH                     ,
            TDM_RATE                        => TDM_RATE                        ,
            INPUT_DATA_WIDTH                => INPUT_DATA_WIDTH                ,
            COEFF_WIDTH                     => COEFF_WIDTH                     ,
            NUMBER_OF_TAPS                  => NUMBER_OF_TAPS                  ,
            CLOG2_NUMBER_OF_TAPS            => CLOG2_NUMBER_OF_TAPS
        )
        port map(
            i_sequenceSel                   => r_sequenceSel_fast               ,
            i_accumulator_reset             => r_accumulator_reset_fast         ,
            o_FIRcoef_addr                  => r_FIRcoef_addrb_converted        ,
            i_coefficientsParellel_real     => r_coefficientsParellel_real      ,
            i_coefficientsParellel_imag     => r_coefficientsParellel_imag      ,

            i_valid                         => r_IQdata_valid_fast              ,
            i_FIR_din_real                  => r_inPhase_fast                   ,
            i_FIR_din_imag                  => r_quadrature_fast                ,

            o_valid                         => r_fifo_FIR_dout_wr_fast          ,
            o_FIR_dout_real                 => r_FIRdata_real_fast              ,
            o_FIR_dout_imag                 => r_FIRdata_imag_fast              ,
            o_sequenceNormSquare            => r_sequenceNormSquare_fast        ,

            i_clk                           => i_clk_fast                       ,
            i_rstn                          => i_rstn_fast
        );


    r_fifo_FIR_dout_data_fast <= r_sequenceNormSquare_fast & r_FIRdata_imag_fast & r_FIRdata_real_fast;
    fifo_FIR_dout: component fifo_generator_corr_dout
        PORT map (
            rst     => r_rst_fast,
            wr_clk  => i_clk_fast,
            rd_clk  => i_clk,
            din     => r_fifo_FIR_dout_data_fast,
            wr_en   => r_fifo_FIR_dout_wr_fast,
            rd_en   => r_fifo_FIR_dout_rd,
            dout    => r_fifo_FIR_dout_data,
            full    => r_fifo_FIR_dout_full_fast,
            valid   => r_fifo_FIR_dout_valid,
            empty   => r_fifo_FIR_dout_empty,
            wr_rst_busy => open,
            rd_rst_busy => open
        );
    process(i_clk, i_rstn)
    begin
        if(i_rstn = '0') then
            r_fifo_FIR_dout_rd      <= '0';
            r_sequenceNormSquare    <= (others => '0');
            r_FIRdata_imag          <= (others => '0');
            r_FIRdata_real          <= (others => '0');
        elsif(rising_edge(i_clk)) then
            if r_fifo_FIR_dout_empty = '0' then
                r_fifo_FIR_dout_rd <= '1';
            else
                r_fifo_FIR_dout_rd <= '0';
            end if;

            if r_fifo_FIR_dout_valid = '1' then
                r_sequenceNormSquare    <= r_fifo_FIR_dout_data(2*(DOUT_FIR_COMPLEX_WIDTH)+NORM_SQUARE_WIDTH-1 downto 2*(DOUT_FIR_COMPLEX_WIDTH));
                r_FIRdata_imag          <= r_fifo_FIR_dout_data(2*DOUT_FIR_COMPLEX_WIDTH-1 downto DOUT_FIR_COMPLEX_WIDTH);
                r_FIRdata_real          <= r_fifo_FIR_dout_data(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
            else
                r_sequenceNormSquare    <= (others => '0');
                r_FIRdata_imag          <= (others => '0');
                r_FIRdata_real          <= (others => '0');
            end if;
        end if;
    end process;
    ------------------------------- FAST DOMAIN ends -------------------------



    r_FIRdata_imag_divided <= r_FIRdata_imag(DOUT_FIR_COMPLEX_WIDTH-1 downto CONSTANT_DIVISION);
    r_FIRdata_real_divided <= r_FIRdata_real(DOUT_FIR_COMPLEX_WIDTH-1 downto CONSTANT_DIVISION);

    xcorrSquareDivided_calculation: component normSquare
        generic map(
            inputLength => DOUT_FIR_COMPLEX_WIDTH_AFTER_DIVISION
        )
        port map(
            i_real_signed       => r_FIRdata_imag_divided,
            i_imag_signed       => r_FIRdata_real_divided,
            o_norm              => r_xcorrSquare_divided,
            i_enable            => '1',
            i_clk               => i_clk,
            i_arstn             => i_rstn
        );

    z_xcorrSquareDivided: component zLine -- normSquare
        generic map(
            DELAY_CYCLES => 0,
            DATA_WIDTH   => r_xcorrSquare_divided'length   -- Arbitrary data width
        )
        port map(
            i_clk  => i_clk,
            i_rst_n  => i_rstn,
            i_enable => '1',
            i_data => r_xcorrSquare_divided,
            o_data => r_xcorrSquare_divided_delayed
        );

    z_sequenceNorm: component zLine -- normSquare
        generic map(
            DELAY_CYCLES => 2,
            DATA_WIDTH   => r_sequenceNormSquare'length   -- Arbitrary data width
        )
        port map(
            i_clk  => i_clk,
            i_rst_n  => i_rstn,
            i_enable => '1',
            i_data => r_sequenceNormSquare,
            o_data => r_sequenceNormSquare_delayed
        );

    z_FIR_real: component zLine
        generic map(
            DELAY_CYCLES => 2,
            DATA_WIDTH   => DOUT_FIR_COMPLEX_WIDTH   -- Arbitrary data width
        )
        port map(
            i_clk       => i_clk,
            i_rst_n     => i_rstn,
            i_enable    => '1',
            i_data      => r_FIRdata_real,
            o_data      => r_FIRdata_real_delayed
        );

    z_FIR_imag: component zLine
        generic map(
            DELAY_CYCLES => 2,
            DATA_WIDTH   => DOUT_FIR_COMPLEX_WIDTH   -- Arbitrary data width
        )
        port map(
            i_clk       => i_clk,
            i_rst_n     => i_rstn,
            i_enable    => '1',
            i_data      => r_FIRdata_imag,
            o_data      => r_FIRdata_imag_delayed
        );

    detectorXcorr_inst: component detectorXcorr
        Generic map(
            DOUT_FIR_COMPLEX_WIDTH              => DOUT_FIR_COMPLEX_WIDTH,
            XCORR_SQUARE_WIDTH_AFTER_DIVISION   => XCORR_SQUARE_WIDTH_AFTER_DIVISION,
            NORM_SQUARE_WIDTH                   => NORM_SQUARE_WIDTH,
            VAL_SUPPRESS                        => 8
        )
        Port map(
            i_real_signed                       => r_FIRdata_real_delayed,
            i_imag_signed                       => r_FIRdata_imag_delayed,
            i_xcorrSquareDivided                => r_xcorrSquare_divided_delayed,
            i_normSquare                        => r_sequenceNormSquare_delayed,
            o_real_signed_detected              => r_FIRdata_real_detected,
            o_imag_signed_detected              => r_FIRdata_imag_detected,
            o_normSquare_detected               => r_normSquare_detected,
            o_xcorrSquareDivided_detected       => r_xcorrSquareDivided_detected,
            i_suppressDetection                 => r_suppressDetection,
            o_detected                          => o_detected,
            o_detected_toggle                   => open,
            o_stateDetector                     => r_stateDetector,
            o_cntDetection                      => r_cntDetection,
            i_clk                               => i_clk,
            i_arstn                             => i_rstn
        );


    process(i_clk, i_rstn)
    begin
        if(i_rstn = '0') then
            r_counterSuppress <= 0;
            r_suppressDetection <= '0';
            r_sequenceSel_pre <= '0';
        elsif(rising_edge(i_clk)) then
            r_sequenceSel_pre <= i_sequenceSel;
            if r_suppressDetection = '0' then
                if (r_sequenceSel_pre xor i_sequenceSel) = '1' then
                    r_suppressDetection  <= '1'; -- suppress the detection
                end if;
            else
                if r_counterSuppress = VAL_SUPPRESS-1 then
                    r_suppressDetection<= '0'; -- go back to the normal operation
                    r_counterSuppress   <= 0;
                else
                    r_counterSuppress <= r_counterSuppress + 1;
                end if;
            end if;
        end if;
    end process;

    o_FIRdata_real_detected <= r_FIRdata_real_detected;
    o_FIRdata_imag_detected <= r_FIRdata_imag_detected;

    gen_status: for i in 0 to NUM_STATUS_REGS-1 generate
        o_status_myDetector(i*32 +  31 downto i*32) <= r_status_myDetector(i);
    end generate gen_status ;

    r_status_myDetector(0) <=  ZERO(31 downto r_FIRdata_real_delayed'length) & r_FIRdata_real_delayed;
    r_status_myDetector(1) <=  ZERO(31 downto r_FIRdata_imag_delayed'length) & r_FIRdata_imag_delayed;
    r_status_myDetector(2) <=  ZERO(31 downto r_FIRdata_real_detected'length) & r_FIRdata_real_detected;
    r_status_myDetector(3) <=  ZERO(31 downto r_FIRdata_imag_detected'length) & r_FIRdata_imag_detected;
    r_status_myDetector(4) <=  ZERO(31 downto r_normSquare_detected'length) & r_normSquare_detected;
    r_status_myDetector(5) <=  r_xcorrSquareDivided_detected(31 downto 0);
    r_status_myDetector(6) <=  ZERO(31 downto r_xcorrSquareDivided_detected'length-32)  & r_xcorrSquareDivided_detected(r_xcorrSquareDivided_detected'length-1 downto 32);
    r_status_myDetector(7) <=  ZERO(31 downto r_cntDetection'length+1) & r_stateDetector & std_logic_vector(r_cntDetection);
    r_status_myDetector(8) <=  r_counterSlow;
    r_status_myDetector(9) <=  r_counterFast_slow;
    r_status_myDetector(10) <= ZERO(31 downto r_normSquare_detected'length) & r_sequenceNormSquare_delayed;

    -- Sanity checks:
    process(i_clk, i_rstn)
    begin
        if(i_rstn = '0') then
            r_counterSlow <= (others => '0');
        elsif(rising_edge(i_clk)) then
            r_counterSlow <= std_logic_vector(unsigned(r_counterSlow) + 1);
        end if;
    end process;

    process(i_clk_fast, i_rstn_fast)
    begin
        if(i_rstn_fast = '0') then
            r_counterFast <= (others => '0');
        elsif(rising_edge(i_clk_fast)) then
            r_counterFast <=  std_logic_vector(unsigned(r_counterFast) + 1);
        end if;
    end process;

    cdc_counter: xpm_cdc_array_single
        generic map (
            DEST_SYNC_FF => 2,              -- DECIMAL; range: 2-10
            INIT_SYNC_FF => 0,                        -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
            SIM_ASSERT_CHK => 0,                      -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
            SRC_INPUT_REG => 1,                       -- DECIMAL; 0=do not register input, 1=register input
            WIDTH => r_counterFast'length                               -- DECIMAL; range: 1-1024
        )
        port map (
            dest_out => r_counterFast_slow,               -- WIDTH-bit output: src_in synchronized to the destination clock domain. This
            dest_clk => i_clk,                   -- 1-bit input: Clock signal for the destination clock domain.
            src_clk => i_clk_fast,                         -- 1-bit input: optional; required when SRC_INPUT_REG = 1
            src_in => r_counterFast            -- WIDTH-bit input: Input single-bit array to be synchronized to destination clock
        );

end Behavioral;
