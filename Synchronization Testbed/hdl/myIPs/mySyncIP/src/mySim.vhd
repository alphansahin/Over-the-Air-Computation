----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2025 01:06:15 PM
-- Design Name: 
-- Module Name: mySim - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_Std.all;
use ieee.std_logic_misc.all;

use ieee.std_logic_textio.all;


library std ;
use std.textio.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mySim is
    generic (
        addr_width : integer := 11;
        data_width : integer := 16;  -- Bit width of each data entry    
        log2_number_Of_FIR_coefficients : integer := 6;
        bitWidth_FIR_coefficients : integer := 8
    );

end mySim;

architecture Behavioral of mySim is
    component syncIP_wrapper is
        port (
            params_enableRXConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
            params_enableTXConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
            params_isTXPathConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
            params_sequenceSelConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
            params_enablePhaseCorrConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
            params_enablePhaseEstConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
            params_addPhaseBiasConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
            params_isConjugatedConf : in STD_LOGIC_VECTOR ( 4 downto 0 );

            params_numeratorkPhase : in STD_LOGIC_VECTOR ( 26 downto 0 );


            params_FIRcoef_addr : in STD_LOGIC_VECTOR ( 31 downto 0 );
            params_FIRcoef_imagValues_rd : out STD_LOGIC_VECTOR ( 31 downto 0 );
            params_FIRcoef_imagValues_wr : in STD_LOGIC_VECTOR ( 31 downto 0 );
            params_FIRcoef_realValues_rd : out STD_LOGIC_VECTOR ( 31 downto 0 );
            params_FIRcoef_realValues_wr : in STD_LOGIC_VECTOR ( 31 downto 0 );
            params_FIRcoef_wr : in STD_LOGIC;

            IQfromRAM_TX_s_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
            IQfromRAM_TX_s_tready : out STD_LOGIC;
            IQfromRAM_TX_s_tvalid : in STD_LOGIC;

            IQfromRF_RX_s_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
            IQfromRF_RX_s_tready : out STD_LOGIC;
            IQfromRF_RX_s_tvalid : in STD_LOGIC;

            IQtoRAM_RX_m_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
            IQtoRAM_RX_m_tready : in STD_LOGIC;
            IQtoRAM_RX_m_tvalid : out STD_LOGIC;

            IQtoRF_TX_m_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
            IQtoRF_TX_m_tvalid : out STD_LOGIC;



            params_timer1_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
            params_timer2_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
            params_timer3_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
            params_timer4_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );


            status_myPhaseEstimation    : out STD_LOGIC_VECTOR ( 31 downto 0 );
            status_myController         : out STD_LOGIC_VECTOR ( 63 downto 0 );
            status_myDetector           : out STD_LOGIC_VECTOR ( 319 downto 0 );

            clk_fast : in STD_LOGIC;
            arstn_fast : in STD_LOGIC;
            clk : in STD_LOGIC;
            arstn : in STD_LOGIC
        );
    end component syncIP_wrapper;

    component myCyclicROM is
        generic (
            initilizationIndex : integer;
            addr_width : integer := addr_width;
            data_width : integer := data_width  -- Bit width of each data entry
        );
        port (
            arstn       : in std_logic;
            clk         : in  std_logic;
            ready       : in  std_logic;
            valid       : out std_logic;
            last        : out  std_logic;
            data        : out std_logic_vector(31 downto 0)
        );
    end component myCyclicROM;

    constant clk_period : time := 8ns;
    constant clk_fast_period : time := 1ns;
    signal clk : STD_LOGIC:='0';
    signal arstn : STD_LOGIC;
    signal clk_fast : STD_LOGIC:='0';
    signal arstn_fast : STD_LOGIC;
    signal startTX_r : STD_LOGIC := '0';
    signal isLoading : STD_LOGIC;
    ---

    signal coefReal0: std_logic_vector(511 downto 0) := x"6cb7ef63a4f26ac7b25938a2c35258da92d2416d3de4a294b3e71b425b686c6d6d6d6c685b421be7b394a2e43d6d41d292da5852c3a23859b2c76af2a463efb7";
    signal coefImag0: std_logic_vector(511 downto 0) := x"44429a2c3f921c5cb3bf5e37a5b74266009ca8075b6a38eeb39596a9c3dcf0fc00fcf0dcc3a99695b3ee386a5b07a89c006642b7a5375ebfb35c1c923f2c9a42";
    signal coefReal1: std_logic_vector(511 downto 0) := x"8159049d7bd8a5702787c7567d4703d8cad803477d56c7872770a5d87b9d04598159049d7bd8a5702787c7567d4703d8cad803477d56c7872770a5d87b9d0459";
    signal coefImag1: std_logic_vector(511 downto 0) := x"00a67fb0e278a8c579258fa317697f7873787f6917a38f2579c5a878e2b07fa6005a81501e88583b87db715de99781888d888197e95d71db873b58881e50815a";


