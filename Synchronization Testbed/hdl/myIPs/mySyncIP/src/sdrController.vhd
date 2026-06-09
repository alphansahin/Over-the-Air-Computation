----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2025 01:23:43 PM
-- Design Name: 
-- Module Name: sdrController - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_misc.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity sdrController is
    generic (
        constant NUM_STATUS_REGS: integer := 2;
        log2_number_Of_FIR_coefficients : integer := 6;
        bitWidth_FIR_coefficients : integer := 8
    );
    PORT(
        -------------------------------------------
        -- Receiver
        data_IQfromRF_RX_i: in  STD_LOGIC_VECTOR (31 downto 0);
        valid_IQfromRF_RX_i : in STD_LOGIC;
        ready_IQfromRF_RX_o : out STD_LOGIC;

        data_IQtoRAM_RX_o: out  STD_LOGIC_VECTOR (31 downto 0);
        valid_IQtoRAM_RX_o : out STD_LOGIC;

        -- Transmitter
        data_IQfromRAM_TX_i: in  STD_LOGIC_VECTOR (31 downto 0);
        valid_IQfromRAM_TX_i : in STD_LOGIC;
        ready_IQfromRAM_TX_o : out STD_LOGIC;

        data_IQtoRF_TX_o: out  STD_LOGIC_VECTOR (31 downto 0);
        valid_IQtoRF_TX_o : out STD_LOGIC;

        -------------------------------------------
        -- Phase compensation related I/O
        data_IQtoBeRotated_o: out  STD_LOGIC_VECTOR (31 downto 0);
        data_IQrotated_i: in  STD_LOGIC_VECTOR (31 downto 0);


        -------------------------------------------
        -- XCORR related I/O
        IQeffective : out STD_LOGIC_VECTOR (23 downto 0);
        o_IQdata_wr                        :   out    std_logic;  -- ufix1
        syncDetected                        :   IN    std_logic;  -- ufix1
        

        -------------------------------------------
        -- Parameters

        timer1_inSample                     :   IN    std_logic_vector(15 DOWNTO 0);
        timer2_inSample                     :   IN    std_logic_vector(15 DOWNTO 0);
        timer3_inSample                     :   IN    std_logic_vector(15 DOWNTO 0);
        timer4_inSample                     :   IN    std_logic_vector(15 DOWNTO 0);

        enableRXconf                        :   IN    std_logic_vector(4 DOWNTO 0);
        enableTXconf                        :   IN    std_logic_vector(4 DOWNTO 0);
        isTXPathConf                        :   IN    std_logic_vector(4 DOWNTO 0);
        sequenceSelConf                     :   IN    std_logic_vector(4 DOWNTO 0);
        enablePhaseEstConf                  :   IN    std_logic_vector(4 DOWNTO 0);
        enablePhaseCorrConf                 :   IN    std_logic_vector(4 DOWNTO 0);
        isConjugatedConf                    :   IN    std_logic_vector(4 DOWNTO 0);
        addPhaseBiasConf                    :   IN    std_logic_vector(4 DOWNTO 0);

        numeratorkPhase_i                   :   IN   std_logic_vector(26 DOWNTO 0);
        
        
        fifoRX_count                        :   IN   std_logic_vector(14 DOWNTO 0);



        sequenceSel                         :   OUT   std_logic;
        enablePhaseEst                      :   OUT   std_logic;
        isConjugated                        :   OUT   std_logic;
        addPhaseBias                        :   OUT   std_logic;


        numeratorkPhase_o                   :   OUT   std_logic_vector(26 DOWNTO 0);

        status_myController                 : out std_logic_vector (NUM_STATUS_REGS*32-1 downto 0);


        clk                                 :   IN    std_logic; 
        arstn                               :   IN    std_logic  -- ufix1
    );
end sdrController;

