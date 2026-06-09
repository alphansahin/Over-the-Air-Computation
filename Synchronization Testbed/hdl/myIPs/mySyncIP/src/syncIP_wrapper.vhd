--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
--Date        : Wed Nov 26 13:32:15 2025
--Host        : ORION running 64-bit major release  (build 9200)
--Command     : generate_target syncIP_wrapper.bd
--Design      : syncIP_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity syncIP_wrapper is
  port (
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
    arstn : in STD_LOGIC;
    arstn_fast : in STD_LOGIC;
    clk : in STD_LOGIC;
    clk_fast : in STD_LOGIC;
    params_FIRcoef_addr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    params_FIRcoef_imagValues_rd : out STD_LOGIC_VECTOR ( 31 downto 0 );
    params_FIRcoef_imagValues_wr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    params_FIRcoef_realValues_rd : out STD_LOGIC_VECTOR ( 31 downto 0 );
    params_FIRcoef_realValues_wr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    params_FIRcoef_wr : in STD_LOGIC;
    params_addPhaseBiasConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_enablePhaseCorrConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_enablePhaseEstConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_enableRXConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_enableTXConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_isConjugatedConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_isTXPathConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_numeratorkPhase : in STD_LOGIC_VECTOR ( 26 downto 0 );
    params_sequenceSelConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_timer1_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    params_timer2_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    params_timer3_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    params_timer4_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    rxFIFO_overflow : out STD_LOGIC;
    status_myController : out STD_LOGIC_VECTOR ( 63 downto 0 );
    status_myDetector : out STD_LOGIC_VECTOR ( 351 downto 0 );
    status_myPhaseEstimation : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
end syncIP_wrapper;

architecture STRUCTURE of syncIP_wrapper is
  component syncIP is
  port (
    IQfromRF_RX_s_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    IQfromRF_RX_s_tvalid : in STD_LOGIC;
    IQfromRF_RX_s_tready : out STD_LOGIC;
    IQfromRAM_TX_s_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    IQfromRAM_TX_s_tvalid : in STD_LOGIC;
    IQfromRAM_TX_s_tready : out STD_LOGIC;
    IQtoRAM_RX_m_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    IQtoRAM_RX_m_tready : in STD_LOGIC;
    IQtoRAM_RX_m_tvalid : out STD_LOGIC;
    IQtoRF_TX_m_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    IQtoRF_TX_m_tvalid : out STD_LOGIC;
    params_enableRXConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_enableTXConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_isTXPathConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_sequenceSelConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_timer1_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    clk : in STD_LOGIC;
    params_timer2_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    params_timer3_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    params_timer4_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    arstn : in STD_LOGIC;
    rxFIFO_overflow : out STD_LOGIC;
    params_enablePhaseEstConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_enablePhaseCorrConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_isConjugatedConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_addPhaseBiasConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_numeratorkPhase : in STD_LOGIC_VECTOR ( 26 downto 0 );
    clk_fast : in STD_LOGIC;
    arstn_fast : in STD_LOGIC;
    params_FIRcoef_imagValues_rd : out STD_LOGIC_VECTOR ( 31 downto 0 );
    params_FIRcoef_imagValues_wr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    params_FIRcoef_realValues_rd : out STD_LOGIC_VECTOR ( 31 downto 0 );
    params_FIRcoef_realValues_wr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    params_FIRcoef_wr : in STD_LOGIC;
    params_FIRcoef_addr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    status_myDetector : out STD_LOGIC_VECTOR ( 351 downto 0 );
    status_myController : out STD_LOGIC_VECTOR ( 63 downto 0 );
    status_myPhaseEstimation : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component syncIP;
begin
syncIP_i: component syncIP
     port map (
      IQfromRAM_TX_s_tdata(31 downto 0) => IQfromRAM_TX_s_tdata(31 downto 0),
      IQfromRAM_TX_s_tready => IQfromRAM_TX_s_tready,
      IQfromRAM_TX_s_tvalid => IQfromRAM_TX_s_tvalid,
      IQfromRF_RX_s_tdata(31 downto 0) => IQfromRF_RX_s_tdata(31 downto 0),
      IQfromRF_RX_s_tready => IQfromRF_RX_s_tready,
      IQfromRF_RX_s_tvalid => IQfromRF_RX_s_tvalid,
      IQtoRAM_RX_m_tdata(31 downto 0) => IQtoRAM_RX_m_tdata(31 downto 0),
      IQtoRAM_RX_m_tready => IQtoRAM_RX_m_tready,
      IQtoRAM_RX_m_tvalid => IQtoRAM_RX_m_tvalid,
      IQtoRF_TX_m_tdata(31 downto 0) => IQtoRF_TX_m_tdata(31 downto 0),
      IQtoRF_TX_m_tvalid => IQtoRF_TX_m_tvalid,
      arstn => arstn,
      arstn_fast => arstn_fast,
      clk => clk,
      clk_fast => clk_fast,
      params_FIRcoef_addr(31 downto 0) => params_FIRcoef_addr(31 downto 0),
      params_FIRcoef_imagValues_rd(31 downto 0) => params_FIRcoef_imagValues_rd(31 downto 0),
      params_FIRcoef_imagValues_wr(31 downto 0) => params_FIRcoef_imagValues_wr(31 downto 0),
      params_FIRcoef_realValues_rd(31 downto 0) => params_FIRcoef_realValues_rd(31 downto 0),
      params_FIRcoef_realValues_wr(31 downto 0) => params_FIRcoef_realValues_wr(31 downto 0),
      params_FIRcoef_wr => params_FIRcoef_wr,
      params_addPhaseBiasConf(4 downto 0) => params_addPhaseBiasConf(4 downto 0),
      params_enablePhaseCorrConf(4 downto 0) => params_enablePhaseCorrConf(4 downto 0),
      params_enablePhaseEstConf(4 downto 0) => params_enablePhaseEstConf(4 downto 0),
      params_enableRXConf(4 downto 0) => params_enableRXConf(4 downto 0),
      params_enableTXConf(4 downto 0) => params_enableTXConf(4 downto 0),
      params_isConjugatedConf(4 downto 0) => params_isConjugatedConf(4 downto 0),
      params_isTXPathConf(4 downto 0) => params_isTXPathConf(4 downto 0),
      params_numeratorkPhase(26 downto 0) => params_numeratorkPhase(26 downto 0),
      params_sequenceSelConf(4 downto 0) => params_sequenceSelConf(4 downto 0),
      params_timer1_inSample(15 downto 0) => params_timer1_inSample(15 downto 0),
      params_timer2_inSample(15 downto 0) => params_timer2_inSample(15 downto 0),
      params_timer3_inSample(15 downto 0) => params_timer3_inSample(15 downto 0),
      params_timer4_inSample(15 downto 0) => params_timer4_inSample(15 downto 0),
      rxFIFO_overflow => rxFIFO_overflow,
      status_myController(63 downto 0) => status_myController(63 downto 0),
      status_myDetector(351 downto 0) => status_myDetector(351 downto 0),
      status_myPhaseEstimation(31 downto 0) => status_myPhaseEstimation(31 downto 0)
    );
end STRUCTURE;