--    signal coefReal0: std_logic_vector(511 downto 0) := x"7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f";
--    signal coefImag0: std_logic_vector(511 downto 0) := x"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
--    signal coefReal1: std_logic_vector(511 downto 0) := x"020406080a0c0e10121416181a1c1e20222426282a2c2e30323436383a3c3e4041434547494b4d4f51535557595b5d5f61636567696b6d6f71737577797b7d7f";
--    signal coefImag1: std_logic_vector(511 downto 0) := x"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

    
    signal coefImag_r : STD_LOGIC_VECTOR ( bitWidth_FIR_coefficients-1 downto 0 );
    signal coefReal_r : STD_LOGIC_VECTOR ( bitWidth_FIR_coefficients-1 downto 0 );
    signal params_FIRcoef_addr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal params_FIRcoef_imagValues_wr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal params_FIRcoef_realValues_wr : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal params_FIRcoef_wr : STD_LOGIC;

    signal es_params_enableRXConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal es_params_enableTXConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal es_params_isTXPathConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal es_params_sequenceSelConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal es_params_enablePhaseCorrConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal es_params_enablePhaseEstConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal es_params_addPhaseBiasConf        : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal es_params_isConjugatedConf    : STD_LOGIC_VECTOR ( 4 downto 0 );

    signal es_params_numeratorkPhase    : STD_LOGIC_VECTOR ( 26 downto 0 );


    signal es_params_timer1_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );
    signal es_params_timer2_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );
    signal es_params_timer3_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );
    signal es_params_timer4_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );


    signal es_IQfromRAM_TX_s_tdata    : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal es_IQfromRAM_TX_s_tready   : STD_LOGIC;
    signal es_IQfromRAM_TX_s_tvalid   : STD_LOGIC;
    signal es_IQfromRF_RX_s_tdata     : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal es_IQfromRF_RX_s_tready    : STD_LOGIC;
    signal es_IQfromRF_RX_s_tvalid    : STD_LOGIC;
    signal es_IQtoRAM_RX_m_tdata      : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal es_IQtoRAM_RX_m_tvalid     : STD_LOGIC;
    signal es_IQtoRF_TX_m_tdata       : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal es_IQtoRF_TX_m_tvalid      : STD_LOGIC;


    signal ed_params_enableRXConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal ed_params_enableTXConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal ed_params_isTXPathConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal ed_params_sequenceSelConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal ed_params_enablePhaseCorrConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal ed_params_enablePhaseEstConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal ed_params_addPhaseBiasConf        : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal ed_params_isConjugatedConf    : STD_LOGIC_VECTOR ( 4 downto 0 );

    signal ed_params_numeratorkPhase    : STD_LOGIC_VECTOR ( 26 downto 0 );



    signal ed_params_timer1_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );
    signal ed_params_timer2_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );
    signal ed_params_timer3_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );
    signal ed_params_timer4_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );

    signal es_IQfromRAM_TX_s_tdata_m    : STD_LOGIC_VECTOR ( 31 downto 0 );

    signal ed_IQfromRAM_TX_s_tdata    : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal ed_IQfromRAM_TX_s_tready   : STD_LOGIC;
    signal ed_IQfromRAM_TX_s_tvalid   : STD_LOGIC;
    signal ed_IQfromRF_RX_s_tdata     : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal ed_IQfromRF_RX_s_tready    : STD_LOGIC;
    signal ed_IQfromRF_RX_s_tvalid    : STD_LOGIC;
    signal ed_IQtoRAM_RX_m_tdata      : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal ed_IQtoRAM_RX_m_tvalid     : STD_LOGIC;
    signal ed_IQtoRF_TX_m_tdata       : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal ed_IQtoRF_TX_m_tvalid      : STD_LOGIC;


