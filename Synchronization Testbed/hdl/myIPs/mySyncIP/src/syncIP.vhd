--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
--Date        : Wed Nov 26 13:32:15 2025
--Host        : ORION running 64-bit major release  (build 9200)
--Command     : generate_target syncIP.bd
--Design      : syncIP
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity rotatorAndScaling_imp_2HNR68 is
  port (
    clk : in STD_LOGIC;
    cosTheta_i : in STD_LOGIC_VECTOR ( 19 downto 0 );
    data_IQrotated_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    data_IQtoBeRotated_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
    sinTheta_i : in STD_LOGIC_VECTOR ( 19 downto 0 )
  );
end rotatorAndScaling_imp_2HNR68;

architecture STRUCTURE of rotatorAndScaling_imp_2HNR68 is
  component syncIP_mult_gen_0_1 is
  port (
    CLK : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR ( 15 downto 0 );
    B : in STD_LOGIC_VECTOR ( 19 downto 0 );
    P : out STD_LOGIC_VECTOR ( 35 downto 0 )
  );
  end component syncIP_mult_gen_0_1;
  component syncIP_rotator_substract_0 is
  port (
    A : in STD_LOGIC_VECTOR ( 35 downto 0 );
    B : in STD_LOGIC_VECTOR ( 35 downto 0 );
    S : out STD_LOGIC_VECTOR ( 36 downto 0 )
  );
  end component syncIP_rotator_substract_0;
  component syncIP_multi_Q_cos_0 is
  port (
    CLK : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR ( 15 downto 0 );
    B : in STD_LOGIC_VECTOR ( 19 downto 0 );
    P : out STD_LOGIC_VECTOR ( 35 downto 0 )
  );
  end component syncIP_multi_Q_cos_0;
  component syncIP_mult_gen_1_0 is
  port (
    CLK : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR ( 15 downto 0 );
    B : in STD_LOGIC_VECTOR ( 19 downto 0 );
    P : out STD_LOGIC_VECTOR ( 35 downto 0 )
  );
  end component syncIP_mult_gen_1_0;
  component syncIP_mult_gen_0_0 is
  port (
    CLK : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR ( 15 downto 0 );
    B : in STD_LOGIC_VECTOR ( 19 downto 0 );
    P : out STD_LOGIC_VECTOR ( 35 downto 0 )
  );
  end component syncIP_mult_gen_0_0;
  component syncIP_phaseBiasAndConjugate_0 is
  port (
    A : in STD_LOGIC_VECTOR ( 35 downto 0 );
    B : in STD_LOGIC_VECTOR ( 35 downto 0 );
    S : out STD_LOGIC_VECTOR ( 36 downto 0 )
  );
  end component syncIP_phaseBiasAndConjugate_0;
  component syncIP_IrSlicer_0 is
  port (
    Din : in STD_LOGIC_VECTOR ( 36 downto 0 );
    Dout : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component syncIP_IrSlicer_0;
  component syncIP_IrSlicer1_0 is
  port (
    Din : in STD_LOGIC_VECTOR ( 36 downto 0 );
    Dout : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component syncIP_IrSlicer1_0;
  component syncIP_basicSlicer_0_0 is
  port (
    data_in : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dataOut1 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    dataOut2 : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component syncIP_basicSlicer_0_0;
  component syncIP_basicConcat_0_1 is
  port (
    dataOut : out STD_LOGIC_VECTOR ( 31 downto 0 );
    dataIn1 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    dataIn2 : in STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component syncIP_basicConcat_0_1;
  signal IrSlicerPhase_Dout : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal QrSlicerPhase_Dout : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal clk_1 : STD_LOGIC;
  signal cosTheta : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal dataInphase : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal dataQuadrature : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal data_IQtoBeRotated_i_1 : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal multi_I_cos_P : STD_LOGIC_VECTOR ( 35 downto 0 );
  signal multi_I_sin_P : STD_LOGIC_VECTOR ( 35 downto 0 );
  signal multi_Q_cos_P : STD_LOGIC_VECTOR ( 35 downto 0 );
  signal multi_Q_sin_P : STD_LOGIC_VECTOR ( 35 downto 0 );
  signal rotatorConcat_dataOut : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal rotator_adder_S : STD_LOGIC_VECTOR ( 36 downto 0 );
  signal rotator_substract_S : STD_LOGIC_VECTOR ( 36 downto 0 );
  signal sinTheta : STD_LOGIC_VECTOR ( 19 downto 0 );
begin
  clk_1 <= clk;
  cosTheta(19 downto 0) <= cosTheta_i(19 downto 0);
  data_IQrotated_o(31 downto 0) <= rotatorConcat_dataOut(31 downto 0);
  data_IQtoBeRotated_i_1(31 downto 0) <= data_IQtoBeRotated_i(31 downto 0);
  sinTheta(19 downto 0) <= sinTheta_i(19 downto 0);
IQslicer: component syncIP_basicSlicer_0_0
     port map (
      dataOut1(15 downto 0) => dataInphase(15 downto 0),
      dataOut2(15 downto 0) => dataQuadrature(15 downto 0),
      data_in(31 downto 0) => data_IQtoBeRotated_i_1(31 downto 0)
    );
IrSlicerPhase: component syncIP_IrSlicer_0
     port map (
      Din(36 downto 0) => rotator_substract_S(36 downto 0),
      Dout(15 downto 0) => IrSlicerPhase_Dout(15 downto 0)
    );
QrSlicerPhase: component syncIP_IrSlicer1_0
     port map (
      Din(36 downto 0) => rotator_adder_S(36 downto 0),
      Dout(15 downto 0) => QrSlicerPhase_Dout(15 downto 0)
    );
multi_I_cos: component syncIP_mult_gen_0_0
     port map (
      A(15 downto 0) => dataInphase(15 downto 0),
      B(19 downto 0) => cosTheta(19 downto 0),
      CLK => clk_1,
      P(35 downto 0) => multi_I_cos_P(35 downto 0)
    );
multi_I_sin: component syncIP_mult_gen_0_1
     port map (
      A(15 downto 0) => dataInphase(15 downto 0),
      B(19 downto 0) => sinTheta(19 downto 0),
      CLK => clk_1,
      P(35 downto 0) => multi_I_sin_P(35 downto 0)
    );
multi_Q_cos: component syncIP_mult_gen_1_0
     port map (
      A(15 downto 0) => dataQuadrature(15 downto 0),
      B(19 downto 0) => cosTheta(19 downto 0),
      CLK => clk_1,
      P(35 downto 0) => multi_Q_cos_P(35 downto 0)
    );
multi_Q_sin: component syncIP_multi_Q_cos_0
     port map (
      A(15 downto 0) => dataQuadrature(15 downto 0),
      B(19 downto 0) => sinTheta(19 downto 0),
      CLK => clk_1,
      P(35 downto 0) => multi_Q_sin_P(35 downto 0)
    );
rotatorConcat: component syncIP_basicConcat_0_1
     port map (
      dataIn1(15 downto 0) => IrSlicerPhase_Dout(15 downto 0),
      dataIn2(15 downto 0) => QrSlicerPhase_Dout(15 downto 0),
      dataOut(31 downto 0) => rotatorConcat_dataOut(31 downto 0)
    );
rotator_adder: component syncIP_rotator_substract_0
     port map (
      A(35 downto 0) => multi_I_sin_P(35 downto 0),
      B(35 downto 0) => multi_Q_cos_P(35 downto 0),
      S(36 downto 0) => rotator_adder_S(36 downto 0)
    );
rotator_substract: component syncIP_phaseBiasAndConjugate_0
     port map (
      A(35 downto 0) => multi_I_cos_P(35 downto 0),
      B(35 downto 0) => multi_Q_sin_P(35 downto 0),
      S(36 downto 0) => rotator_substract_S(36 downto 0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity phaseCompensation_imp_6RINKV is
  port (
    addPhaseBias_i : in STD_LOGIC;
    arstn : in STD_LOGIC;
    clk : in STD_LOGIC;
    data_IQrotated_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    data_IQtoBeRotated_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
    enablePhaseEs_i : in STD_LOGIC;
    imag_signed_detected_i : in STD_LOGIC_VECTOR ( 26 downto 0 );
    isConjugated_i : in STD_LOGIC;
    numeratork_i : in STD_LOGIC_VECTOR ( 26 downto 0 );
    real_signed_detected_i : in STD_LOGIC_VECTOR ( 26 downto 0 );
    status_myPhaseEstimation : out STD_LOGIC_VECTOR ( 31 downto 0 );
    syncDetected_i : in STD_LOGIC
  );
end phaseCompensation_imp_6RINKV;

architecture STRUCTURE of phaseCompensation_imp_6RINKV is
  component syncIP_cordic_0_0 is
  port (
    aclk : in STD_LOGIC;
    s_axis_cartesian_tvalid : in STD_LOGIC;
    s_axis_cartesian_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_dout_tvalid : out STD_LOGIC;
    m_axis_dout_tdata : out STD_LOGIC_VECTOR ( 23 downto 0 )
  );
  end component syncIP_cordic_0_0;
  component syncIP_c_addsub_0_0 is
  port (
    A : in STD_LOGIC_VECTOR ( 23 downto 0 );
    B : in STD_LOGIC_VECTOR ( 23 downto 0 );
    ADD : in STD_LOGIC;
    S : out STD_LOGIC_VECTOR ( 23 downto 0 )
  );
  end component syncIP_c_addsub_0_0;
  component syncIP_util_vector_logic_0_1 is
  port (
    Op1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    Res : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component syncIP_util_vector_logic_0_1;
  component syncIP_xlconstant_0_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 19 downto 0 )
  );
  end component syncIP_xlconstant_0_0;
  component syncIP_xlconstant_0_1 is
  port (
    dout : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component syncIP_xlconstant_0_1;
  component syncIP_basicConcat_0_0 is
  port (
    dataOut : out STD_LOGIC_VECTOR ( 63 downto 0 );
    dataIn1 : in STD_LOGIC_VECTOR ( 26 downto 0 );
    dataIn2 : in STD_LOGIC_VECTOR ( 26 downto 0 )
  );
  end component syncIP_basicConcat_0_0;
  component syncIP_IQslicer_0 is
  port (
    data_in : in STD_LOGIC_VECTOR ( 47 downto 0 );
    dataOut1 : out STD_LOGIC_VECTOR ( 19 downto 0 );
    dataOut2 : out STD_LOGIC_VECTOR ( 19 downto 0 )
  );
  end component syncIP_IQslicer_0;
  component syncIP_myReciprocal_0_1 is
  port (
    clk : in STD_LOGIC;
    valid_o : out STD_LOGIC;
    a : in STD_LOGIC_VECTOR ( 26 downto 0 );
    b : in STD_LOGIC_VECTOR ( 26 downto 0 );
    k : out STD_LOGIC_VECTOR ( 14 downto 0 )
  );
  end component syncIP_myReciprocal_0_1;
  component syncIP_mux_0_0 is
  port (
    dataOut : out STD_LOGIC_VECTOR ( 19 downto 0 );
    dataIn0 : in STD_LOGIC_VECTOR ( 19 downto 0 );
    dataIn1 : in STD_LOGIC_VECTOR ( 19 downto 0 );
    selectIn : in STD_LOGIC
  );
  end component syncIP_mux_0_0;
  component syncIP_magnitudeEstimator_0_0 is
  port (
    inPhase_i : in STD_LOGIC_VECTOR ( 26 downto 0 );
    quadrature_i : in STD_LOGIC_VECTOR ( 26 downto 0 );
    magnitude_o : out STD_LOGIC_VECTOR ( 26 downto 0 );
    clk : in STD_LOGIC;
    arstn : in STD_LOGIC
  );
  end component syncIP_magnitudeEstimator_0_0;
  component syncIP_phaseEstimationInput_0_0 is
  port (
    data_o : out STD_LOGIC_VECTOR ( 63 downto 0 );
    data_i : in STD_LOGIC_VECTOR ( 63 downto 0 );
    valid_o : out STD_LOGIC;
    syncDetected_i : in STD_LOGIC;
    enablePhaseEs_i : in STD_LOGIC;
    kVal_i : in STD_LOGIC_VECTOR ( 14 downto 0 );
    status_myPhaseEstimation : out STD_LOGIC_VECTOR ( 31 downto 0 );
    clk : in STD_LOGIC;
    arstn : in STD_LOGIC
  );
  end component syncIP_phaseEstimationInput_0_0;
  component syncIP_xlconcat_0_1 is
  port (
    In0 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    In1 : in STD_LOGIC_VECTOR ( 19 downto 0 );
    dout : out STD_LOGIC_VECTOR ( 23 downto 0 )
  );
  end component syncIP_xlconcat_0_1;
  component syncIP_xlconstant_2_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 3 downto 0 )
  );
  end component syncIP_xlconstant_2_0;
  component syncIP_atan_1 is
  port (
    aclk : in STD_LOGIC;
    s_axis_phase_tvalid : in STD_LOGIC;
    s_axis_phase_tdata : in STD_LOGIC_VECTOR ( 23 downto 0 );
    m_axis_dout_tvalid : out STD_LOGIC;
    m_axis_dout_tdata : out STD_LOGIC_VECTOR ( 47 downto 0 )
  );
  end component syncIP_atan_1;
  component syncIP_myAcosROM_0_0 is
  port (
    clk : in STD_LOGIC;
    address : in STD_LOGIC_VECTOR ( 14 downto 0 );
    data_o : out STD_LOGIC_VECTOR ( 19 downto 0 )
  );
  end component syncIP_myAcosROM_0_0;
  signal acosMux_afterpadding : STD_LOGIC_VECTOR ( 23 downto 0 );
  signal acosMux_o : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal add_r : STD_LOGIC_VECTOR ( 0 to 0 );
  signal arstn_1 : STD_LOGIC;
  signal clk_1 : STD_LOGIC;
  signal cosSinSlicer_dataOut1 : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal cosSinSlicer_dataOut2 : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal cosSin_m_axis_dout_tdata : STD_LOGIC_VECTOR ( 47 downto 0 );
  signal data_IQtoBeRotated_i_1 : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal enablePhaseEst_r : STD_LOGIC;
  signal imag_signed_detected_r : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal isConjugated_r : STD_LOGIC;
  signal magnitudeEstimator_0_magnitude_o : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal myAcosROM_0_data_o : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal myReciprocal_0_k : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal numeratork_i_1 : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal phaseBiasAndConjugate_S : STD_LOGIC_VECTOR ( 23 downto 0 );
  signal phaseEstimationInput_0_data_o : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal phaseEstimationInput_0_myPhaseEstimation_status : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal phaseEstimationInput_0_valid_o : STD_LOGIC;
  signal phase_Estimate : STD_LOGIC_VECTOR ( 23 downto 0 );
  signal real_signed_detected_r : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal rotatorAndScaling_data_IQrotated_o : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal selectIn_1 : STD_LOGIC;
  signal syncDetected_r : STD_LOGIC;
  signal xcorrConcat_dataOut : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal xlconstant_0_dout : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal xlconstant_1_dout : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xlconstant_3_dout : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_atan_m_axis_dout_tvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_cosSin_m_axis_dout_tvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_myReciprocal_0_valid_o_UNCONNECTED : STD_LOGIC;
begin
  arstn_1 <= arstn;
  clk_1 <= clk;
  data_IQrotated_o(31 downto 0) <= rotatorAndScaling_data_IQrotated_o(31 downto 0);
  data_IQtoBeRotated_i_1(31 downto 0) <= data_IQtoBeRotated_i(31 downto 0);
  enablePhaseEst_r <= enablePhaseEs_i;
  imag_signed_detected_r(26 downto 0) <= imag_signed_detected_i(26 downto 0);
  isConjugated_r <= isConjugated_i;
  numeratork_i_1(26 downto 0) <= numeratork_i(26 downto 0);
  real_signed_detected_r(26 downto 0) <= real_signed_detected_i(26 downto 0);
  selectIn_1 <= addPhaseBias_i;
  status_myPhaseEstimation(31 downto 0) <= phaseEstimationInput_0_myPhaseEstimation_status(31 downto 0);
  syncDetected_r <= syncDetected_i;
-- re:-1:1,im:-1:1,phase:-pi:pi
  -- re:-1:1,im:-1:1,phase:-pi:pi
  -- sinTheta,cosTheta: 2.14
  -- I_i,Q_i: 16.0
  -- P: 18.14
  atan: component syncIP_cordic_0_0
     port map (
      aclk => clk_1,
      m_axis_dout_tdata(23 downto 0) => phase_Estimate(23 downto 0),
      m_axis_dout_tvalid => NLW_atan_m_axis_dout_tvalid_UNCONNECTED,
      s_axis_cartesian_tdata(63 downto 0) => phaseEstimationInput_0_data_o(63 downto 0),
      s_axis_cartesian_tvalid => phaseEstimationInput_0_valid_o
    );
cosSin: component syncIP_atan_1
     port map (
      aclk => clk_1,
      m_axis_dout_tdata(47 downto 0) => cosSin_m_axis_dout_tdata(47 downto 0),
      m_axis_dout_tvalid => NLW_cosSin_m_axis_dout_tvalid_UNCONNECTED,
      s_axis_phase_tdata(23 downto 0) => phaseBiasAndConjugate_S(23 downto 0),
      s_axis_phase_tvalid => xlconstant_1_dout(0)
    );
cosSinSlicer: component syncIP_IQslicer_0
     port map (
      dataOut1(19 downto 0) => cosSinSlicer_dataOut1(19 downto 0),
      dataOut2(19 downto 0) => cosSinSlicer_dataOut2(19 downto 0),
      data_in(47 downto 0) => cosSin_m_axis_dout_tdata(47 downto 0)
    );
magnitudeEstimator_0: component syncIP_magnitudeEstimator_0_0
     port map (
      arstn => arstn_1,
      clk => clk_1,
      inPhase_i(26 downto 0) => real_signed_detected_r(26 downto 0),
      magnitude_o(26 downto 0) => magnitudeEstimator_0_magnitude_o(26 downto 0),
      quadrature_i(26 downto 0) => imag_signed_detected_r(26 downto 0)
    );
mux_0: component syncIP_mux_0_0
     port map (
      dataIn0(19 downto 0) => xlconstant_0_dout(19 downto 0),
      dataIn1(19 downto 0) => myAcosROM_0_data_o(19 downto 0),
      dataOut(19 downto 0) => acosMux_o(19 downto 0),
      selectIn => selectIn_1
    );
myAcosROM_0: component syncIP_myAcosROM_0_0
     port map (
      address(14 downto 0) => myReciprocal_0_k(14 downto 0),
      clk => clk_1,
      data_o(19 downto 0) => myAcosROM_0_data_o(19 downto 0)
    );
myReciprocal_0: component syncIP_myReciprocal_0_1
     port map (
      a(26 downto 0) => magnitudeEstimator_0_magnitude_o(26 downto 0),
      b(26 downto 0) => numeratork_i_1(26 downto 0),
      clk => clk_1,
      k(14 downto 0) => myReciprocal_0_k(14 downto 0),
      valid_o => NLW_myReciprocal_0_valid_o_UNCONNECTED
    );
phaseBiasAndConjugate: component syncIP_c_addsub_0_0
     port map (
      A(23 downto 0) => acosMux_afterpadding(23 downto 0),
      ADD => add_r(0),
      B(23 downto 0) => phase_Estimate(23 downto 0),
      S(23 downto 0) => phaseBiasAndConjugate_S(23 downto 0)
    );
phaseEstimationInput_0: component syncIP_phaseEstimationInput_0_0
     port map (
      arstn => arstn_1,
      clk => clk_1,
      data_i(63 downto 0) => xcorrConcat_dataOut(63 downto 0),
      data_o(63 downto 0) => phaseEstimationInput_0_data_o(63 downto 0),
      enablePhaseEs_i => enablePhaseEst_r,
      kVal_i(14 downto 0) => myReciprocal_0_k(14 downto 0),
      status_myPhaseEstimation(31 downto 0) => phaseEstimationInput_0_myPhaseEstimation_status(31 downto 0),
      syncDetected_i => syncDetected_r,
      valid_o => phaseEstimationInput_0_valid_o
    );
-- sinTheta,cosTheta: 2.14
  -- I_i,Q_i: 16.0
  -- P: 18.14
  -- S:19.14
  -- aBias: 0.14, S: 19.14
  -- P: 19.28
  rotatorAndScaling: entity work.rotatorAndScaling_imp_2HNR68
     port map (
      clk => clk_1,
      cosTheta_i(19 downto 0) => cosSinSlicer_dataOut1(19 downto 0),
      data_IQrotated_o(31 downto 0) => rotatorAndScaling_data_IQrotated_o(31 downto 0),
      data_IQtoBeRotated_i(31 downto 0) => data_IQtoBeRotated_i_1(31 downto 0),
      sinTheta_i(19 downto 0) => cosSinSlicer_dataOut2(19 downto 0)
    );
util_vector_logic_1: component syncIP_util_vector_logic_0_1
     port map (
      Op1(0) => isConjugated_r,
      Res(0) => add_r(0)
    );
xcorrConcat: component syncIP_basicConcat_0_0
     port map (
      dataIn1(26 downto 0) => real_signed_detected_r(26 downto 0),
      dataIn2(26 downto 0) => imag_signed_detected_r(26 downto 0),
      dataOut(63 downto 0) => xcorrConcat_dataOut(63 downto 0)
    );
xlconcat_1: component syncIP_xlconcat_0_1
     port map (
      In0(3 downto 0) => xlconstant_3_dout(3 downto 0),
      In1(19 downto 0) => acosMux_o(19 downto 0),
      dout(23 downto 0) => acosMux_afterpadding(23 downto 0)
    );
xlconstant_0: component syncIP_xlconstant_0_0
     port map (
      dout(19 downto 0) => xlconstant_0_dout(19 downto 0)
    );
xlconstant_1: component syncIP_xlconstant_0_1
     port map (
      dout(0) => xlconstant_1_dout(0)
    );
xlconstant_3: component syncIP_xlconstant_2_0
     port map (
      dout(3 downto 0) => xlconstant_3_dout(3 downto 0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
-- sinTheta,cosTheta: 2.14
  -- I_i,Q_i: 16.0
  -- P: 18.14
  -- S:19.14
  -- aBias: 0.14, S: 19.14
  -- P: 19.28
  --  
  --  dc
  --  
  entity syncIP is
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
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of syncIP : entity is "syncIP,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=syncIP,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=30,numReposBlks=28,numNonXlnxBlks=0,numHierBlks=2,maxHierDepth=2,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=11,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of syncIP : entity is "syncIP.hwdef";
end syncIP;

architecture STRUCTURE of syncIP is
  component syncIP_largeRXBuffer_0 is
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
  end component syncIP_largeRXBuffer_0;
  component syncIP_sdrController_0_0 is
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
    data_IQtoBeRotated_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    data_IQrotated_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
    IQeffective : out STD_LOGIC_VECTOR ( 23 downto 0 );
    o_IQdata_wr : out STD_LOGIC;
    syncDetected : in STD_LOGIC;
    timer1_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    timer2_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    timer3_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    timer4_inSample : in STD_LOGIC_VECTOR ( 15 downto 0 );
    enableRXconf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    enableTXconf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    isTXPathConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    sequenceSelConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    enablePhaseEstConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    enablePhaseCorrConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    isConjugatedConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    addPhaseBiasConf : in STD_LOGIC_VECTOR ( 4 downto 0 );
    numeratorkPhase_i : in STD_LOGIC_VECTOR ( 26 downto 0 );
    fifoRX_count : in STD_LOGIC_VECTOR ( 14 downto 0 );
    sequenceSel : out STD_LOGIC;
    enablePhaseEst : out STD_LOGIC;
    isConjugated : out STD_LOGIC;
    addPhaseBias : out STD_LOGIC;
    numeratorkPhase_o : out STD_LOGIC_VECTOR ( 26 downto 0 );
    status_myController : out STD_LOGIC_VECTOR ( 63 downto 0 );
    clk : in STD_LOGIC;
    arstn : in STD_LOGIC
  );
  end component syncIP_sdrController_0_0;
  component syncIP_myCorrelator_0_0 is
  port (
    i_FIRcoef_wr : in STD_LOGIC;
    i_FIRcoef_addr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    i_FIRcoef_realValues_wr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    i_FIRcoef_imagValues_wr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    i_FIRcoef_realValues_rd : out STD_LOGIC_VECTOR ( 31 downto 0 );
    i_FIRcoef_imagValues_rd : out STD_LOGIC_VECTOR ( 31 downto 0 );
    i_sequenceSel : in STD_LOGIC;
    i_IQdata : in STD_LOGIC_VECTOR ( 23 downto 0 );
    i_IQdata_wr : in STD_LOGIC;
    i_clk : in STD_LOGIC;
    i_rstn : in STD_LOGIC;
    o_status_myDetector : out STD_LOGIC_VECTOR ( 351 downto 0 );
    o_FIRdata_real_detected : out STD_LOGIC_VECTOR ( 26 downto 0 );
    o_FIRdata_imag_detected : out STD_LOGIC_VECTOR ( 26 downto 0 );
    o_detected : out STD_LOGIC;
    i_clk_fast : in STD_LOGIC;
    i_rstn_fast : in STD_LOGIC
  );
  end component syncIP_myCorrelator_0_0;
  signal arstn_1 : STD_LOGIC;
  signal arstn_fast_1 : STD_LOGIC;
  signal clk_1 : STD_LOGIC;
  signal correlator_FIRcoef_imagValues_rd : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal correlator_FIRcoef_realValues_rd : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal correlator_detectedRepeat : STD_LOGIC;
  signal correlator_imag_signed_detected_o : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal correlator_status_myDetector : STD_LOGIC_VECTOR ( 351 downto 0 );
  signal largeRXBuffer_M_AXIS_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal largeRXBuffer_M_AXIS_TREADY : STD_LOGIC;
  signal largeRXBuffer_M_AXIS_TVALID : STD_LOGIC;
  signal largeRXBuffer_axis_data_count : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal largeRXBuffer_axis_overflow : STD_LOGIC;
  signal params_FIRcoef_addr_1 : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal params_FIRcoef_imagValues_wr_1 : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal params_FIRcoef_realValues_wr_1 : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal params_FIRcoef_wr_1 : STD_LOGIC;
  signal params_enableRXConf1_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_enableRXConf2_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_enableRXConf3_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_enableRXConf_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_enableTXConf_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_isConjugatedConf1_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_isTXPathConf_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_numeratorkPhase_1 : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal params_sequenceSelConf_1 : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal params_timer1_Nofdm_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal params_timer2_Nofdm_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal params_timer3_Nofdm_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal params_timer4_Nofdm_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal phaseCompensation_data_IQrotated_o : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal phaseCompensation_myPhaseEstimation_status : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal real_signed_detected_i_1 : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal s_axis_dataFreqTX_1_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s_axis_dataFreqTX_1_TREADY : STD_LOGIC;
  signal s_axis_dataFreqTX_1_TVALID : STD_LOGIC;
  signal s_axis_dataTimeRX_1_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s_axis_dataTimeRX_1_TREADY : STD_LOGIC;
  signal s_axis_dataTimeRX_1_TVALID : STD_LOGIC;
  signal sdrController_0_IQeffective : STD_LOGIC_VECTOR ( 23 downto 0 );
  signal sdrController_0_IQtoRAM_RX_m_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal sdrController_0_IQtoRAM_RX_m_TVALID : STD_LOGIC;
  signal sdrController_0_IQtoRF_TX_m_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal sdrController_0_IQtoRF_TX_m_TVALID : STD_LOGIC;
  signal sdrController_0_addPhaseBias : STD_LOGIC;
  signal sdrController_0_data_IQtoBeRotated_o : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal sdrController_0_enablePhaseEst : STD_LOGIC;
  signal sdrController_0_isConjugated : STD_LOGIC;
  signal sdrController_0_myController_status : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal sdrController_0_numeratorkPhase_o : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal sdrController_0_o_IQdata_wr : STD_LOGIC;
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
  attribute X_INTERFACE_INFO of arstn_fast : signal is "xilinx.com:signal:reset:1.0 RST.ARSTN_FAST RST";
  attribute X_INTERFACE_PARAMETER of arstn_fast : signal is "XIL_INTERFACENAME RST.ARSTN_FAST, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 CLK.CLK CLK";
  attribute X_INTERFACE_PARAMETER of clk : signal is "XIL_INTERFACENAME CLK.CLK, ASSOCIATED_BUSIF IQfromRF_RX_s:IQfromRAM_TX_s:IQtoRAM_RX_m:IQtoRF_TX_m, ASSOCIATED_RESET arstn, CLK_DOMAIN syncIP_clk, FREQ_HZ 10000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of clk_fast : signal is "xilinx.com:signal:clock:1.0 CLK.CLK_FAST CLK";
  attribute X_INTERFACE_PARAMETER of clk_fast : signal is "XIL_INTERFACENAME CLK.CLK_FAST, ASSOCIATED_RESET arstn:arstn_fast, CLK_DOMAIN syncIP_clk_fast, FREQ_HZ 80000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of IQfromRAM_TX_s_tdata : signal is "xilinx.com:interface:axis:1.0 IQfromRAM_TX_s TDATA";
  attribute X_INTERFACE_PARAMETER of IQfromRAM_TX_s_tdata : signal is "XIL_INTERFACENAME IQfromRAM_TX_s, CLK_DOMAIN syncIP_clk, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of IQfromRF_RX_s_tdata : signal is "xilinx.com:interface:axis:1.0 IQfromRF_RX_s TDATA";
  attribute X_INTERFACE_PARAMETER of IQfromRF_RX_s_tdata : signal is "XIL_INTERFACENAME IQfromRF_RX_s, CLK_DOMAIN syncIP_clk, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of IQtoRAM_RX_m_tdata : signal is "xilinx.com:interface:axis:1.0 IQtoRAM_RX_m TDATA";
  attribute X_INTERFACE_PARAMETER of IQtoRAM_RX_m_tdata : signal is "XIL_INTERFACENAME IQtoRAM_RX_m, CLK_DOMAIN syncIP_clk, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of IQtoRF_TX_m_tdata : signal is "xilinx.com:interface:axis:1.0 IQtoRF_TX_m TDATA";
  attribute X_INTERFACE_PARAMETER of IQtoRF_TX_m_tdata : signal is "XIL_INTERFACENAME IQtoRF_TX_m, CLK_DOMAIN syncIP_clk, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
begin
  IQfromRAM_TX_s_tready <= s_axis_dataFreqTX_1_TREADY;
  IQfromRF_RX_s_tready <= s_axis_dataTimeRX_1_TREADY;
  IQtoRAM_RX_m_tdata(31 downto 0) <= largeRXBuffer_M_AXIS_TDATA(31 downto 0);
  IQtoRAM_RX_m_tvalid <= largeRXBuffer_M_AXIS_TVALID;
  IQtoRF_TX_m_tdata(31 downto 0) <= sdrController_0_IQtoRF_TX_m_TDATA(31 downto 0);
  IQtoRF_TX_m_tvalid <= sdrController_0_IQtoRF_TX_m_TVALID;
  arstn_1 <= arstn;
  arstn_fast_1 <= arstn_fast;
  clk_1 <= clk;
  largeRXBuffer_M_AXIS_TREADY <= IQtoRAM_RX_m_tready;
  params_FIRcoef_addr_1(31 downto 0) <= params_FIRcoef_addr(31 downto 0);
  params_FIRcoef_imagValues_rd(31 downto 0) <= correlator_FIRcoef_imagValues_rd(31 downto 0);
  params_FIRcoef_imagValues_wr_1(31 downto 0) <= params_FIRcoef_imagValues_wr(31 downto 0);
  params_FIRcoef_realValues_rd(31 downto 0) <= correlator_FIRcoef_realValues_rd(31 downto 0);
  params_FIRcoef_realValues_wr_1(31 downto 0) <= params_FIRcoef_realValues_wr(31 downto 0);
  params_FIRcoef_wr_1 <= params_FIRcoef_wr;
  params_enableRXConf1_1(4 downto 0) <= params_enablePhaseEstConf(4 downto 0);
  params_enableRXConf2_1(4 downto 0) <= params_enablePhaseCorrConf(4 downto 0);
  params_enableRXConf3_1(4 downto 0) <= params_isConjugatedConf(4 downto 0);
  params_enableRXConf_1(4 downto 0) <= params_enableRXConf(4 downto 0);
  params_enableTXConf_1(4 downto 0) <= params_enableTXConf(4 downto 0);
  params_isConjugatedConf1_1(4 downto 0) <= params_addPhaseBiasConf(4 downto 0);
  params_isTXPathConf_1(4 downto 0) <= params_isTXPathConf(4 downto 0);
  params_numeratorkPhase_1(26 downto 0) <= params_numeratorkPhase(26 downto 0);
  params_sequenceSelConf_1(4 downto 0) <= params_sequenceSelConf(4 downto 0);
  params_timer1_Nofdm_1(15 downto 0) <= params_timer1_inSample(15 downto 0);
  params_timer2_Nofdm_1(15 downto 0) <= params_timer2_inSample(15 downto 0);
  params_timer3_Nofdm_1(15 downto 0) <= params_timer3_inSample(15 downto 0);
  params_timer4_Nofdm_1(15 downto 0) <= params_timer4_inSample(15 downto 0);
  rxFIFO_overflow <= largeRXBuffer_axis_overflow;
  s_axis_dataFreqTX_1_TDATA(31 downto 0) <= IQfromRAM_TX_s_tdata(31 downto 0);
  s_axis_dataFreqTX_1_TVALID <= IQfromRAM_TX_s_tvalid;
  s_axis_dataTimeRX_1_TDATA(31 downto 0) <= IQfromRF_RX_s_tdata(31 downto 0);
  s_axis_dataTimeRX_1_TVALID <= IQfromRF_RX_s_tvalid;
  status_myController(63 downto 0) <= sdrController_0_myController_status(63 downto 0);
  status_myDetector(351 downto 0) <= correlator_status_myDetector(351 downto 0);
  status_myPhaseEstimation(31 downto 0) <= phaseCompensation_myPhaseEstimation_status(31 downto 0);
largeRXBuffer: component syncIP_largeRXBuffer_0
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
myCorrelator_0: component syncIP_myCorrelator_0_0
     port map (
      i_FIRcoef_addr(31 downto 0) => params_FIRcoef_addr_1(31 downto 0),
      i_FIRcoef_imagValues_rd(31 downto 0) => correlator_FIRcoef_imagValues_rd(31 downto 0),
      i_FIRcoef_imagValues_wr(31 downto 0) => params_FIRcoef_imagValues_wr_1(31 downto 0),
      i_FIRcoef_realValues_rd(31 downto 0) => correlator_FIRcoef_realValues_rd(31 downto 0),
      i_FIRcoef_realValues_wr(31 downto 0) => params_FIRcoef_realValues_wr_1(31 downto 0),
      i_FIRcoef_wr => params_FIRcoef_wr_1,
      i_IQdata(23 downto 0) => sdrController_0_IQeffective(23 downto 0),
      i_IQdata_wr => sdrController_0_o_IQdata_wr,
      i_clk => clk_1,
      i_clk_fast => clk_fast,
      i_rstn => arstn_1,
      i_rstn_fast => arstn_fast_1,
      i_sequenceSel => sdrController_0_sequenceSel,
      o_FIRdata_imag_detected(26 downto 0) => correlator_imag_signed_detected_o(26 downto 0),
      o_FIRdata_real_detected(26 downto 0) => real_signed_detected_i_1(26 downto 0),
      o_detected => correlator_detectedRepeat,
      o_status_myDetector(351 downto 0) => correlator_status_myDetector(351 downto 0)
    );
phaseCompensation: entity work.phaseCompensation_imp_6RINKV
     port map (
      addPhaseBias_i => sdrController_0_addPhaseBias,
      arstn => arstn_1,
      clk => clk_1,
      data_IQrotated_o(31 downto 0) => phaseCompensation_data_IQrotated_o(31 downto 0),
      data_IQtoBeRotated_i(31 downto 0) => sdrController_0_data_IQtoBeRotated_o(31 downto 0),
      enablePhaseEs_i => sdrController_0_enablePhaseEst,
      imag_signed_detected_i(26 downto 0) => correlator_imag_signed_detected_o(26 downto 0),
      isConjugated_i => sdrController_0_isConjugated,
      numeratork_i(26 downto 0) => sdrController_0_numeratorkPhase_o(26 downto 0),
      real_signed_detected_i(26 downto 0) => real_signed_detected_i_1(26 downto 0),
      status_myPhaseEstimation(31 downto 0) => phaseCompensation_myPhaseEstimation_status(31 downto 0),
      syncDetected_i => correlator_detectedRepeat
    );
sdrController_0: component syncIP_sdrController_0_0
     port map (
      IQeffective(23 downto 0) => sdrController_0_IQeffective(23 downto 0),
      addPhaseBias => sdrController_0_addPhaseBias,
      addPhaseBiasConf(4 downto 0) => params_isConjugatedConf1_1(4 downto 0),
      arstn => arstn_1,
      clk => clk_1,
      data_IQfromRAM_TX_i(31 downto 0) => s_axis_dataFreqTX_1_TDATA(31 downto 0),
      data_IQfromRF_RX_i(31 downto 0) => s_axis_dataTimeRX_1_TDATA(31 downto 0),
      data_IQrotated_i(31 downto 0) => phaseCompensation_data_IQrotated_o(31 downto 0),
      data_IQtoBeRotated_o(31 downto 0) => sdrController_0_data_IQtoBeRotated_o(31 downto 0),
      data_IQtoRAM_RX_o(31 downto 0) => sdrController_0_IQtoRAM_RX_m_TDATA(31 downto 0),
      data_IQtoRF_TX_o(31 downto 0) => sdrController_0_IQtoRF_TX_m_TDATA(31 downto 0),
      enablePhaseCorrConf(4 downto 0) => params_enableRXConf2_1(4 downto 0),
      enablePhaseEst => sdrController_0_enablePhaseEst,
      enablePhaseEstConf(4 downto 0) => params_enableRXConf1_1(4 downto 0),
      enableRXconf(4 downto 0) => params_enableRXConf_1(4 downto 0),
      enableTXconf(4 downto 0) => params_enableTXConf_1(4 downto 0),
      fifoRX_count(14 downto 0) => largeRXBuffer_axis_data_count(14 downto 0),
      isConjugated => sdrController_0_isConjugated,
      isConjugatedConf(4 downto 0) => params_enableRXConf3_1(4 downto 0),
      isTXPathConf(4 downto 0) => params_isTXPathConf_1(4 downto 0),
      numeratorkPhase_i(26 downto 0) => params_numeratorkPhase_1(26 downto 0),
      numeratorkPhase_o(26 downto 0) => sdrController_0_numeratorkPhase_o(26 downto 0),
      o_IQdata_wr => sdrController_0_o_IQdata_wr,
      ready_IQfromRAM_TX_o => s_axis_dataFreqTX_1_TREADY,
      ready_IQfromRF_RX_o => s_axis_dataTimeRX_1_TREADY,
      sequenceSel => sdrController_0_sequenceSel,
      sequenceSelConf(4 downto 0) => params_sequenceSelConf_1(4 downto 0),
      status_myController(63 downto 0) => sdrController_0_myController_status(63 downto 0),
      syncDetected => correlator_detectedRepeat,
      timer1_inSample(15 downto 0) => params_timer1_Nofdm_1(15 downto 0),
      timer2_inSample(15 downto 0) => params_timer2_Nofdm_1(15 downto 0),
      timer3_inSample(15 downto 0) => params_timer3_Nofdm_1(15 downto 0),
      timer4_inSample(15 downto 0) => params_timer4_Nofdm_1(15 downto 0),
      valid_IQfromRAM_TX_i => s_axis_dataFreqTX_1_TVALID,
      valid_IQfromRF_RX_i => s_axis_dataTimeRX_1_TVALID,
      valid_IQtoRAM_RX_o => sdrController_0_IQtoRAM_RX_m_TVALID,
      valid_IQtoRF_TX_o => sdrController_0_IQtoRF_TX_m_TVALID
    );
end STRUCTURE;
