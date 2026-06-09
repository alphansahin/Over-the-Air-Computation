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
        log2_number_Of_FIR_coefficients : integer := 4;
        bitWidth_FIR_coefficients : integer := 6
    );
    PORT(
        -------------------------------------------
        -- Receiver
        -- ADC 2 Controller interface - Slave
        data_IQfromRF_RX_i: in  STD_LOGIC_VECTOR (31 downto 0);
        valid_IQfromRF_RX_i : in STD_LOGIC;
        ready_IQfromRF_RX_o : out STD_LOGIC;
        
        -- Controller 2 RAM interface
        data_IQtoRAM_RX_o: out  STD_LOGIC_VECTOR (31 downto 0);
        valid_IQtoRAM_RX_o : out STD_LOGIC;



        -- Transmitter
        -- Ram 2 Controller interface - Slave
        data_IQfromRAM_TX_i: in  STD_LOGIC_VECTOR (31 downto 0);
        valid_IQfromRAM_TX_i : in STD_LOGIC;
        ready_IQfromRAM_TX_o : out STD_LOGIC;


        -- Controller 2 DAC interface
        data_IQtoRF_TX_o: out  STD_LOGIC_VECTOR (31 downto 0);
        valid_IQtoRF_TX_o : out STD_LOGIC;

        -------------------------------------------
        -- XCORR related I/O

        FIRimag_reload_last  : out STD_LOGIC;
        FIRimag_reload_ready  : in STD_LOGIC;
        FIRimag_reload_valid : out STD_LOGIC;
        FIRimag_reload_data : out STD_LOGIC_VECTOR (7 downto 0);

        FIRimag_config_ready  : in STD_LOGIC;
        FIRimag_config_valid : out STD_LOGIC;
        FIRimag_config_data : out STD_LOGIC_VECTOR (7 downto 0);

        FIRreal_reload_last  : out STD_LOGIC;
        FIRreal_reload_ready  : in STD_LOGIC;
        FIRreal_reload_valid : out STD_LOGIC;
        FIRreal_reload_data : out STD_LOGIC_VECTOR (7 downto 0);

        FIRreal_config_ready  : in STD_LOGIC;
        FIRreal_config_valid : out STD_LOGIC;
        FIRreal_config_data : out STD_LOGIC_VECTOR (7 downto 0);

        FIRimag_data_valid : out STD_LOGIC;
        FIRimag_data_ready: in STD_LOGIC;
        FIRimag_data_data : out STD_LOGIC_VECTOR (31 downto 0);

        FIRreal_data_valid : out STD_LOGIC;
        FIRreal_data_ready: in STD_LOGIC;
        FIRreal_data_data : out STD_LOGIC_VECTOR (31 downto 0);

        IQeffective                 : out STD_LOGIC_VECTOR (23 downto 0);


        FIRreal_arst_o : out STD_LOGIC;
        FIRimag_arst_o : out STD_LOGIC;
        syncDetected                        :   IN    std_logic;  -- ufix1

        -------------------------------------------
        -- Xcorr related I/O

        timer1_inSample                        :   IN    std_logic_vector(15 DOWNTO 0);
        timer2_inSample                        :   IN    std_logic_vector(15 DOWNTO 0);
        timer3_inSample                        :   IN    std_logic_vector(15 DOWNTO 0);
        timer4_inSample                        :   IN    std_logic_vector(15 DOWNTO 0);

        enableRXconf                        :   IN    std_logic_vector(4 DOWNTO 0);
        enableTXconf                        :   IN    std_logic_vector(4 DOWNTO 0);
        isTXPathConf                        :   IN    std_logic_vector(4 DOWNTO 0);
        sequenceSelConf                     :   IN    std_logic_vector(4 DOWNTO 0);

        coefReal0                           :   IN    std_logic_vector(2**log2_number_Of_FIR_coefficients*bitWidth_FIR_coefficients-1 DOWNTO 0);
        coefReal1                           :   IN    std_logic_vector(2**log2_number_Of_FIR_coefficients*bitWidth_FIR_coefficients-1 DOWNTO 0);
        coefImag0                           :   IN    std_logic_vector(2**log2_number_Of_FIR_coefficients*bitWidth_FIR_coefficients-1 DOWNTO 0);
        coefImag1                           :   IN    std_logic_vector(2**log2_number_Of_FIR_coefficients*bitWidth_FIR_coefficients-1 DOWNTO 0);


        enableRX                            :   OUT   std_logic;
        enableTX                            :   OUT   std_logic;
        isTXPath                            :   OUT   std_logic;
        sequenceSel                         :   OUT   std_logic;

        cntDetectionAsMode                  :   OUT   std_logic_vector(15 DOWNTO 0);

        clk                                 :   IN    std_logic;  -- ufix1
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


    ATTRIBUTE X_INTERFACE_INFO of FIRimag_data_data: signal is  "xilinx.com:interface:axis:1.0 FIRimag_data tdata";
    ATTRIBUTE X_INTERFACE_INFO of FIRimag_data_ready: signal is "xilinx.com:interface:axis:1.0 FIRimag_data tready";
    ATTRIBUTE X_INTERFACE_INFO of FIRimag_data_valid: signal is "xilinx.com:interface:axis:1.0 FIRimag_data tvalid";

    ATTRIBUTE X_INTERFACE_INFO of FIRreal_data_data: signal is  "xilinx.com:interface:axis:1.0 FIRreal_data tdata";
    ATTRIBUTE X_INTERFACE_INFO of FIRreal_data_ready: signal is "xilinx.com:interface:axis:1.0 FIRreal_data tready";
    ATTRIBUTE X_INTERFACE_INFO of FIRreal_data_valid: signal is "xilinx.com:interface:axis:1.0 FIRreal_data tvalid";

    ATTRIBUTE X_INTERFACE_INFO of FIRreal_reload_data: signal is  "xilinx.com:interface:axis:1.0  FIRreal_reload tdata";
    ATTRIBUTE X_INTERFACE_INFO of FIRreal_reload_ready: signal is "xilinx.com:interface:axis:1.0 FIRreal_reload tready";
    ATTRIBUTE X_INTERFACE_INFO of FIRreal_reload_valid: signal is "xilinx.com:interface:axis:1.0 FIRreal_reload tvalid";
    ATTRIBUTE X_INTERFACE_INFO of FIRreal_reload_last: signal is  "xilinx.com:interface:axis:1.0  FIRreal_reload tlast";
    ATTRIBUTE X_INTERFACE_INFO of FIRreal_config_data: signal is  "xilinx.com:interface:axis:1.0  FIRreal_config tdata";
    ATTRIBUTE X_INTERFACE_INFO of FIRreal_config_ready: signal is "xilinx.com:interface:axis:1.0 FIRreal_config tready";
    ATTRIBUTE X_INTERFACE_INFO of FIRreal_config_valid: signal is "xilinx.com:interface:axis:1.0 FIRreal_config tvalid";

    ATTRIBUTE X_INTERFACE_INFO of FIRimag_reload_data: signal is  "xilinx.com:interface:axis:1.0  FIRimag_reload tdata";
    ATTRIBUTE X_INTERFACE_INFO of FIRimag_reload_ready: signal is "xilinx.com:interface:axis:1.0 FIRimag_reload tready";
    ATTRIBUTE X_INTERFACE_INFO of FIRimag_reload_valid: signal is "xilinx.com:interface:axis:1.0 FIRimag_reload tvalid";
    ATTRIBUTE X_INTERFACE_INFO of FIRimag_reload_last: signal is  "xilinx.com:interface:axis:1.0  FIRimag_reload tlast";
    ATTRIBUTE X_INTERFACE_INFO of FIRimag_config_data: signal is  "xilinx.com:interface:axis:1.0  FIRimag_config tdata";
    ATTRIBUTE X_INTERFACE_INFO of FIRimag_config_ready: signal is "xilinx.com:interface:axis:1.0 FIRimag_config tready";
    ATTRIBUTE X_INTERFACE_INFO of FIRimag_config_valid: signal is "xilinx.com:interface:axis:1.0 FIRimag_config tvalid";




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
    
    


    -- Xcorr related signals
    signal iqConcat_r : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal FIRreal_coef : STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
    signal FIRimag_coef : STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );

    -- Timer related signals
    signal FIRreal_isConfigurationLoaded_r    : std_logic;
    signal FIRimag_isConfigurationLoaded_r    : std_logic;
    signal enableRX_r    : std_logic;
    signal enableTX_r    : std_logic;
    signal isTXPath_r    : std_logic;
    signal sequenceSel_r : std_logic;

    signal stateTimer : STD_LOGIC;
    signal selectTimer : unsigned(1 downto 0 ) := "00";
    constant timerIsIdle : STD_LOGIC := '0';
    constant timerIsRunning : STD_LOGIC := '1';

    signal counterSample : unsigned(15 downto 0 );
    signal cntDetectionAsMode_r : unsigned(15 downto 0 );
    signal timer_inSample : unsigned(15 downto 0 );