begin
    es_IQfromRAM_TX_s_tdata_m <=  es_IQfromRAM_TX_s_tdata when startTX_r = '1' else (others=>'0');

    syncIP_ES_i: component syncIP_wrapper
        port map (
            IQfromRAM_TX_s_tdata => es_IQfromRAM_TX_s_tdata_m ,
            IQfromRAM_TX_s_tready=> es_IQfromRAM_TX_s_tready,
            IQfromRAM_TX_s_tvalid=> es_IQfromRAM_TX_s_tvalid,

            IQfromRF_RX_s_tdata  => es_IQfromRF_RX_s_tdata  ,
            IQfromRF_RX_s_tready => es_IQfromRF_RX_s_tready ,
            IQfromRF_RX_s_tvalid => es_IQfromRF_RX_s_tvalid ,

            IQtoRAM_RX_m_tdata   => es_IQtoRAM_RX_m_tdata   ,
            IQtoRAM_RX_m_tready  => '0',
            IQtoRAM_RX_m_tvalid  => es_IQtoRAM_RX_m_tvalid  ,

            IQtoRF_TX_m_tdata    => es_IQtoRF_TX_m_tdata    ,
            IQtoRF_TX_m_tvalid   => es_IQtoRF_TX_m_tvalid   ,


            params_FIRcoef_addr             =>  params_FIRcoef_addr          ,
            params_FIRcoef_imagValues_rd    =>  open ,
            params_FIRcoef_imagValues_wr    =>  params_FIRcoef_imagValues_wr ,
            params_FIRcoef_realValues_rd    =>  open ,
            params_FIRcoef_realValues_wr    =>  params_FIRcoef_realValues_wr ,
            params_FIRcoef_wr               =>  params_FIRcoef_wr            ,


            status_myPhaseEstimation   =>  open ,
            status_myController        =>  open ,
            status_myDetector          =>  open ,
            
            params_enableRXConf(4 downto 0)         => es_params_enableRXConf(4 downto 0),
            params_enableTXConf(4 downto 0)         => es_params_enableTXConf(4 downto 0),
            params_isTXPathConf(4 downto 0)         => es_params_isTXPathConf(4 downto 0),
            params_sequenceSelConf(4 downto 0)      => es_params_sequenceSelConf(4 downto 0),
            params_enablePhaseCorrConf(4 downto 0)  => es_params_enablePhaseCorrConf(4 downto 0),
            params_enablePhaseEstConf(4 downto 0)   => es_params_enablePhaseEstConf(4 downto 0) ,
            params_addPhaseBiasConf(4 downto 0)         => es_params_addPhaseBiasConf(4 downto 0),
            params_isConjugatedConf(4 downto 0)     => es_params_isConjugatedConf(4 downto 0),

            params_numeratorkPhase                        => es_params_numeratorkPhase,


            params_timer1_inSample(15 downto 0)     => es_params_timer1_inSample(15 downto 0),
            params_timer2_inSample(15 downto 0)     => es_params_timer2_inSample(15 downto 0),
            params_timer3_inSample(15 downto 0)     => es_params_timer3_inSample(15 downto 0),
            params_timer4_inSample(15 downto 0)     => es_params_timer4_inSample(15 downto 0),

            clk_fast                                     => clk_fast,
            arstn_fast                                   => arstn_fast,
            clk                                     => clk,
            arstn                                   => arstn
        );


    cyclicROM_ES_i: component myCyclicROM
        generic map (
            initilizationIndex                  => 0,
            addr_width                              => addr_width,
            data_width                              => data_width  -- Bit width of each data entry
        )
        port map (
            arstn                                   => arstn,
            clk                                     => clk,
            ready                                   => es_IQfromRAM_TX_s_tready and startTX_r,
            valid                                   => es_IQfromRAM_TX_s_tvalid,
            last                                    => open,
            data                                    => es_IQfromRAM_TX_s_tdata
        );


    syncIP_ED_i: component syncIP_wrapper
        port map (
            IQfromRAM_TX_s_tdata => ed_IQfromRAM_TX_s_tdata   ,
            IQfromRAM_TX_s_tready=> ed_IQfromRAM_TX_s_tready  ,
            IQfromRAM_TX_s_tvalid=> ed_IQfromRAM_TX_s_tvalid  ,

            IQfromRF_RX_s_tdata  => ed_IQfromRF_RX_s_tdata    ,
            IQfromRF_RX_s_tready => ed_IQfromRF_RX_s_tready   ,
            IQfromRF_RX_s_tvalid => ed_IQfromRF_RX_s_tvalid   ,

            IQtoRAM_RX_m_tdata   => ed_IQtoRAM_RX_m_tdata     ,
            IQtoRAM_RX_m_tready  => '0',
            IQtoRAM_RX_m_tvalid  => ed_IQtoRAM_RX_m_tvalid    ,

            IQtoRF_TX_m_tdata    => ed_IQtoRF_TX_m_tdata      ,
            IQtoRF_TX_m_tvalid   => ed_IQtoRF_TX_m_tvalid     ,

            params_FIRcoef_addr             =>  params_FIRcoef_addr          ,
            params_FIRcoef_imagValues_rd    =>  open ,
            params_FIRcoef_imagValues_wr    =>  params_FIRcoef_imagValues_wr ,
            params_FIRcoef_realValues_rd    =>  open ,
            params_FIRcoef_realValues_wr    =>  params_FIRcoef_realValues_wr ,
            params_FIRcoef_wr               =>  params_FIRcoef_wr            ,


            status_myPhaseEstimation   =>  open ,
            status_myController        =>  open ,
            status_myDetector          =>  open ,
            

            params_enableRXConf(4 downto 0)         => ed_params_enableRXConf(4 downto 0),
            params_enableTXConf(4 downto 0)         => ed_params_enableTXConf(4 downto 0),
            params_isTXPathConf(4 downto 0)         => ed_params_isTXPathConf(4 downto 0),
            params_sequenceSelConf(4 downto 0)      => ed_params_sequenceSelConf(4 downto 0),
            params_enablePhaseCorrConf(4 downto 0)  => ed_params_enablePhaseCorrConf(4 downto 0),
            params_enablePhaseEstConf(4 downto 0)   => ed_params_enablePhaseEstConf(4 downto 0) ,
            params_addPhaseBiasConf(4 downto 0)     => ed_params_addPhaseBiasConf(4 downto 0),
            params_isConjugatedConf(4 downto 0)     => ed_params_isConjugatedConf(4 downto 0),

            params_numeratorkPhase                        => ed_params_numeratorkPhase,





            params_timer1_inSample(15 downto 0)     => ed_params_timer1_inSample(15 downto 0),
            params_timer2_inSample(15 downto 0)     => ed_params_timer2_inSample(15 downto 0),
            params_timer3_inSample(15 downto 0)     => ed_params_timer3_inSample(15 downto 0),
            params_timer4_inSample(15 downto 0)     => ed_params_timer4_inSample(15 downto 0),

            clk_fast                                     => clk_fast,
            arstn_fast                                   => arstn_fast,
            clk                                     => clk,
            arstn                                   => arstn
        );


    cyclicROM_ED_i: component myCyclicROM
        generic map (
            initilizationIndex                  => 1,
            addr_width                              => addr_width,
            data_width                              => data_width  -- Bit width of each data entry
        )
        port map (
            arstn                                   => arstn,
            clk                                     => clk,
            ready                                   => ed_IQfromRAM_TX_s_tready,
            valid                                   => ed_IQfromRAM_TX_s_tvalid,
            last                                    => open,
            data                                    => ed_IQfromRAM_TX_s_tdata
        );

    ed_IQfromRF_RX_s_tvalid <= es_IQtoRF_TX_m_tvalid;
    ed_IQfromRF_RX_s_tdata  <= (31 downto 28=>es_IQtoRF_TX_m_tdata(31)) & es_IQtoRF_TX_m_tdata(31 downto 16+4)  & (15 downto 12=>es_IQtoRF_TX_m_tdata(15)) &  es_IQtoRF_TX_m_tdata(15 downto 4);

    es_IQfromRF_RX_s_tvalid <= ed_IQtoRF_TX_m_tvalid;
    es_IQfromRF_RX_s_tdata <= ed_IQtoRF_TX_m_tdata;

    --generate clock
    clk_generation: process
    begin
        wait for clk_period/2;
        clk <= not clk; --toggle clock when half of clk_period is over
    end process;
    clk_fast_generation: process
    begin
        wait for clk_fast_period/2;
        clk_fast <= not clk_fast; --toggle clock when half of clk_period is over
    end process;

    params_FIRcoef_imagValues_wr(31 downto 8)  <= (others=>'0');
    params_FIRcoef_realValues_wr(31 downto 8)  <= (others=>'0');
    params_FIRcoef_imagValues_wr(7 downto 0) <= coefImag_r;
    params_FIRcoef_realValues_wr(7 downto 0) <= coefReal_r;


    coefImag_r <= coefImag0(7+to_integer(unsigned(params_FIRcoef_addr(5 downto 0)))*8 downto to_integer(unsigned(params_FIRcoef_addr(5 downto 0)))*8) when params_FIRcoef_addr(6) = '0' else coefImag1(7+to_integer(unsigned(params_FIRcoef_addr(5 downto 0)))*8 downto to_integer(unsigned(params_FIRcoef_addr(5 downto 0)))*8);
    coefReal_r <= coefReal0(7+to_integer(unsigned(params_FIRcoef_addr(5 downto 0)))*8 downto to_integer(unsigned(params_FIRcoef_addr(5 downto 0)))*8) when params_FIRcoef_addr(6) = '0' else coefReal1(7+to_integer(unsigned(params_FIRcoef_addr(5 downto 0)))*8 downto to_integer(unsigned(params_FIRcoef_addr(5 downto 0)))*8);

    FIRcoefFeed: process(clk,arstn)
    begin
        if(arstn='0') then
            params_FIRcoef_wr <= '0';
            params_FIRcoef_addr  <= (others=>'0');
            isLoading <= '0';
        elsif(rising_edge(clk)) then
            if isLoading = '0' then
                isLoading <= '1';
                params_FIRcoef_wr <= '1';
            else
                if params_FIRcoef_addr = x"000000FF" then
                    params_FIRcoef_wr <= '0';
                else
                    params_FIRcoef_addr(7 downto 0) <=  params_FIRcoef_addr(7 downto 0) + 1;
                    params_FIRcoef_wr <= '1';
                end if;
            end if;
        end if;
    end process;



    arstn_fast  <= arstn;
    process
    begin
        -- hold reset state for 100 ns.
        arstn                   <= '0';

        es_params_isTXPathConf          <= b"11111";
        es_params_enableRXConf          <= b"11111";
        es_params_enableTXConf          <= b"11111";
        es_params_sequenceSelConf       <= b"00000";
        es_params_isConjugatedConf      <= b"11111";
        es_params_enablePhaseCorrConf   <= b"11111";
        es_params_enablePhaseEstConf    <= b"11111";
        es_params_addPhaseBiasConf      <= b"11110";

        es_params_numeratorkPhase             <= std_logic_vector(to_signed(0000, 27));


        es_params_timer1_inSample       <= std_logic_vector(to_unsigned(4, 16));
        es_params_timer2_inSample       <= std_logic_vector(to_unsigned(992, 16));
        es_params_timer3_inSample       <= std_logic_vector(to_unsigned(340, 16));
        es_params_timer4_inSample       <= std_logic_vector(to_unsigned(0, 16));


        ed_params_isTXPathConf          <= b"00100";
        ed_params_enableRXConf          <= b"00000";
        ed_params_enableTXConf          <= b"11110";
        ed_params_sequenceSelConf       <= b"00100";
        ed_params_isConjugatedConf      <= b"00000";
        ed_params_enablePhaseCorrConf   <= b"11110";
        ed_params_enablePhaseEstConf    <= b"00101";
        ed_params_addPhaseBiasConf      <= b"00000";

        ed_params_numeratorkPhase             <= std_logic_vector(to_signed(0000, 27));



        ed_params_timer1_inSample  <= std_logic_vector(to_unsigned(8, 16));
        ed_params_timer2_inSample  <= std_logic_vector(to_unsigned(792, 16));
        ed_params_timer3_inSample  <= std_logic_vector(to_unsigned(800, 16));
        ed_params_timer4_inSample  <= std_logic_vector(to_unsigned(2400, 16));

        wait for 20 ns;
        arstn                   <= '1';

        wait for 2500 ns;
        startTX_r <= '1';

        wait for 1000 ns;
        es_params_numeratorkPhase             <= std_logic_vector(to_signed(10000, 27));

        wait for 5000 ns;
        startTX_r <= '0';
        wait;
    end process;

end Behavioral;
