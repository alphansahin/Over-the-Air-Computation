--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
--Date        : Sat Jul  5 14:03:17 2025
--Host        : ORION running 64-bit major release  (build 9200)
--Command     : generate_target myFreqSDR.bd
--Design      : myFreqSDR
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity correlator_imp_1JLS5UE is
  port (
    FIRimag_arst : in STD_LOGIC;
    FIRimag_config_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    FIRimag_config_tready : out STD_LOGIC;
    FIRimag_config_tvalid : in STD_LOGIC;
    FIRimag_data_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    FIRimag_data_tready : out STD_LOGIC;
    FIRimag_data_tvalid : in STD_LOGIC;
    FIRimag_reload_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    FIRimag_reload_tlast : in STD_LOGIC;
    FIRimag_reload_tready : out STD_LOGIC;
    FIRimag_reload_tvalid : in STD_LOGIC;
    FIRreal_arst : in STD_LOGIC;
    FIRreal_config_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    FIRreal_config_tready : out STD_LOGIC;
    FIRreal_config_tvalid : in STD_LOGIC;
    FIRreal_data_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    FIRreal_data_tready : out STD_LOGIC;
    FIRreal_data_tvalid : in STD_LOGIC;
    FIRreal_reload_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    FIRreal_reload_tlast : in STD_LOGIC;
    FIRreal_reload_tready : out STD_LOGIC;
    FIRreal_reload_tvalid : in STD_LOGIC;
    IQeffective : in STD_LOGIC_VECTOR ( 23 downto 0 );
    arstn : in STD_LOGIC;
    clk : in STD_LOGIC;
    detectedRepeat : out STD_LOGIC
  );
end correlator_imp_1JLS5UE;

