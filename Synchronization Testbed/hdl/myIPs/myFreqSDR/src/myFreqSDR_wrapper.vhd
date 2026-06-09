--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
--Date        : Sat Jul  5 14:03:17 2025
--Host        : ORION running 64-bit major release  (build 9200)
--Command     : generate_target myFreqSDR_wrapper.bd
--Design      : myFreqSDR_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity myFreqSDR_wrapper is
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
    clk : in STD_LOGIC;
    info_cntDetection : out STD_LOGIC_VECTOR ( 15 downto 0 );
    info_enableRX : out STD_LOGIC;
    info_enableTX : out STD_LOGIC;
    info_fifoRX_count : out STD_LOGIC_VECTOR ( 14 downto 0 );
    info_isTXPath : out STD_LOGIC;
    info_overflow : out STD_LOGIC;
    info_sequenceSel : out STD_LOGIC;
    params_coefImag0 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    params_coefImag1 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    params_coefReal0 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    params_coefReal1 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    params_enableRXConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_enableTXConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_isTXPathConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_sequenceSelConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    params_timer1_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    params_timer2_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    params_timer3_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    params_timer4_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 )
  );
end myFreqSDR_wrapper;

architecture STRUCTURE of myFreqSDR_wrapper is
  component myFreqSDR is
  port (
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
    info_cntDetection : out STD_LOGIC_VECTOR ( 15 downto 0 );
    info_enableRX : out STD_LOGIC;
    info_enableTX : out STD_LOGIC;
    info_isTXPath : out STD_LOGIC;
    info_sequenceSel : out STD_LOGIC;
    params_coefReal0 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    params_coefReal1 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    params_coefImag0 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    params_coefImag1 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    info_fifoRX_count : out STD_LOGIC_VECTOR ( 14 downto 0 );
    IQtoRAM_RX_m_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    IQtoRAM_RX_m_tready : in STD_LOGIC;
    IQtoRAM_RX_m_tvalid : out STD_LOGIC;
    IQfromRAM_TX_s_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    IQfromRAM_TX_s_tvalid : in STD_LOGIC;
    IQfromRAM_TX_s_tready : out STD_LOGIC;
    IQfromRF_RX_s_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    IQfromRF_RX_s_tvalid : in STD_LOGIC;
    IQfromRF_RX_s_tready : out STD_LOGIC;
    IQtoRF_TX_m_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    IQtoRF_TX_m_tvalid : out STD_LOGIC;
    info_overflow : out STD_LOGIC
  );
  end component myFreqSDR;
begin
myFreqSDR_i: component myFreqSDR
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
      clk => clk,
      info_cntDetection(15 downto 0) => info_cntDetection(15 downto 0),
      info_enableRX => info_enableRX,
      info_enableTX => info_enableTX,
      info_fifoRX_count(14 downto 0) => info_fifoRX_count(14 downto 0),
      info_isTXPath => info_isTXPath,
      info_overflow => info_overflow,
      info_sequenceSel => info_sequenceSel,
      params_coefImag0(95 downto 0) => params_coefImag0(95 downto 0),
      params_coefImag1(95 downto 0) => params_coefImag1(95 downto 0),
      params_coefReal0(95 downto 0) => params_coefReal0(95 downto 0),
      params_coefReal1(95 downto 0) => params_coefReal1(95 downto 0),
      params_enableRXConf(4 downto 0) => params_enableRXConf(4 downto 0),
      params_enableTXConf(4 downto 0) => params_enableTXConf(4 downto 0),
      params_isTXPathConf(4 downto 0) => params_isTXPathConf(4 downto 0),
      params_sequenceSelConf(4 downto 0) => params_sequenceSelConf(4 downto 0),
      params_timer1_inSample(15 downto 0) => params_timer1_inSample(15 downto 0),
      params_timer2_inSample(15 downto 0) => params_timer2_inSample(15 downto 0),
      params_timer3_inSample(15 downto 0) => params_timer3_inSample(15 downto 0),
      params_timer4_inSample(15 downto 0) => params_timer4_inSample(15 downto 0)
    );
end STRUCTURE;
