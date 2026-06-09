-- (c) Copyright 1995-2025 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:module_ref:sdrController:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY myFreqSDR_sdrController_0_0 IS
  PORT (
    data_IQfromRF_RX_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    valid_IQfromRF_RX_i : IN STD_LOGIC;
    ready_IQfromRF_RX_o : OUT STD_LOGIC;
    data_IQtoRAM_RX_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    valid_IQtoRAM_RX_o : OUT STD_LOGIC;
    data_IQfromRAM_TX_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    valid_IQfromRAM_TX_i : IN STD_LOGIC;
    ready_IQfromRAM_TX_o : OUT STD_LOGIC;
    data_IQtoRF_TX_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    valid_IQtoRF_TX_o : OUT STD_LOGIC;
    FIRimag_reload_last : OUT STD_LOGIC;
    FIRimag_reload_ready : IN STD_LOGIC;
    FIRimag_reload_valid : OUT STD_LOGIC;
    FIRimag_reload_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    FIRimag_config_ready : IN STD_LOGIC;
    FIRimag_config_valid : OUT STD_LOGIC;
    FIRimag_config_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    FIRreal_reload_last : OUT STD_LOGIC;
    FIRreal_reload_ready : IN STD_LOGIC;
    FIRreal_reload_valid : OUT STD_LOGIC;
    FIRreal_reload_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    FIRreal_config_ready : IN STD_LOGIC;
    FIRreal_config_valid : OUT STD_LOGIC;
    FIRreal_config_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    FIRimag_data_valid : OUT STD_LOGIC;
    FIRimag_data_ready : IN STD_LOGIC;
    FIRimag_data_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    FIRreal_data_valid : OUT STD_LOGIC;
    FIRreal_data_ready : IN STD_LOGIC;
    FIRreal_data_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    IQeffective : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    FIRreal_arst_o : OUT STD_LOGIC;
    FIRimag_arst_o : OUT STD_LOGIC;
    syncDetected : IN STD_LOGIC;
    timer1_inSample : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    timer2_inSample : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    timer3_inSample : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    timer4_inSample : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    enableRXconf : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    enableTXconf : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    isTXPathConf : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    sequenceSelConf : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    coefReal0 : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
    coefReal1 : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
    coefImag0 : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
    coefImag1 : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
    enableRX : OUT STD_LOGIC;
    enableTX : OUT STD_LOGIC;
    isTXPath : OUT STD_LOGIC;
    sequenceSel : OUT STD_LOGIC;
    cntDetectionAsMode : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    clk : IN STD_LOGIC;
    arstn : IN STD_LOGIC
  );
END myFreqSDR_sdrController_0_0;