architecture Behavioral of sdrController is
    ATTRIBUTE X_INTERFACE_INFO: string;

    ATTRIBUTE X_INTERFACE_INFO of data_IQfromRF_RX_i: signal is "xilinx.com:interface:axis:1.0 IQfromRF_RX_s tdata";
    ATTRIBUTE X_INTERFACE_INFO of ready_IQfromRF_RX_o: signal is "xilinx.com:interface:axis:1.0 IQfromRF_RX_s tready";
    ATTRIBUTE X_INTERFACE_INFO of valid_IQfromRF_RX_i: signal is "xilinx.com:interface:axis:1.0 IQfromRF_RX_s tvalid";

    ATTRIBUTE X_INTERFACE_INFO of data_IQtoRAM_RX_o: signal is "xilinx.com:interface:axis:1.0 IQtoRAM_RX_m tdata";
    ATTRIBUTE X_INTERFACE_INFO of valid_IQtoRAM_RX_o: signal is "xilinx.com:interface:axis:1.0 IQtoRAM_RX_m tvalid";


    ATTRIBUTE X_INTERFACE_INFO of data_IQfromRAM_TX_i: signal is "xilinx.com:interface:axis:1.0 IQfromRAM_TX_s tdata";
    ATTRIBUTE X_INTERFACE_INFO of ready_IQfromRAM_TX_o: signal is "xilinx.com:interface:axis:1.0 IQfromRAM_TX_s tready";
    ATTRIBUTE X_INTERFACE_INFO of valid_IQfromRAM_TX_i: signal is "xilinx.com:interface:axis:1.0 IQfromRAM_TX_s tvalid";


    ATTRIBUTE X_INTERFACE_INFO of data_IQtoRF_TX_o: signal is "xilinx.com:interface:axis:1.0 IQtoRF_TX_m tdata";
    ATTRIBUTE X_INTERFACE_INFO of valid_IQtoRF_TX_o: signal is "xilinx.com:interface:axis:1.0 IQtoRF_TX_m tvalid";




    component correlatorSlicer is
        Port (
            inphase_tx_in : in STD_LOGIC_VECTOR (15 downto 0);
            quadrature_tx_in : in STD_LOGIC_VECTOR (15 downto 0);
            inphase_rx_in : in STD_LOGIC_VECTOR (15 downto 0);
            quadrature_rx_in : in STD_LOGIC_VECTOR (15 downto 0);
            isTXpath: in std_logic;
            inphase_out : out STD_LOGIC_VECTOR (11 downto 0);
            quadrature_out : out STD_LOGIC_VECTOR (11 downto 0);
            iqConcat_out : out STD_LOGIC_VECTOR (31 downto 0);
            iqConcatNoPadding_out : out STD_LOGIC_VECTOR (23 downto 0)
        );
    end component ;

    component FIRcontroller is
        generic (
            log2_number_Of_FIR_coefficients : integer := log2_number_Of_FIR_coefficients;
            bitWidth_FIR_coefficients : integer := bitWidth_FIR_coefficients
        );
        Port (
            FIR_coef_i : in STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
            FIR_isConfigurationLoaded_o : out STD_LOGIC;
            FIR_reload_last : out STD_LOGIC;
            FIR_reload_ready : in STD_LOGIC;
            FIR_reload_valid : out STD_LOGIC;
            FIR_reload_data : out STD_LOGIC_VECTOR (7 downto 0);
            FIR_config_ready  : in STD_LOGIC;
            FIR_config_valid : out STD_LOGIC;
            FIR_config_data : out STD_LOGIC_VECTOR (7 downto 0);
            FIR_arst_o : out STD_LOGIC;
            clk                                 :   IN    std_logic;  -- ufix1
            arstn                               :   IN    std_logic  -- ufix1
        );
    end component;


    -- Timer related signals
    signal FIRreal_isConfigurationLoaded_r    : std_logic;
    signal FIRimag_isConfigurationLoaded_r    : std_logic;
    signal enableRX_r    : std_logic;
    signal enableTX_r    : std_logic;
    signal isTXPath_r    : std_logic;
    signal sequenceSel_r : std_logic;
    signal enablePhaseEst_r  : std_logic;
    signal enablePhaseCorr_r : std_logic;
    signal isConjugated_r    : std_logic;
    signal addPhaseBias_r    : std_logic;


    signal stateTimer : STD_LOGIC;
    signal selectTimer : unsigned(1 downto 0 ) := "00";
    constant timerIsIdle : STD_LOGIC := '0';
    constant timerIsRunning : STD_LOGIC := '1';

    signal counterSample : unsigned(15 downto 0 );
    signal cntDetectionAsMode_r : unsigned(15 downto 0 );
    signal timer_inSample : unsigned(15 downto 0 );

    constant ZERO : std_logic_vector(31 downto 0) := (others => '0');
    type std_logic_vector_array_t is array (natural range <>) of std_logic_vector(31 downto 0);
    signal status_myController_r : std_logic_vector_array_t(0 to NUM_STATUS_REGS-1);
    
    
