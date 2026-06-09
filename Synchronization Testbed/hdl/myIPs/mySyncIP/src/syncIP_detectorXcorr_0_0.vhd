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

-- IP VLNV: xilinx.com:module_ref:detectorXcorr:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY syncIP_detectorXcorr_0_0 IS
  PORT (
    real_signed_i : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    imag_signed_i : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    real_signed_detected_o : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    imag_signed_detected_o : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    xcorrSquare_i : IN STD_LOGIC_VECTOR(53 DOWNTO 0);
    normSquare_i : IN STD_LOGIC_VECTOR(29 DOWNTO 0);
    detectedRepeat : OUT STD_LOGIC;
    status_myDetector : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
    clk : IN STD_LOGIC;
    arstn : IN STD_LOGIC
  );
END syncIP_detectorXcorr_0_0;

ARCHITECTURE syncIP_detectorXcorr_0_0_arch OF syncIP_detectorXcorr_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF syncIP_detectorXcorr_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT detectorXcorr IS
    GENERIC (
      NUM_STATUS_REGS : INTEGER;
      log2_of_norm_square_filter_coeffs : INTEGER;
      log2_of_1_over_threshold : INTEGER;
      inputLength : INTEGER;
      bitWidth_xcorrSquare_in : INTEGER;
      bitWidth_normSquare_in : INTEGER
    );
    PORT (
      real_signed_i : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
      imag_signed_i : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
      real_signed_detected_o : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
      imag_signed_detected_o : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
      xcorrSquare_i : IN STD_LOGIC_VECTOR(53 DOWNTO 0);
      normSquare_i : IN STD_LOGIC_VECTOR(29 DOWNTO 0);
      detectedRepeat : OUT STD_LOGIC;
      status_myDetector : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
      clk : IN STD_LOGIC;
      arstn : IN STD_LOGIC
    );
  END COMPONENT detectorXcorr;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF syncIP_detectorXcorr_0_0_arch: ARCHITECTURE IS "detectorXcorr,Vivado 2022.1";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF syncIP_detectorXcorr_0_0_arch : ARCHITECTURE IS "syncIP_detectorXcorr_0_0,detectorXcorr,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF syncIP_detectorXcorr_0_0_arch: ARCHITECTURE IS "syncIP_detectorXcorr_0_0,detectorXcorr,{x_ipProduct=Vivado 2022.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=detectorXcorr,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,NUM_STATUS_REGS=8,log2_of_norm_square_filter_coeffs=20,log2_of_1_over_threshold=2,inputLength=27,bitWidth_xcorrSquare_in=54,bitWidth_normSquare_in=30}";
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF syncIP_detectorXcorr_0_0_arch: ARCHITECTURE IS "module_ref";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER OF clk: SIGNAL IS "XIL_INTERFACENAME clk, FREQ_HZ 10000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN syncIP_clk, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF clk: SIGNAL IS "xilinx.com:signal:clock:1.0 clk CLK";
BEGIN
  U0 : detectorXcorr
    GENERIC MAP (
      NUM_STATUS_REGS => 8,
      log2_of_norm_square_filter_coeffs => 20,
      log2_of_1_over_threshold => 2,
      inputLength => 27,
      bitWidth_xcorrSquare_in => 54,
      bitWidth_normSquare_in => 30
    )
    PORT MAP (
      real_signed_i => real_signed_i,
      imag_signed_i => imag_signed_i,
      real_signed_detected_o => real_signed_detected_o,
      imag_signed_detected_o => imag_signed_detected_o,
      xcorrSquare_i => xcorrSquare_i,
      normSquare_i => normSquare_i,
      detectedRepeat => detectedRepeat,
      status_myDetector => status_myDetector,
      clk => clk,
      arstn => arstn
    );
END syncIP_detectorXcorr_0_0_arch;