ARCHITECTURE myFreqSDR_sdrController_0_0_arch OF myFreqSDR_sdrController_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF myFreqSDR_sdrController_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT sdrController IS
    GENERIC (
      log2_number_Of_FIR_coefficients : INTEGER;
      bitWidth_FIR_coefficients : INTEGER
    );
    PORT (
      data_IQfromRF_RX_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      valid_IQfromRF_RX_i : IN STD_LOGIC;
      ready_IQfromRF_RX_o : OUT STD_LOGIC;
      data_IQtoRAM_RX_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      valid_IQtoRAM_RX_o : OUT STD_LOGIC;
      data_IQfromRAM_TX_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      valid_IQfromRAM_TX_i : IN STD_LOGIC;
      ready_IQfromRAM_TX_o : OUT STD_LOGIC;
      data_IQtoRF_TX_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      valid_IQtoRF_TX_o : OUT STD_LOGIC;
      FIRimag_reload_last : OUT STD_LOGIC;
      FIRimag_reload_ready : IN STD_LOGIC;
      FIRimag_reload_valid : OUT STD_LOGIC;
      FIRimag_reload_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      FIRimag_config_ready : IN STD_LOGIC;
      FIRimag_config_valid : OUT STD_LOGIC;
      FIRimag_config_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      FIRreal_reload_last : OUT STD_LOGIC;
      FIRreal_reload_ready : IN STD_LOGIC;
      FIRreal_reload_valid : OUT STD_LOGIC;
      FIRreal_reload_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      FIRreal_config_ready : IN STD_LOGIC;
      FIRreal_config_valid : OUT STD_LOGIC;
      FIRreal_config_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      FIRimag_data_valid : OUT STD_LOGIC;
      FIRimag_data_ready : IN STD_LOGIC;
      FIRimag_data_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      FIRreal_data_valid : OUT STD_LOGIC;
      FIRreal_data_ready : IN STD_LOGIC;
      FIRreal_data_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      IQeffective : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      FIRreal_arst_o : OUT STD_LOGIC;
      FIRimag_arst_o : OUT STD_LOGIC;
      syncDetected : IN STD_LOGIC;
      timer1_inSample : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      timer2_inSample : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      timer3_inSample : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      timer4_inSample : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      enableRXconf : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      enableTXconf : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      isTXPathConf : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      sequenceSelConf : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      coefReal0 : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
      coefReal1 : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
      coefImag0 : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
      coefImag1 : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
      enableRX : OUT STD_LOGIC;
      enableTX : OUT STD_LOGIC;
      isTXPath : OUT STD_LOGIC;
      sequenceSel : OUT STD_LOGIC;
      cntDetectionAsMode : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      clk : IN STD_LOGIC;
      arstn : IN STD_LOGIC
    );
  END COMPONENT sdrController;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF myFreqSDR_sdrController_0_0_arch: ARCHITECTURE IS "sdrController,Vivado 2022.1";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF myFreqSDR_sdrController_0_0_arch : ARCHITECTURE IS "myFreqSDR_sdrController_0_0,sdrController,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF myFreqSDR_sdrController_0_0_arch: ARCHITECTURE IS "myFreqSDR_sdrController_0_0,sdrController,{x_ipProduct=Vivado 2022.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=sdrController,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,log2_number_Of_FIR_coefficients=4,bitWidth_FIR_coefficients=6}";
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF myFreqSDR_sdrController_0_0_arch: ARCHITECTURE IS "module_ref";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF FIRimag_config_data: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRimag_config TDATA";
  ATTRIBUTE X_INTERFACE_PARAMETER OF FIRimag_config_ready: SIGNAL IS "XIL_INTERFACENAME FIRimag_config, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN myFreqSDR_clk, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF FIRimag_config_ready: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRimag_config TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF FIRimag_config_valid: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRimag_config TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF FIRimag_data_data: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRimag_data TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF FIRimag_data_ready: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRimag_data TREADY";
  ATTRIBUTE X_INTERFACE_PARAMETER OF FIRimag_data_valid: SIGNAL IS "XIL_INTERFACENAME FIRimag_data, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN myFreqSDR_clk, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF FIRimag_data_valid: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRimag_data TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF FIRimag_reload_data: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRimag_reload TDATA";
  ATTRIBUTE X_INTERFACE_PARAMETER OF FIRimag_reload_last: SIGNAL IS "XIL_INTERFACENAME FIRimag_reload, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN myFreqSDR_clk, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF FIRimag_reload_last: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRimag_reload TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF FIRimag_reload_ready: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRimag_reload TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF FIRimag_reload_valid: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRimag_reload TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF FIRreal_config_data: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRreal_config TDATA";
  ATTRIBUTE X_INTERFACE_PARAMETER OF FIRreal_config_ready: SIGNAL IS "XIL_INTERFACENAME FIRreal_config, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN myFreqSDR_clk, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF FIRreal_config_ready: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRreal_config TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF FIRreal_config_valid: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRreal_config TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF FIRreal_data_data: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRreal_data TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF FIRreal_data_ready: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRreal_data TREADY";
  ATTRIBUTE X_INTERFACE_PARAMETER OF FIRreal_data_valid: SIGNAL IS "XIL_INTERFACENAME FIRreal_data, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN myFreqSDR_clk, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF FIRreal_data_valid: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRreal_data TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF FIRreal_reload_data: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRreal_reload TDATA";
  ATTRIBUTE X_INTERFACE_PARAMETER OF FIRreal_reload_last: SIGNAL IS "XIL_INTERFACENAME FIRreal_reload, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN myFreqSDR_clk, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF FIRreal_reload_last: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRreal_reload TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF FIRreal_reload_ready: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRreal_reload TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF FIRreal_reload_valid: SIGNAL IS "xilinx.com:interface:axis:1.0 FIRreal_reload TVALID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF clk: SIGNAL IS "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF IQfromRF_RX_s:IQtoRAM_RX_m:IQfromRAM_TX_s:IQtoRF_TX_m:FIRimag_reload:FIRimag_config:FIRreal_reload:FIRreal_config:FIRimag_data:FIRreal_data, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN myFreqSDR_clk, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF clk: SIGNAL IS "xilinx.com:signal:clock:1.0 clk CLK";
  ATTRIBUTE X_INTERFACE_PARAMETER OF data_IQfromRAM_TX_i: SIGNAL IS "XIL_INTERFACENAME IQfromRAM_TX_s, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN myFreqSDR_clk, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF data_IQfromRAM_TX_i: SIGNAL IS "xilinx.com:interface:axis:1.0 IQfromRAM_TX_s TDATA";
  ATTRIBUTE X_INTERFACE_PARAMETER OF data_IQfromRF_RX_i: SIGNAL IS "XIL_INTERFACENAME IQfromRF_RX_s, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN myFreqSDR_clk, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF data_IQfromRF_RX_i: SIGNAL IS "xilinx.com:interface:axis:1.0 IQfromRF_RX_s TDATA";
  ATTRIBUTE X_INTERFACE_PARAMETER OF data_IQtoRAM_RX_o: SIGNAL IS "XIL_INTERFACENAME IQtoRAM_RX_m, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN myFreqSDR_clk, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF data_IQtoRAM_RX_o: SIGNAL IS "xilinx.com:interface:axis:1.0 IQtoRAM_RX_m TDATA";
  ATTRIBUTE X_INTERFACE_PARAMETER OF data_IQtoRF_TX_o: SIGNAL IS "XIL_INTERFACENAME IQtoRF_TX_m, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN myFreqSDR_clk, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF data_IQtoRF_TX_o: SIGNAL IS "xilinx.com:interface:axis:1.0 IQtoRF_TX_m TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF ready_IQfromRAM_TX_o: SIGNAL IS "xilinx.com:interface:axis:1.0 IQfromRAM_TX_s TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF ready_IQfromRF_RX_o: SIGNAL IS "xilinx.com:interface:axis:1.0 IQfromRF_RX_s TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF valid_IQfromRAM_TX_i: SIGNAL IS "xilinx.com:interface:axis:1.0 IQfromRAM_TX_s TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF valid_IQfromRF_RX_i: SIGNAL IS "xilinx.com:interface:axis:1.0 IQfromRF_RX_s TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF valid_IQtoRAM_RX_o: SIGNAL IS "xilinx.com:interface:axis:1.0 IQtoRAM_RX_m TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF valid_IQtoRF_TX_o: SIGNAL IS "xilinx.com:interface:axis:1.0 IQtoRF_TX_m TVALID";