begin
    gen_status: for i in 0 to NUM_STATUS_REGS-1 generate
        status_myController(i*32 +  31 downto i*32) <= status_myController_r(i);
    end generate gen_status ;
    status_myController_r(0)  <=  ZERO(31 downto 24) & addPhaseBias_r & isConjugated_r & enablePhaseCorr_r & enablePhaseEst_r &  sequenceSel_r & isTXPath_r & enableTX_r & enableRX_r & std_logic_vector(cntDetectionAsMode_r);
    status_myController_r(1)  <= ZERO(31 downto fifoRX_count'length) & fifoRX_count;
    
    -- rx chain
    data_IQtoRAM_RX_o <= data_IQfromRF_RX_i when enableRX_r = '1' else (others => '0');
    valid_IQtoRAM_RX_o <= valid_IQfromRF_RX_i when enableRX_r = '1'  else '0';
    ready_IQfromRF_RX_o <= '1' when enableRX_r = '1' else '0';

    -- tx chain
    data_IQtoBeRotated_o  <= data_IQfromRAM_TX_i;
    data_IQtoRF_TX_o <= data_IQrotated_i when enablePhaseCorr_r = '1' and enableTX_r = '1' else
                            data_IQfromRAM_TX_i when enablePhaseCorr_r = '0' and enableTX_r = '1' else
                            (others => '0');

    valid_IQtoRF_TX_o <= valid_IQfromRAM_TX_i when enableTX_r = '1' else '0';
    ready_IQfromRAM_TX_o <= '1' when enableTX_r = '1' else '0';

    -- correlator
    sequenceSel     <= sequenceSel_r;
    enablePhaseEst  <= enablePhaseEst_r;
    isConjugated    <= isConjugated_r;
    addPhaseBias    <= addPhaseBias_r;

    numeratorkPhase_o       <= numeratorkPhase_i;

    correlatorMux_i: component correlatorSlicer
        Port map(
            inphase_tx_in => data_IQfromRAM_TX_i(15 downto 0),
            quadrature_tx_in => data_IQfromRAM_TX_i(31 downto 16),
            inphase_rx_in => data_IQfromRF_RX_i(15 downto 0),
            quadrature_rx_in => data_IQfromRF_RX_i(31 downto 16),
            isTXpath => isTXpath_r,
            inphase_out => open,
            quadrature_out => open,
            iqConcat_out => open,
            iqConcatNoPadding_out => IQeffective
        );
        
    o_IQdata_wr <= valid_IQfromRAM_TX_i when isTXpath_r = '1' else valid_IQfromRAM_TX_i; 

    process(arstn,clk)
    begin
        if arstn = '0' then
            cntDetectionAsMode_r <= (others=> '0');
            stateTimer <= timerIsIdle;
            selectTimer <= (others=> '0');
            counterSample <= (to_unsigned(0, 16));
            
        elsif rising_edge(clk) then
            case stateTimer is
                when timerIsIdle =>
                    if syncDetected = '1' then
                        cntDetectionAsMode_r <= cntDetectionAsMode_r + 1;
                        if unsigned(timer_inSample) /= 0 then
                            stateTimer <= timerIsRunning;
                            counterSample <= unsigned(timer_inSample);
                            selectTimer <= selectTimer + 1;
                        end if;
                    end if;
                when timerIsRunning => -- pass
                    if counterSample = (to_unsigned(1, 16)) then
                        if selectTimer = "00" then
                            stateTimer <= timerIsIdle;
                        else
                            if unsigned(timer_inSample) /= 0 then
                                stateTimer <= timerIsRunning;
                                counterSample <= unsigned(timer_inSample);
                                selectTimer <= selectTimer + 1;
                            else
                                stateTimer <= timerIsIdle;
                                selectTimer <= "00";
                            end if;
                        end if;
                    else
                        counterSample <= counterSample - 1;
                    end if;

                when others =>
            end case;
        end if;
    end process;

    process (selectTimer,timer1_inSample,timer2_inSample,timer3_inSample,timer4_inSample)  begin
        case selectTimer is
            when "00" =>
                timer_inSample <= unsigned(timer1_inSample);
            when "01" =>
                timer_inSample <= unsigned(timer2_inSample);
            when "10" =>
                timer_inSample <= unsigned(timer3_inSample);
            when "11" =>
                timer_inSample <= unsigned(timer4_inSample);
            when others =>
                timer_inSample <= (others => '0');
        end case;
    end process;
    process (selectTimer,stateTimer,enableRXconf,enableTXconf,isTXPathConf,sequenceSelConf,enablePhaseEstConf,enablePhaseCorrConf,isConjugatedConf,addPhaseBiasConf)  begin
        case stateTimer & selectTimer  is
            when timerIsRunning & "00" =>
                enableRX_r    <= enableRXconf(4);
                enableTX_r    <= enableTXconf(4);
                isTXPath_r    <= isTXPathConf(4);
                sequenceSel_r <= sequenceSelConf(4);
                enablePhaseEst_r  <= enablePhaseEstConf(4);
                enablePhaseCorr_r <= enablePhaseCorrConf(4);
                isConjugated_r    <= isConjugatedConf(4);
                addPhaseBias_r    <= addPhaseBiasConf(4);
            when timerIsRunning & "01" =>
                enableRX_r    <= enableRXconf(1);
                enableTX_r    <= enableTXconf(1);
                isTXPath_r    <= isTXPathConf(1);
                sequenceSel_r <= sequenceSelConf(1);
                enablePhaseEst_r  <= enablePhaseEstConf(1);
                enablePhaseCorr_r <= enablePhaseCorrConf(1);
                isConjugated_r    <= isConjugatedConf(1);
                addPhaseBias_r    <= addPhaseBiasConf(1);
            when timerIsRunning & "10" =>
                enableRX_r    <= enableRXconf(2);
                enableTX_r    <= enableTXconf(2);
                isTXPath_r    <= isTXPathConf(2);
                sequenceSel_r <= sequenceSelConf(2);
                enablePhaseEst_r  <= enablePhaseEstConf(2);
                enablePhaseCorr_r <= enablePhaseCorrConf(2);
                isConjugated_r    <= isConjugatedConf(2);
                addPhaseBias_r    <= addPhaseBiasConf(2);
            when timerIsRunning & "11" =>
                enableRX_r    <= enableRXconf(3);
                enableTX_r    <= enableTXconf(3);
                isTXPath_r    <= isTXPathConf(3);
                sequenceSel_r <= sequenceSelConf(3);
                enablePhaseEst_r  <= enablePhaseEstConf(3);
                enablePhaseCorr_r <= enablePhaseCorrConf(3);
                isConjugated_r    <= isConjugatedConf(3);
                addPhaseBias_r    <= addPhaseBiasConf(3);
            when others =>
                enableRX_r    <= enableRXconf(0);
                enableTX_r    <= enableTXconf(0);
                isTXPath_r    <= isTXPathConf(0);
                sequenceSel_r <= sequenceSelConf(0);
                enablePhaseEst_r  <= enablePhaseEstConf(0);
                enablePhaseCorr_r <= enablePhaseCorrConf(0);
                isConjugated_r    <= isConjugatedConf(0);
                addPhaseBias_r    <= addPhaseBiasConf(0);
        end case;
    end process;

end Behavioral;