architecture STRUCTURE of correlator_imp_1JLS5UE is
  component myFreqSDR_fir_compiler_0_0 is
  port (
    aresetn : in STD_LOGIC;
    aclk : in STD_LOGIC;
    s_axis_data_tvalid : in STD_LOGIC;
    s_axis_data_tready : out STD_LOGIC;
    s_axis_data_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_config_tvalid : in STD_LOGIC;
    s_axis_config_tready : out STD_LOGIC;
    s_axis_config_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_reload_tvalid : in STD_LOGIC;
    s_axis_reload_tready : out STD_LOGIC;
    s_axis_reload_tlast : in STD_LOGIC;
    s_axis_reload_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 47 downto 0 );
    event_s_reload_tlast_missing : out STD_LOGIC;
    event_s_reload_tlast_unexpected : out STD_LOGIC
  );
  end component myFreqSDR_fir_compiler_0_0;
  component myFreqSDR_fir_compiler_0_1 is
  port (
    aresetn : in STD_LOGIC;
    aclk : in STD_LOGIC;
    s_axis_data_tvalid : in STD_LOGIC;
    s_axis_data_tready : out STD_LOGIC;
    s_axis_data_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_config_tvalid : in STD_LOGIC;
    s_axis_config_tready : out STD_LOGIC;
    s_axis_config_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_reload_tvalid : in STD_LOGIC;
    s_axis_reload_tready : out STD_LOGIC;
    s_axis_reload_tlast : in STD_LOGIC;
    s_axis_reload_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 47 downto 0 );
    event_s_reload_tlast_missing : out STD_LOGIC;
    event_s_reload_tlast_unexpected : out STD_LOGIC
  );
  end component myFreqSDR_fir_compiler_0_1;
  component myFreqSDR_c_addsub_0_3 is
  port (
    A : in STD_LOGIC_VECTOR ( 21 downto 0 );
    B : in STD_LOGIC_VECTOR ( 21 downto 0 );
    CLK : in STD_LOGIC;
    S : out STD_LOGIC_VECTOR ( 22 downto 0 )
  );
  end component myFreqSDR_c_addsub_0_3;
  component myFreqSDR_c_addsub_0_4 is
  port (
    A : in STD_LOGIC_VECTOR ( 21 downto 0 );
    B : in STD_LOGIC_VECTOR ( 21 downto 0 );
    CLK : in STD_LOGIC;
    S : out STD_LOGIC_VECTOR ( 22 downto 0 )
  );
  end component myFreqSDR_c_addsub_0_4;
  component myFreqSDR_c_shift_ram_0_0 is
  port (
    D : in STD_LOGIC_VECTOR ( 23 downto 0 );
    CLK : in STD_LOGIC;
    CE : in STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 23 downto 0 )
  );
  end component myFreqSDR_c_shift_ram_0_0;
  component myFreqSDR_basicSlicer_0_0 is
  port (
    data_in : in STD_LOGIC_VECTOR ( 23 downto 0 );
    dataOut1 : out STD_LOGIC_VECTOR ( 11 downto 0 );
    dataOut2 : out STD_LOGIC_VECTOR ( 11 downto 0 )
  );
  end component myFreqSDR_basicSlicer_0_0;
  component myFreqSDR_getIQback_0 is
  port (
    data_in : in STD_LOGIC_VECTOR ( 47 downto 0 );
    dataOut1 : out STD_LOGIC_VECTOR ( 21 downto 0 );
    dataOut2 : out STD_LOGIC_VECTOR ( 21 downto 0 )
  );
  end component myFreqSDR_getIQback_0;
  component myFreqSDR_FIRreal_slicer_0 is
  port (
    data_in : in STD_LOGIC_VECTOR ( 47 downto 0 );
    dataOut1 : out STD_LOGIC_VECTOR ( 21 downto 0 );
    dataOut2 : out STD_LOGIC_VECTOR ( 21 downto 0 )
  );
  end component myFreqSDR_FIRreal_slicer_0;
  component myFreqSDR_moving_sum_0_0 is
  port (
    dataIn : in STD_LOGIC_VECTOR ( 23 downto 0 );
    enable : in STD_LOGIC;
    dataOut : out STD_LOGIC_VECTOR ( 27 downto 0 );
    clk : in STD_LOGIC;
    arstn : in STD_LOGIC
  );
  end component myFreqSDR_moving_sum_0_0;
  component myFreqSDR_normSquare_0_0 is
  port (
    real_signed_i : in STD_LOGIC_VECTOR ( 22 downto 0 );
    imag_signed_i : in STD_LOGIC_VECTOR ( 22 downto 0 );
    norm_unsigned_o : out STD_LOGIC_VECTOR ( 45 downto 0 );
    clk : in STD_LOGIC;
    arstn : in STD_LOGIC
  );
  end component myFreqSDR_normSquare_0_0;
  component myFreqSDR_normSquare_0_1 is
  port (
    real_signed_i : in STD_LOGIC_VECTOR ( 11 downto 0 );
    imag_signed_i : in STD_LOGIC_VECTOR ( 11 downto 0 );
    norm_unsigned_o : out STD_LOGIC_VECTOR ( 23 downto 0 );
    clk : in STD_LOGIC;
    arstn : in STD_LOGIC
  );
  end component myFreqSDR_normSquare_0_1;
  component myFreqSDR_delayIQdataByX_0 is
  port (
    D : in STD_LOGIC_VECTOR ( 0 to 0 );
    CLK : in STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component myFreqSDR_delayIQdataByX_0;
  component myFreqSDR_xlconstant_0_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component myFreqSDR_xlconstant_0_0;
  component myFreqSDR_detectorXcorr_0_0 is
  port (
    xcorrSquare_in : in STD_LOGIC_VECTOR ( 45 downto 0 );
    normSquare_in : in STD_LOGIC_VECTOR ( 27 downto 0 );
    detectedRepeat : out STD_LOGIC;
    clk : in STD_LOGIC;
    enable : in STD_LOGIC;
    arstn : in STD_LOGIC
  );
  end component myFreqSDR_detectorXcorr_0_0;
  signal Conn1_TDATA : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal Conn1_TLAST : STD_LOGIC;
  signal Conn1_TREADY : STD_LOGIC;
  signal Conn1_TVALID : STD_LOGIC;
  signal Conn2_TDATA : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal Conn2_TREADY : STD_LOGIC;
  signal Conn2_TVALID : STD_LOGIC;
  signal Conn3_TDATA : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal Conn3_TLAST : STD_LOGIC;
  signal Conn3_TREADY : STD_LOGIC;
  signal Conn3_TVALID : STD_LOGIC;
  signal Conn4_TDATA : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal Conn4_TREADY : STD_LOGIC;
  signal Conn4_TVALID : STD_LOGIC;
  signal Conn5_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Conn5_TREADY : STD_LOGIC;
  signal Conn5_TVALID : STD_LOGIC;
  signal Conn6_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Conn6_TREADY : STD_LOGIC;
  signal Conn6_TVALID : STD_LOGIC;
  signal D_1 : STD_LOGIC_VECTOR ( 23 downto 0 );
  signal FIRimag_slicer_dataOut1 : STD_LOGIC_VECTOR ( 21 downto 0 );
  signal FIRimag_slicer_dataOut2 : STD_LOGIC_VECTOR ( 21 downto 0 );
  signal FIRreal_slicer1_dataOut1 : STD_LOGIC_VECTOR ( 21 downto 0 );
  signal FIRreal_slicer1_dataOut2 : STD_LOGIC_VECTOR ( 21 downto 0 );
  signal Net1 : STD_LOGIC_VECTOR ( 22 downto 0 );
  signal Net2 : STD_LOGIC_VECTOR ( 22 downto 0 );
  signal aresetn1_1 : STD_LOGIC;
  signal aresetn_1 : STD_LOGIC;
  signal arstn_1 : STD_LOGIC;
  signal basicSlicer_0_dataOut1 : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal basicSlicer_0_dataOut2 : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal c_shift_ram_0_Q : STD_LOGIC_VECTOR ( 23 downto 0 );
  signal clk_1 : STD_LOGIC;
  signal correlatorSlicer_0_valid_out1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal delayIQdataByX1_Q : STD_LOGIC_VECTOR ( 0 to 0 );
  signal detectorXcorr_0_detectedRepeat : STD_LOGIC;
  signal fir_imag_m_axis_data_tdata : STD_LOGIC_VECTOR ( 47 downto 0 );
  signal fir_imag_m_axis_data_tvalid : STD_LOGIC;
  signal fir_real_m_axis_data_tdata : STD_LOGIC_VECTOR ( 47 downto 0 );
  signal moving_sum_0_dataOut : STD_LOGIC_VECTOR ( 27 downto 0 );
  signal normSquare_0_norm_o : STD_LOGIC_VECTOR ( 45 downto 0 );
  signal normSquare_1_norm_o : STD_LOGIC_VECTOR ( 23 downto 0 );
  signal NLW_fir_imag_event_s_reload_tlast_missing_UNCONNECTED : STD_LOGIC;
  signal NLW_fir_imag_event_s_reload_tlast_unexpected_UNCONNECTED : STD_LOGIC;
  signal NLW_fir_real_event_s_reload_tlast_missing_UNCONNECTED : STD_LOGIC;
  signal NLW_fir_real_event_s_reload_tlast_unexpected_UNCONNECTED : STD_LOGIC;
  signal NLW_fir_real_m_axis_data_tvalid_UNCONNECTED : STD_LOGIC;
begin
  Conn1_TDATA(7 downto 0) <= FIRimag_reload_tdata(7 downto 0);
  Conn1_TLAST <= FIRimag_reload_tlast;
  Conn1_TVALID <= FIRimag_reload_tvalid;
  Conn2_TDATA(7 downto 0) <= FIRimag_config_tdata(7 downto 0);
  Conn2_TVALID <= FIRimag_config_tvalid;
  Conn3_TDATA(7 downto 0) <= FIRreal_reload_tdata(7 downto 0);
  Conn3_TLAST <= FIRreal_reload_tlast;
  Conn3_TVALID <= FIRreal_reload_tvalid;
  Conn4_TDATA(7 downto 0) <= FIRreal_config_tdata(7 downto 0);
  Conn4_TVALID <= FIRreal_config_tvalid;
  Conn5_TDATA(31 downto 0) <= FIRimag_data_tdata(31 downto 0);
  Conn5_TVALID <= FIRimag_data_tvalid;
  Conn6_TDATA(31 downto 0) <= FIRreal_data_tdata(31 downto 0);
  Conn6_TVALID <= FIRreal_data_tvalid;
  D_1(23 downto 0) <= IQeffective(23 downto 0);
  FIRimag_config_tready <= Conn2_TREADY;
  FIRimag_data_tready <= Conn5_TREADY;
  FIRimag_reload_tready <= Conn1_TREADY;
  FIRreal_config_tready <= Conn4_TREADY;
  FIRreal_data_tready <= Conn6_TREADY;
  FIRreal_reload_tready <= Conn3_TREADY;
  aresetn1_1 <= FIRimag_arst;
  aresetn_1 <= FIRreal_arst;
  arstn_1 <= arstn;
  clk_1 <= clk;
  detectedRepeat <= detectorXcorr_0_detectedRepeat;
FIRimag_slicer: component myFreqSDR_getIQback_0
     port map (
      dataOut1(21 downto 0) => FIRimag_slicer_dataOut1(21 downto 0),
      dataOut2(21 downto 0) => FIRimag_slicer_dataOut2(21 downto 0),
      data_in(47 downto 0) => fir_imag_m_axis_data_tdata(47 downto 0)
    );
FIRreal_slicer: component myFreqSDR_FIRreal_slicer_0
     port map (
      dataOut1(21 downto 0) => FIRreal_slicer1_dataOut1(21 downto 0),
      dataOut2(21 downto 0) => FIRreal_slicer1_dataOut2(21 downto 0),
      data_in(47 downto 0) => fir_real_m_axis_data_tdata(47 downto 0)
    );
-- Delay: lengthFIR-1
  -- jj
  delayIQdataBy15: component myFreqSDR_c_shift_ram_0_0
     port map (
      CE => correlatorSlicer_0_valid_out1(0),
      CLK => clk_1,
      D(23 downto 0) => D_1(23 downto 0),
      Q(23 downto 0) => c_shift_ram_0_Q(23 downto 0)
    );
delayIQdataBy3: component myFreqSDR_delayIQdataByX_0
     port map (
      CLK => clk_1,
      D(0) => fir_imag_m_axis_data_tvalid,
      Q(0) => delayIQdataByX1_Q(0)
    );
detectorXcorr_0: component myFreqSDR_detectorXcorr_0_0
     port map (
      arstn => arstn_1,
      clk => clk_1,
      detectedRepeat => detectorXcorr_0_detectedRepeat,
      enable => delayIQdataByX1_Q(0),
      normSquare_in(27 downto 0) => moving_sum_0_dataOut(27 downto 0),
      xcorrSquare_in(45 downto 0) => normSquare_0_norm_o(45 downto 0)
    );
enableCorrelator: component myFreqSDR_xlconstant_0_0
     port map (
      dout(0) => correlatorSlicer_0_valid_out1(0)
    );
-- BitWidth for each paralel filter: lengthFIR=16,bitWidthFIRin=12,bitWidthFIRcoefBits=6
  -- bitWidthFIRout = bitWidthFIRin+bitWidthFIRcoefBits+log2(lengthFIR) = 22 bits 
  -- BitWidth for each paralel filter: lengthFIR=16,bitWidthFIRin=12,bitWidthFIRcoefBits=6
  -- bitWidthFIRout = bitWidthFIRin+bitWidthFIRcoefBits+log2(lengthFIR) = 22 bits 
  -- BitWidth for each paralel filter: lengthFIR=16,bitWidthFIRin=12,bitWidthFIRcoefBits=6
  -- bitWidthFIRout = bitWidthFIRin+bitWidthFIRcoefBits+log2(lengthFIR) = 22 bits 
  fir_imag: component myFreqSDR_fir_compiler_0_1
     port map (
      aclk => clk_1,
      aresetn => aresetn_1,
      event_s_reload_tlast_missing => NLW_fir_imag_event_s_reload_tlast_missing_UNCONNECTED,
      event_s_reload_tlast_unexpected => NLW_fir_imag_event_s_reload_tlast_unexpected_UNCONNECTED,
      m_axis_data_tdata(47 downto 0) => fir_imag_m_axis_data_tdata(47 downto 0),
      m_axis_data_tvalid => fir_imag_m_axis_data_tvalid,
      s_axis_config_tdata(7 downto 0) => Conn2_TDATA(7 downto 0),
      s_axis_config_tready => Conn2_TREADY,
      s_axis_config_tvalid => Conn2_TVALID,
      s_axis_data_tdata(31 downto 0) => Conn5_TDATA(31 downto 0),
      s_axis_data_tready => Conn5_TREADY,
      s_axis_data_tvalid => Conn5_TVALID,
      s_axis_reload_tdata(7 downto 0) => Conn1_TDATA(7 downto 0),
      s_axis_reload_tlast => Conn1_TLAST,
      s_axis_reload_tready => Conn1_TREADY,
      s_axis_reload_tvalid => Conn1_TVALID
    );
fir_real: component myFreqSDR_fir_compiler_0_0
     port map (
      aclk => clk_1,
      aresetn => aresetn1_1,
      event_s_reload_tlast_missing => NLW_fir_real_event_s_reload_tlast_missing_UNCONNECTED,
      event_s_reload_tlast_unexpected => NLW_fir_real_event_s_reload_tlast_unexpected_UNCONNECTED,
      m_axis_data_tdata(47 downto 0) => fir_real_m_axis_data_tdata(47 downto 0),
      m_axis_data_tvalid => NLW_fir_real_m_axis_data_tvalid_UNCONNECTED,
      s_axis_config_tdata(7 downto 0) => Conn4_TDATA(7 downto 0),
      s_axis_config_tready => Conn4_TREADY,
      s_axis_config_tvalid => Conn4_TVALID,
      s_axis_data_tdata(31 downto 0) => Conn6_TDATA(31 downto 0),
      s_axis_data_tready => Conn6_TREADY,
      s_axis_data_tvalid => Conn6_TVALID,
      s_axis_reload_tdata(7 downto 0) => Conn3_TDATA(7 downto 0),
      s_axis_reload_tlast => Conn3_TLAST,
      s_axis_reload_tready => Conn3_TREADY,
      s_axis_reload_tvalid => Conn3_TVALID
    );
getIQback: component myFreqSDR_basicSlicer_0_0
     port map (
      dataOut1(11 downto 0) => basicSlicer_0_dataOut1(11 downto 0),
      dataOut2(11 downto 0) => basicSlicer_0_dataOut2(11 downto 0),
      data_in(23 downto 0) => c_shift_ram_0_Q(23 downto 0)
    );
-- bitWidthFIRout+1=23 bits
  -- jj
  imag_add: component myFreqSDR_c_addsub_0_3
     port map (
      A(21 downto 0) => FIRreal_slicer1_dataOut2(21 downto 0),
      B(21 downto 0) => FIRimag_slicer_dataOut1(21 downto 0),
      CLK => clk_1,
      S(22 downto 0) => Net1(22 downto 0)
    );
-- 2*bitWidthFIRin+log2(lengthFIR)=28 bits
  -- Enter Comments here
  moving_sum_0: component myFreqSDR_moving_sum_0_0
     port map (
      arstn => arstn_1,
      clk => clk_1,
      dataIn(23 downto 0) => normSquare_1_norm_o(23 downto 0),
      dataOut(27 downto 0) => moving_sum_0_dataOut(27 downto 0),
      enable => correlatorSlicer_0_valid_out1(0)
    );
-- 2(bitWidthFIRout+1)
  -- Enter Comments here
  normSquare_0: component myFreqSDR_normSquare_0_0
     port map (
      arstn => arstn_1,
      clk => clk_1,
      imag_signed_i(22 downto 0) => Net1(22 downto 0),
      norm_unsigned_o(45 downto 0) => normSquare_0_norm_o(45 downto 0),
      real_signed_i(22 downto 0) => Net2(22 downto 0)
    );
-- 2*bitWidthFIRin=24 bits
  -- Enter Comments here
  normSquare_1: component myFreqSDR_normSquare_0_1
     port map (
      arstn => arstn_1,
      clk => clk_1,
      imag_signed_i(11 downto 0) => basicSlicer_0_dataOut2(11 downto 0),
      norm_unsigned_o(23 downto 0) => normSquare_1_norm_o(23 downto 0),
      real_signed_i(11 downto 0) => basicSlicer_0_dataOut1(11 downto 0)
    );
-- bitWidthFIRout+1=23 bits
  -- bitWidthFIRout+1=23 bits
  real_sub: component myFreqSDR_c_addsub_0_4
     port map (
      A(21 downto 0) => FIRreal_slicer1_dataOut1(21 downto 0),
      B(21 downto 0) => FIRimag_slicer_dataOut2(21 downto 0),
      CLK => clk_1,
      S(22 downto 0) => Net2(22 downto 0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity myFreqSDR is
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
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of myFreqSDR : entity is "myFreqSDR,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=myFreqSDR,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=17,numReposBlks=16,numNonXlnxBlks=0,numHierBlks=1,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=8,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of myFreqSDR : entity is "myFreqSDR.hwdef";
end myFreqSDR;

architecture STRUCTURE of myFreqSDR is
  component myFreqSDR_sdrController_0_0 is
  port (
    data_IQfromRF_RX_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
    valid_IQfromRF_RX_i : in STD_LOGIC;
    ready_IQfromRF_RX_o : out STD_LOGIC;
    data_IQtoRAM_RX_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    valid_IQtoRAM_RX_o : out STD_LOGIC;
    data_IQfromRAM_TX_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
    valid_IQfromRAM_TX_i : in STD_LOGIC;
    ready_IQfromRAM_TX_o : out STD_LOGIC;
    data_IQtoRF_TX_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    valid_IQtoRF_TX_o : out STD_LOGIC;
    FIRimag_reload_last : out STD_LOGIC;
    FIRimag_reload_ready : in STD_LOGIC;
    FIRimag_reload_valid : out STD_LOGIC;
    FIRimag_reload_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    FIRimag_config_ready : in STD_LOGIC;
    FIRimag_config_valid : out STD_LOGIC;
    FIRimag_config_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    FIRreal_reload_last : out STD_LOGIC;
    FIRreal_reload_ready : in STD_LOGIC;
    FIRreal_reload_valid : out STD_LOGIC;
    FIRreal_reload_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    FIRreal_config_ready : in STD_LOGIC;
    FIRreal_config_valid : out STD_LOGIC;
    FIRreal_config_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    FIRimag_data_valid : out STD_LOGIC;
    FIRimag_data_ready : in STD_LOGIC;
    FIRimag_data_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    FIRreal_data_valid : out STD_LOGIC;
    FIRreal_data_ready : in STD_LOGIC;
    FIRreal_data_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    IQeffective : out STD_LOGIC_VECTOR ( 23 downto 0 );
    FIRreal_arst_o : out STD_LOGIC;
    FIRimag_arst_o : out STD_LOGIC;
    syncDetected : in STD_LOGIC;
    timer1_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    timer2_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    timer3_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    timer4_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    enableRXconf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    enableTXconf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    isTXPathConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    sequenceSelConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    coefReal0 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    coefReal1 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    coefImag0 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    coefImag1 : in STD_LOGIC_VECTOR ( 95 downto 0 );
    enableRX : out STD_LOGIC;
    enableTX : out STD_LOGIC;
    isTXPath : out STD_LOGIC;
    sequenceSel : out STD_LOGIC;
    cntDetectionAsMode : out STD_LOGIC_VECTOR ( 15 downto 0 );
    clk : in STD_LOGIC;
    arstn : in STD_LOGIC
  );
  end component myFreqSDR_sdrController_0_0;
  component myFreqSDR_fifo_generator_0_0 is
  port (
    wr_rst_busy : out STD_LOGIC;
    rd_rst_busy : out STD_LOGIC;
    s_aclk : in STD_LOGIC;
    s_aresetn : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axis_data_count : out STD_LOGIC_VECTOR ( 14 downto 0 );
    axis_overflow : out STD_LOGIC
  );
  end component myFreqSDR_fifo_generator_0_0;
  signal D_1 : STD_LOGIC_VECTOR ( 23 downto 0 );
  signal arstn_1 : STD_LOGIC;
  signal clk_1 : STD_LOGIC;
  signal correlator_detectedRepeat : STD_LOGIC;
  signal largeRXBuffer_M_AXIS_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal largeRXBuffer_M_AXIS_TREADY : STD_LOGIC;
  signal largeRXBuffer_M_AXIS_TVALID : STD_LOGIC;
  signal largeRXBuffer_axis_data_count : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal largeRXBuffer_axis_overflow : STD_LOGIC;
  signal params_coefReal0n1_1 : STD_LOGIC_VECTOR ( 95 downto 0 );
  signal params_coefReal0n2_1 : STD_LOGIC_VECTOR ( 95 downto 0 );
  signal params_coefReal0n3_1 : STD_LOGIC_VECTOR ( 95 downto 0 );
  signal params_coefReal0n_1 : STD_LOGIC_VECTOR ( 95 downto 0 );
  signal params_enableRXConf_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_enableTXConf_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_isTXPathConf_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_sequenceSelConf_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_timer1_Nofdm_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal params_timer2_Nofdm_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal params_timer3_Nofdm_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal params_timer4_Nofdm_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal s_axis_dataFreqTX_1_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s_axis_dataFreqTX_1_TREADY : STD_LOGIC;
  signal s_axis_dataFreqTX_1_TVALID : STD_LOGIC;
  signal s_axis_dataTimeRX_1_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s_axis_dataTimeRX_1_TREADY : STD_LOGIC;
  signal s_axis_dataTimeRX_1_TVALID : STD_LOGIC;
  signal sdrController_0_FIR_data_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal sdrController_0_FIR_data_TREADY : STD_LOGIC;
  signal sdrController_0_FIR_data_TVALID : STD_LOGIC;
  signal sdrController_0_FIRimag_arst_o : STD_LOGIC;
  signal sdrController_0_FIRimag_config_TDATA : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal sdrController_0_FIRimag_config_TREADY : STD_LOGIC;
  signal sdrController_0_FIRimag_config_TVALID : STD_LOGIC;
  signal sdrController_0_FIRimag_reload_TDATA : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal sdrController_0_FIRimag_reload_TLAST : STD_LOGIC;
  signal sdrController_0_FIRimag_reload_TREADY : STD_LOGIC;
  signal sdrController_0_FIRimag_reload_TVALID : STD_LOGIC;
  signal sdrController_0_FIRreal_arst_o : STD_LOGIC;
  signal sdrController_0_FIRreal_config_TDATA : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal sdrController_0_FIRreal_config_TREADY : STD_LOGIC;
  signal sdrController_0_FIRreal_config_TVALID : STD_LOGIC;
  signal sdrController_0_FIRreal_data_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal sdrController_0_FIRreal_data_TREADY : STD_LOGIC;
  signal sdrController_0_FIRreal_data_TVALID : STD_LOGIC;
  signal sdrController_0_FIRreal_reload_TDATA : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal sdrController_0_FIRreal_reload_TLAST : STD_LOGIC;
  signal sdrController_0_FIRreal_reload_TREADY : STD_LOGIC;
  signal sdrController_0_FIRreal_reload_TVALID : STD_LOGIC;
  signal sdrController_0_IQtoRAM_RX_m_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal sdrController_0_IQtoRAM_RX_m_TVALID : STD_LOGIC;
  signal sdrController_0_cntDetectionAsMode : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal sdrController_0_enableRX : STD_LOGIC;
  signal sdrController_0_enableTX : STD_LOGIC;
  signal sdrController_0_isTXPath : STD_LOGIC;
  signal sdrController_0_ofdmTimeTX_m_data_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal sdrController_0_ofdmTimeTX_m_data_TVALID : STD_LOGIC;
  signal sdrController_0_sequenceSel : STD_LOGIC;
  signal NLW_largeRXBuffer_rd_rst_busy_UNCONNECTED : STD_LOGIC;
  signal NLW_largeRXBuffer_s_axis_tready_UNCONNECTED : STD_LOGIC;
  signal NLW_largeRXBuffer_wr_rst_busy_UNCONNECTED : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of IQfromRAM_TX_s_tready : signal is "xilinx.com:interface:axis:1.0 IQfromRAM_TX_s TREADY";
  attribute X_INTERFACE_INFO of IQfromRAM_TX_s_tvalid : signal is "xilinx.com:interface:axis:1.0 IQfromRAM_TX_s TVALID";
  attribute X_INTERFACE_INFO of IQfromRF_RX_s_tready : signal is "xilinx.com:interface:axis:1.0 IQfromRF_RX_s TREADY";
  attribute X_INTERFACE_INFO of IQfromRF_RX_s_tvalid : signal is "xilinx.com:interface:axis:1.0 IQfromRF_RX_s TVALID";
  attribute X_INTERFACE_INFO of IQtoRAM_RX_m_tready : signal is "xilinx.com:interface:axis:1.0 IQtoRAM_RX_m TREADY";
  attribute X_INTERFACE_INFO of IQtoRAM_RX_m_tvalid : signal is "xilinx.com:interface:axis:1.0 IQtoRAM_RX_m TVALID";
  attribute X_INTERFACE_INFO of IQtoRF_TX_m_tvalid : signal is "xilinx.com:interface:axis:1.0 IQtoRF_TX_m TVALID";
  attribute X_INTERFACE_INFO of arstn : signal is "xilinx.com:signal:reset:1.0 RST.ARSTN RST";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of arstn : signal is "XIL_INTERFACENAME RST.ARSTN, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 CLK.CLK CLK";
  attribute X_INTERFACE_PARAMETER of clk : signal is "XIL_INTERFACENAME CLK.CLK, ASSOCIATED_BUSIF IQfromRF_RX_s:IQfromRAM_TX_s:IQtoRAM_RX_m:IQtoRF_TX_m, ASSOCIATED_RESET arstn, CLK_DOMAIN myFreqSDR_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of IQfromRAM_TX_s_tdata : signal is "xilinx.com:interface:axis:1.0 IQfromRAM_TX_s TDATA";
  attribute X_INTERFACE_PARAMETER of IQfromRAM_TX_s_tdata : signal is "XIL_INTERFACENAME IQfromRAM_TX_s, CLK_DOMAIN myFreqSDR_clk, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of IQfromRF_RX_s_tdata : signal is "xilinx.com:interface:axis:1.0 IQfromRF_RX_s TDATA";
  attribute X_INTERFACE_PARAMETER of IQfromRF_RX_s_tdata : signal is "XIL_INTERFACENAME IQfromRF_RX_s, CLK_DOMAIN myFreqSDR_clk, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of IQtoRAM_RX_m_tdata : signal is "xilinx.com:interface:axis:1.0 IQtoRAM_RX_m TDATA";
  attribute X_INTERFACE_PARAMETER of IQtoRAM_RX_m_tdata : signal is "XIL_INTERFACENAME IQtoRAM_RX_m, CLK_DOMAIN myFreqSDR_clk, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of IQtoRF_TX_m_tdata : signal is "xilinx.com:interface:axis:1.0 IQtoRF_TX_m TDATA";
  attribute X_INTERFACE_PARAMETER of IQtoRF_TX_m_tdata : signal is "XIL_INTERFACENAME IQtoRF_TX_m, CLK_DOMAIN myFreqSDR_clk, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
begin
  IQfromRAM_TX_s_tready <= s_axis_dataFreqTX_1_TREADY;
  IQfromRF_RX_s_tready <= s_axis_dataTimeRX_1_TREADY;
  IQtoRAM_RX_m_tdata(31 downto 0) <= largeRXBuffer_M_AXIS_TDATA(31 downto 0);
  IQtoRAM_RX_m_tvalid <= largeRXBuffer_M_AXIS_TVALID;
  IQtoRF_TX_m_tdata(31 downto 0) <= sdrController_0_ofdmTimeTX_m_data_TDATA(31 downto 0);
  IQtoRF_TX_m_tvalid <= sdrController_0_ofdmTimeTX_m_data_TVALID;
  arstn_1 <= arstn;
  clk_1 <= clk;
  info_cntDetection(15 downto 0) <= sdrController_0_cntDetectionAsMode(15 downto 0);
  info_enableRX <= sdrController_0_enableRX;
  info_enableTX <= sdrController_0_enableTX;
  info_fifoRX_count(14 downto 0) <= largeRXBuffer_axis_data_count(14 downto 0);
  info_isTXPath <= sdrController_0_isTXPath;
  info_overflow <= largeRXBuffer_axis_overflow;
  info_sequenceSel <= sdrController_0_sequenceSel;
  largeRXBuffer_M_AXIS_TREADY <= IQtoRAM_RX_m_tready;
  params_coefReal0n1_1(95 downto 0) <= params_coefReal1(95 downto 0);
  params_coefReal0n2_1(95 downto 0) <= params_coefImag0(95 downto 0);
  params_coefReal0n3_1(95 downto 0) <= params_coefImag1(95 downto 0);
  params_coefReal0n_1(95 downto 0) <= params_coefReal0(95 downto 0);
  params_enableRXConf_1(4 downto 0) <= params_enableRXConf(4 downto 0);
  params_enableTXConf_1(4 downto 0) <= params_enableTXConf(4 downto 0);
  params_isTXPathConf_1(4 downto 0) <= params_isTXPathConf(4 downto 0);
  params_sequenceSelConf_1(4 downto 0) <= params_sequenceSelConf(4 downto 0);
  params_timer1_Nofdm_1(15 downto 0) <= params_timer1_inSample(15 downto 0);
  params_timer2_Nofdm_1(15 downto 0) <= params_timer2_inSample(15 downto 0);
  params_timer3_Nofdm_1(15 downto 0) <= params_timer3_inSample(15 downto 0);
  params_timer4_Nofdm_1(15 downto 0) <= params_timer4_inSample(15 downto 0);
  s_axis_dataFreqTX_1_TDATA(31 downto 0) <= IQfromRAM_TX_s_tdata(31 downto 0);
  s_axis_dataFreqTX_1_TVALID <= IQfromRAM_TX_s_tvalid;
  s_axis_dataTimeRX_1_TDATA(31 downto 0) <= IQfromRF_RX_s_tdata(31 downto 0);
  s_axis_dataTimeRX_1_TVALID <= IQfromRF_RX_s_tvalid;
-- 2(bitWidthFIRout+1)
  -- BitWidth for each paralel filter:
  -- bitWidthFIRout = bitWidthFIRin+bitWidthFIRcoefBits+log2(lengthFIR)
  correlator: entity work.correlator_imp_1JLS5UE
     port map (
      FIRimag_arst => sdrController_0_FIRimag_arst_o,
      FIRimag_config_tdata(7 downto 0) => sdrController_0_FIRimag_config_TDATA(7 downto 0),
      FIRimag_config_tready => sdrController_0_FIRimag_config_TREADY,
      FIRimag_config_tvalid => sdrController_0_FIRimag_config_TVALID,
      FIRimag_data_tdata(31 downto 0) => sdrController_0_FIR_data_TDATA(31 downto 0),
      FIRimag_data_tready => sdrController_0_FIR_data_TREADY,
      FIRimag_data_tvalid => sdrController_0_FIR_data_TVALID,
      FIRimag_reload_tdata(7 downto 0) => sdrController_0_FIRimag_reload_TDATA(7 downto 0),
      FIRimag_reload_tlast => sdrController_0_FIRimag_reload_TLAST,
      FIRimag_reload_tready => sdrController_0_FIRimag_reload_TREADY,
      FIRimag_reload_tvalid => sdrController_0_FIRimag_reload_TVALID,
      FIRreal_arst => sdrController_0_FIRreal_arst_o,
      FIRreal_config_tdata(7 downto 0) => sdrController_0_FIRreal_config_TDATA(7 downto 0),
      FIRreal_config_tready => sdrController_0_FIRreal_config_TREADY,
      FIRreal_config_tvalid => sdrController_0_FIRreal_config_TVALID,
      FIRreal_data_tdata(31 downto 0) => sdrController_0_FIRreal_data_TDATA(31 downto 0),
      FIRreal_data_tready => sdrController_0_FIRreal_data_TREADY,
      FIRreal_data_tvalid => sdrController_0_FIRreal_data_TVALID,
      FIRreal_reload_tdata(7 downto 0) => sdrController_0_FIRreal_reload_TDATA(7 downto 0),
      FIRreal_reload_tlast => sdrController_0_FIRreal_reload_TLAST,
      FIRreal_reload_tready => sdrController_0_FIRreal_reload_TREADY,
      FIRreal_reload_tvalid => sdrController_0_FIRreal_reload_TVALID,
      IQeffective(23 downto 0) => D_1(23 downto 0),
      arstn => arstn_1,
      clk => clk_1,
      detectedRepeat => correlator_detectedRepeat
    );
largeRXBuffer: component myFreqSDR_fifo_generator_0_0
     port map (
      axis_data_count(14 downto 0) => largeRXBuffer_axis_data_count(14 downto 0),
      axis_overflow => largeRXBuffer_axis_overflow,
      m_axis_tdata(31 downto 0) => largeRXBuffer_M_AXIS_TDATA(31 downto 0),
      m_axis_tready => largeRXBuffer_M_AXIS_TREADY,
      m_axis_tvalid => largeRXBuffer_M_AXIS_TVALID,
      rd_rst_busy => NLW_largeRXBuffer_rd_rst_busy_UNCONNECTED,
      s_aclk => clk_1,
      s_aresetn => arstn_1,
      s_axis_tdata(31 downto 0) => sdrController_0_IQtoRAM_RX_m_TDATA(31 downto 0),
      s_axis_tready => NLW_largeRXBuffer_s_axis_tready_UNCONNECTED,
      s_axis_tvalid => sdrController_0_IQtoRAM_RX_m_TVALID,
      wr_rst_busy => NLW_largeRXBuffer_wr_rst_busy_UNCONNECTED
    );
sdrController_0: component myFreqSDR_sdrController_0_0
     port map (
      FIRimag_arst_o => sdrController_0_FIRimag_arst_o,
      FIRimag_config_data(7 downto 0) => sdrController_0_FIRimag_config_TDATA(7 downto 0),
      FIRimag_config_ready => sdrController_0_FIRimag_config_TREADY,
      FIRimag_config_valid => sdrController_0_FIRimag_config_TVALID,
      FIRimag_data_data(31 downto 0) => sdrController_0_FIR_data_TDATA(31 downto 0),
      FIRimag_data_ready => sdrController_0_FIR_data_TREADY,
      FIRimag_data_valid => sdrController_0_FIR_data_TVALID,
      FIRimag_reload_data(7 downto 0) => sdrController_0_FIRimag_reload_TDATA(7 downto 0),
      FIRimag_reload_last => sdrController_0_FIRimag_reload_TLAST,
      FIRimag_reload_ready => sdrController_0_FIRimag_reload_TREADY,
      FIRimag_reload_valid => sdrController_0_FIRimag_reload_TVALID,
      FIRreal_arst_o => sdrController_0_FIRreal_arst_o,
      FIRreal_config_data(7 downto 0) => sdrController_0_FIRreal_config_TDATA(7 downto 0),
      FIRreal_config_ready => sdrController_0_FIRreal_config_TREADY,
      FIRreal_config_valid => sdrController_0_FIRreal_config_TVALID,
      FIRreal_data_data(31 downto 0) => sdrController_0_FIRreal_data_TDATA(31 downto 0),
      FIRreal_data_ready => sdrController_0_FIRreal_data_TREADY,
      FIRreal_data_valid => sdrController_0_FIRreal_data_TVALID,
      FIRreal_reload_data(7 downto 0) => sdrController_0_FIRreal_reload_TDATA(7 downto 0),
      FIRreal_reload_last => sdrController_0_FIRreal_reload_TLAST,
      FIRreal_reload_ready => sdrController_0_FIRreal_reload_TREADY,
      FIRreal_reload_valid => sdrController_0_FIRreal_reload_TVALID,
      IQeffective(23 downto 0) => D_1(23 downto 0),
      arstn => arstn_1,
      clk => clk_1,
      cntDetectionAsMode(15 downto 0) => sdrController_0_cntDetectionAsMode(15 downto 0),
      coefImag0(95 downto 0) => params_coefReal0n2_1(95 downto 0),
      coefImag1(95 downto 0) => params_coefReal0n3_1(95 downto 0),
      coefReal0(95 downto 0) => params_coefReal0n_1(95 downto 0),
      coefReal1(95 downto 0) => params_coefReal0n1_1(95 downto 0),
      data_IQfromRAM_TX_i(31 downto 0) => s_axis_dataFreqTX_1_TDATA(31 downto 0),
      data_IQfromRF_RX_i(31 downto 0) => s_axis_dataTimeRX_1_TDATA(31 downto 0),
      data_IQtoRAM_RX_o(31 downto 0) => sdrController_0_IQtoRAM_RX_m_TDATA(31 downto 0),
      data_IQtoRF_TX_o(31 downto 0) => sdrController_0_ofdmTimeTX_m_data_TDATA(31 downto 0),
      enableRX => sdrController_0_enableRX,
      enableRXconf(4 downto 0) => params_enableRXConf_1(4 downto 0),
      enableTX => sdrController_0_enableTX,
      enableTXconf(4 downto 0) => params_enableTXConf_1(4 downto 0),
      isTXPath => sdrController_0_isTXPath,
      isTXPathConf(4 downto 0) => params_isTXPathConf_1(4 downto 0),
      ready_IQfromRAM_TX_o => s_axis_dataFreqTX_1_TREADY,
      ready_IQfromRF_RX_o => s_axis_dataTimeRX_1_TREADY,
      sequenceSel => sdrController_0_sequenceSel,
      sequenceSelConf(4 downto 0) => params_sequenceSelConf_1(4 downto 0),
      syncDetected => correlator_detectedRepeat,
      timer1_inSample(15 downto 0) => params_timer1_Nofdm_1(15 downto 0),
      timer2_inSample(15 downto 0) => params_timer2_Nofdm_1(15 downto 0),
      timer3_inSample(15 downto 0) => params_timer3_Nofdm_1(15 downto 0),
      timer4_inSample(15 downto 0) => params_timer4_Nofdm_1(15 downto 0),
      valid_IQfromRAM_TX_i => s_axis_dataFreqTX_1_TVALID,
      valid_IQfromRF_RX_i => s_axis_dataTimeRX_1_TVALID,
      valid_IQtoRAM_RX_o => sdrController_0_IQtoRAM_RX_m_TVALID,
      valid_IQtoRF_TX_o => sdrController_0_ofdmTimeTX_m_data_TVALID
    );
end STRUCTURE;