BEGIN
  U0 : sdrController
    GENERIC MAP (
      log2_number_Of_FIR_coefficients => 4,
      bitWidth_FIR_coefficients => 6
    )
    PORT MAP (
      data_IQfromRF_RX_i => data_IQfromRF_RX_i,
      valid_IQfromRF_RX_i => valid_IQfromRF_RX_i,
      ready_IQfromRF_RX_o => ready_IQfromRF_RX_o,
      data_IQtoRAM_RX_o => data_IQtoRAM_RX_o,
      valid_IQtoRAM_RX_o => valid_IQtoRAM_RX_o,
      data_IQfromRAM_TX_i => data_IQfromRAM_TX_i,
      valid_IQfromRAM_TX_i => valid_IQfromRAM_TX_i,
      ready_IQfromRAM_TX_o => ready_IQfromRAM_TX_o,
      data_IQtoRF_TX_o => data_IQtoRF_TX_o,
      valid_IQtoRF_TX_o => valid_IQtoRF_TX_o,
      FIRimag_reload_last => FIRimag_reload_last,
      FIRimag_reload_ready => FIRimag_reload_ready,
      FIRimag_reload_valid => FIRimag_reload_valid,
      FIRimag_reload_data => FIRimag_reload_data,
      FIRimag_config_ready => FIRimag_config_ready,
      FIRimag_config_valid => FIRimag_config_valid,
      FIRimag_config_data => FIRimag_config_data,
      FIRreal_reload_last => FIRreal_reload_last,
      FIRreal_reload_ready => FIRreal_reload_ready,
      FIRreal_reload_valid => FIRreal_reload_valid,
      FIRreal_reload_data => FIRreal_reload_data,
      FIRreal_config_ready => FIRreal_config_ready,
      FIRreal_config_valid => FIRreal_config_valid,
      FIRreal_config_data => FIRreal_config_data,
      FIRimag_data_valid => FIRimag_data_valid,
      FIRimag_data_ready => FIRimag_data_ready,
      FIRimag_data_data => FIRimag_data_data,
      FIRreal_data_valid => FIRreal_data_valid,
      FIRreal_data_ready => FIRreal_data_ready,
      FIRreal_data_data => FIRreal_data_data,
      IQeffective => IQeffective,
      FIRreal_arst_o => FIRreal_arst_o,
      FIRimag_arst_o => FIRimag_arst_o,
      syncDetected => syncDetected,
      timer1_inSample => timer1_inSample,
      timer2_inSample => timer2_inSample,
      timer3_inSample => timer3_inSample,
      timer4_inSample => timer4_inSample,
      enableRXconf => enableRXconf,
      enableTXconf => enableTXconf,
      isTXPathConf => isTXPathConf,
      sequenceSelConf => sequenceSelConf,
      coefReal0 => coefReal0,
      coefReal1 => coefReal1,
      coefImag0 => coefImag0,
      coefImag1 => coefImag1,
      enableRX => enableRX,
      enableTX => enableTX,
      isTXPath => isTXPath,
      sequenceSel => sequenceSel,
      cntDetectionAsMode => cntDetectionAsMode,
      clk => clk,
      arstn => arstn
    );
END myFreqSDR_sdrController_0_0_arch;