begin
    -- Controller
    -- general sample counter


    -- rx chain
    data_IQtoRAM_RX_o <= data_IQfromRF_RX_i when enableRX_r = '1' else (others => '0');
    ready_IQfromRF_RX_o <= '1' when enableRX_r = '1' else '0';
    valid_IQtoRAM_RX_o <= valid_IQfromRF_RX_i when enableRX_r = '1'  else '0';


    -- tx chain
    data_IQtoRF_TX_o  <= data_IQfromRAM_TX_i when enableTX_r = '1' else (others => '0');
    ready_IQfromRAM_TX_o <= '1' when enableTX_r = '1' else '0';
    valid_IQtoRF_TX_o <= valid_IQfromRAM_TX_i when enableTX_r = '1' else '0';
    

    -- correlator
    FIRreal_coef <= coefReal0 when sequenceSel_r = '0' else coefReal1;
    FIRimag_coef <= coefImag0 when sequenceSel_r = '0' else coefImag1;

    FIRreal_data_data <= iqConcat_r;
    FIRimag_data_data <= iqConcat_r;
    FIRreal_data_valid <= '1';
    FIRimag_data_valid <= '1';

    enableRX <= enableRX_r;
    enableTX <= enableTX_r;
    isTXPath <= isTXPath_r;
    sequenceSel <= sequenceSel_r;
    cntDetectionAsMode <= std_logic_vector(cntDetectionAsMode_r);

    correlatorMux_i: component correlatorSlicer
        Port map(
            inphase_tx_in => data_IQfromRAM_TX_i(15 downto 0),
            quadrature_tx_in => data_IQfromRAM_TX_i(31 downto 16),
            inphase_rx_in => data_IQfromRF_RX_i(15 downto 0),
            quadrature_rx_in => data_IQfromRF_RX_i(31 downto 16),
            isTXpath => isTXpath_r,
            inphase_out => open,
            quadrature_out => open,
            iqConcat_out => iqConcat_r,
            iqConcatNoPadding_out => IQeffective
        );
        
    FIRreal_i: component FIRcontroller
        Port map(
            FIR_coef_i                       => FIRreal_coef,
            FIR_isConfigurationLoaded_o      => FIRreal_isConfigurationLoaded_r,
            FIR_reload_last                  => FIRreal_reload_last,
            FIR_reload_ready                 => FIRreal_reload_ready,
            FIR_reload_valid                 => FIRreal_reload_valid,
            FIR_reload_data                  => FIRreal_reload_data,
            FIR_config_ready                 => FIRreal_config_ready,
            FIR_config_valid                 => FIRreal_config_valid,
            FIR_config_data                  => FIRreal_config_data,
            FIR_arst_o                       => FIRreal_arst_o,
            clk                              => clk,                       
            arstn                            => arstn 
        );
        
    FIRimag_i: component FIRcontroller
        Port map(
            FIR_coef_i                       => FIRimag_coef,
            FIR_isConfigurationLoaded_o      => FIRimag_isConfigurationLoaded_r,
            FIR_reload_last                  => FIRimag_reload_last,
            FIR_reload_ready                 => FIRimag_reload_ready,
            FIR_reload_valid                 => FIRimag_reload_valid,
            FIR_reload_data                  => FIRimag_reload_data,
            FIR_config_ready                 => FIRimag_config_ready,
            FIR_config_valid                 => FIRimag_config_valid,
            FIR_config_data                  => FIRimag_config_data,
            FIR_arst_o                       => FIRimag_arst_o,
            clk                              => clk,                       
            arstn                            => arstn 
        );        

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
    process (selectTimer,stateTimer,enableRXconf,enableTXconf,isTXPathConf,sequenceSelConf)  begin
        case stateTimer & selectTimer  is
            when timerIsRunning & "00" =>
                enableRX_r    <= enableRXconf(4);
                enableTX_r    <= enableTXconf(4);
                isTXPath_r    <= isTXPathConf(4);
                sequenceSel_r <= sequenceSelConf(4);
            when timerIsRunning & "01" =>
                enableRX_r    <= enableRXconf(1);
                enableTX_r    <= enableTXconf(1);
                isTXPath_r    <= isTXPathConf(1);
                sequenceSel_r <= sequenceSelConf(1);
            when timerIsRunning & "10" =>
                enableRX_r    <= enableRXconf(2);
                enableTX_r    <= enableTXconf(2);
                isTXPath_r    <= isTXPathConf(2);
                sequenceSel_r <= sequenceSelConf(2);
            when timerIsRunning & "11" =>
                enableRX_r    <= enableRXconf(3);
                enableTX_r    <= enableTXconf(3);
                isTXPath_r    <= isTXPathConf(3);
                sequenceSel_r <= sequenceSelConf(3);
            when others =>
                enableRX_r    <= enableRXconf(0);
                enableTX_r    <= enableTXconf(0);
                isTXPath_r    <= isTXPathConf(0);
                sequenceSel_r <= sequenceSelConf(0);
        end case;
    end process;

end Behavioral;


