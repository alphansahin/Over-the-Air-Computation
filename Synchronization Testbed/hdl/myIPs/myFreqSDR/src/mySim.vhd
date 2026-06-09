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
        addr_width : integer := 7;
        data_width : integer := 12;  -- Bit width of each data entry    
        log2_number_Of_FIR_coefficients : integer := 4;
        bitWidth_FIR_coefficients : integer := 6
    );

end mySim;

architecture Behavioral of mySim is
    component myFreqSDR_wrapper is
        port (
            params_enableRXConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
            params_enableTXConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
            params_isTXPathConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
            params_sequenceSelConf : in STD_LOGIC_VECTOR ( 4 downto 0 );

            params_coefImag0 : in STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
            params_coefImag1 : in STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
            params_coefReal0 : in STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
            params_coefReal1 : in STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );

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

            info_cntDetection : out STD_LOGIC_VECTOR ( 15 downto 0 );
            info_enableRX : out STD_LOGIC;
            info_enableTX : out STD_LOGIC;
            info_fifoRX_count : out STD_LOGIC_VECTOR ( 14 downto 0 );
            info_isTXPath : out STD_LOGIC;
            info_overflow : out STD_LOGIC;
            info_sequenceSel : out STD_LOGIC;
            
            params_timer1_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
            params_timer2_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
            params_timer3_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
            params_timer4_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );

            clk : in STD_LOGIC;

            arstn : in STD_LOGIC
        );
    end component myFreqSDR_wrapper;

    component myCyclicROM is
        generic (
            initfile : string := "somefile.mem";
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
    
    constant clk_period : time := 1ns;
    signal clk : STD_LOGIC:='0';
    signal arstn : STD_LOGIC;
    signal startTX_r : STD_LOGIC := '0';
    ---

    signal es_params_enableRXConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal es_params_enableTXConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal es_params_isTXPathConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal es_params_sequenceSelConf : STD_LOGIC_VECTOR ( 4 downto 0 );
    signal es_params_coefImag0 : STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
    signal es_params_coefImag1 : STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
    signal es_params_coefReal0 : STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
    signal es_params_coefReal1 : STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
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
    signal ed_params_coefImag0 : STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
    signal ed_params_coefImag1 : STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
    signal ed_params_coefReal0 : STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
    signal ed_params_coefReal1 : STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );

    signal ed_params_timer1_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );
    signal ed_params_timer2_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );
    signal ed_params_timer3_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );
    signal ed_params_timer4_inSample : STD_LOGIC_VECTOR ( 15 downto 0 );

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
    myFreqSDR_ES_i: component myFreqSDR_wrapper
        port map (
            IQfromRAM_TX_s_tdata => es_IQfromRAM_TX_s_tdata ,
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


            params_coefReal0((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0)           => es_params_coefReal0((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0),
            params_coefReal1((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0)           => es_params_coefReal1((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0),
            params_coefImag0((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0)           => es_params_coefImag0((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0),
            params_coefImag1((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0)           => es_params_coefImag1((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0),
            params_enableRXConf(4 downto 0)         => es_params_enableRXConf(4 downto 0),
            params_enableTXConf(4 downto 0)         => es_params_enableTXConf(4 downto 0),
            params_isTXPathConf(4 downto 0)         => es_params_isTXPathConf(4 downto 0),
            params_sequenceSelConf(4 downto 0)      => es_params_sequenceSelConf(4 downto 0),
            params_timer1_inSample(15 downto 0)     => es_params_timer1_inSample(15 downto 0),
            params_timer2_inSample(15 downto 0)     => es_params_timer2_inSample(15 downto 0),
            params_timer3_inSample(15 downto 0)     => es_params_timer3_inSample(15 downto 0),
            params_timer4_inSample(15 downto 0)     => es_params_timer4_inSample(15 downto 0),
            info_cntDetection => open,
            info_enableRX     => open,
            info_enableTX     => open,
            info_fifoRX_count => open,
            info_isTXPath     => open,
            info_overflow     => open,
            info_sequenceSel  => open,
            clk                                     => clk,
            arstn                                   => arstn
        );


    cyclicROM_ES_i: component myCyclicROM
        generic map (
            initfile                                => "es_data.mem",
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


    myFreqSDR_ED_i: component myFreqSDR_wrapper
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

            params_coefReal0((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0)           => ed_params_coefReal0((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0),
            params_coefReal1((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0)           => ed_params_coefReal1((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0),            
            params_coefImag0((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0)           => ed_params_coefImag0((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0),
            params_coefImag1((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0)           => ed_params_coefImag1((2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0),
            params_enableRXConf(4 downto 0)         => ed_params_enableRXConf(4 downto 0),
            params_enableTXConf(4 downto 0)         => ed_params_enableTXConf(4 downto 0),
            params_isTXPathConf(4 downto 0)         => ed_params_isTXPathConf(4 downto 0),
            params_sequenceSelConf(4 downto 0)      => ed_params_sequenceSelConf(4 downto 0),
            params_timer1_inSample(15 downto 0)     => ed_params_timer1_inSample(15 downto 0),
            params_timer2_inSample(15 downto 0)     => ed_params_timer2_inSample(15 downto 0),
            params_timer3_inSample(15 downto 0)     => ed_params_timer3_inSample(15 downto 0),
            params_timer4_inSample(15 downto 0)     => ed_params_timer4_inSample(15 downto 0),
            info_cntDetection => open,
            info_enableRX     => open,
            info_enableTX     => open,
            info_fifoRX_count => open,
            info_isTXPath     => open,
            info_overflow     => open,
            info_sequenceSel  => open,
            clk                                     => clk,
            arstn                                   => arstn
        );        


    cyclicROM_ED_i: component myCyclicROM
        generic map (
            initfile                                => "ed_data.mem",
            addr_width                              => addr_width,
            data_width                              => data_width  -- Bit width of each data entry
        )    
        port map (
            arstn                                   => arstn,
            clk                                     => clk,
            ready                                   => ed_IQfromRAM_TX_s_tready and startTX_r,
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

    process
    begin
        -- hold reset state for 100 ns.
        arstn                   <= '0';

        -- es_params_enableRXConf     <= b"00110";
        es_params_enableRXConf     <= b"11111";
        es_params_enableTXConf     <= b"11111";
        es_params_isTXPathConf     <= b"00001";
        es_params_sequenceSelConf  <= b"00000";
        es_params_coefReal0        <= x"359e63d4d69c75c68dd63e59"; -- std_logic_vector(to_unsigned(1, 48));
        es_params_coefReal1        <= x"359e63d4d69c75c68dd63e59";
        es_params_coefImag0        <= x"90773e9a6cfc03cce69be707";
        es_params_coefImag1        <= x"90773e9a6cfc03cce69be707";
        es_params_timer1_inSample  <= std_logic_vector(to_unsigned(7, 16));
        es_params_timer2_inSample  <= std_logic_vector(to_unsigned(7, 16));
        es_params_timer3_inSample  <= std_logic_vector(to_unsigned(0, 16));
        es_params_timer4_inSample  <= std_logic_vector(to_unsigned(0, 16));

        ed_params_enableRXConf     <= b"00110";
        ed_params_enableTXConf     <= b"11110";
        ed_params_isTXPathConf     <= b"00000";
        ed_params_sequenceSelConf  <= b"00000";
        ed_params_coefReal0        <= x"359e63d4d69c75c68dd63e59"; -- std_logic_vector(to_unsigned(1, 48));
        ed_params_coefReal1        <= x"359e63d4d69c75c68dd63e59";
        ed_params_coefImag0        <= x"90773e9a6cfc03cce69be707";
        ed_params_coefImag1        <= x"90773e9a6cfc03cce69be707";
        ed_params_timer1_inSample  <= std_logic_vector(to_unsigned(7, 16));
        ed_params_timer2_inSample  <= std_logic_vector(to_unsigned(7, 16));
        ed_params_timer3_inSample  <= std_logic_vector(to_unsigned(0, 16));
        ed_params_timer4_inSample  <= std_logic_vector(to_unsigned(0, 16));

        wait for 20 ns;
        arstn                   <= '1';
        
        wait for 50 ns;
        startTX_r <= '1';
        wait for 600 ns;
    end process;

end Behavioral;
