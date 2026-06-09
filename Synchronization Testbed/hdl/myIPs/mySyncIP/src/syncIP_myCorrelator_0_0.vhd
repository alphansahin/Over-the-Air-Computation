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

-- IP VLNV: xilinx.com:module_ref:myCorrelator:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY syncIP_myCorrelator_0_0 IS
  PORT (
    i_FIRcoef_wr : IN STD_LOGIC;
    i_FIRcoef_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_FIRcoef_realValues_wr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_FIRcoef_imagValues_wr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_FIRcoef_realValues_rd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_FIRcoef_imagValues_rd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    i_sequenceSel : IN STD_LOGIC;
    i_IQdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    i_IQdata_wr : IN STD_LOGIC;
    i_clk : IN STD_LOGIC;
    i_rstn : IN STD_LOGIC;
    o_status_myDetector : OUT STD_LOGIC_VECTOR(351 DOWNTO 0);
    o_FIRdata_real_detected : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    o_FIRdata_imag_detected : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    o_detected : OUT STD_LOGIC;
    i_clk_fast : IN STD_LOGIC;
    i_rstn_fast : IN STD_LOGIC
  );
END syncIP_myCorrelator_0_0;

ARCHITECTURE syncIP_myCorrelator_0_0_arch OF syncIP_myCorrelator_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF syncIP_myCorrelator_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT myCorrelator IS
    GENERIC (
      NUM_STATUS_REGS : INTEGER;
      TDM_RATE : INTEGER;
      INPUT_DATA_WIDTH : INTEGER;
      COEFF_WIDTH : INTEGER;
      NUMBER_OF_TAPS : INTEGER;
      CLOG2_NUMBER_OF_TAPSi : INTEGER
    );
    PORT (
      i_FIRcoef_wr : IN STD_LOGIC;
      i_FIRcoef_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_FIRcoef_realValues_wr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_FIRcoef_imagValues_wr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_FIRcoef_realValues_rd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_FIRcoef_imagValues_rd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_sequenceSel : IN STD_LOGIC;
      i_IQdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      i_IQdata_wr : IN STD_LOGIC;
      i_clk : IN STD_LOGIC;
      i_rstn : IN STD_LOGIC;
      o_status_myDetector : OUT STD_LOGIC_VECTOR(351 DOWNTO 0);
      o_FIRdata_real_detected : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
      o_FIRdata_imag_detected : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
      o_detected : OUT STD_LOGIC;
      i_clk_fast : IN STD_LOGIC;
      i_rstn_fast : IN STD_LOGIC
    );
  END COMPONENT myCorrelator;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF syncIP_myCorrelator_0_0_arch: ARCHITECTURE IS "myCorrelator,Vivado 2022.1";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF syncIP_myCorrelator_0_0_arch : ARCHITECTURE IS "syncIP_myCorrelator_0_0,myCorrelator,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF syncIP_myCorrelator_0_0_arch: ARCHITECTURE IS "syncIP_myCorrelator_0_0,myCorrelator,{x_ipProduct=Vivado 2022.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=myCorrelator,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,NUM_STATUS_REGS=11,TDM_RATE=8,INPUT_DATA_WIDTH=12,COEFF_WIDTH=8,NUMBER_OF_TAPS=64,CLOG2_NUMBER_OF_TAPSi=6}";
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF syncIP_myCorrelator_0_0_arch: ARCHITECTURE IS "module_ref";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER OF i_clk: SIGNAL IS "XIL_INTERFACENAME i_clk, ASSOCIATED_RESET i_rstn, FREQ_HZ 10000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN syncIP_clk, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF i_clk: SIGNAL IS "xilinx.com:signal:clock:1.0 i_clk CLK";
  ATTRIBUTE X_INTERFACE_PARAMETER OF i_rstn: SIGNAL IS "XIL_INTERFACENAME i_rstn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF i_rstn: SIGNAL IS "xilinx.com:signal:reset:1.0 i_rstn RST";
  ATTRIBUTE X_INTERFACE_INFO OF o_FIRdata_imag_detected: SIGNAL IS "xilinx.com:user:axi_complex:1.0 o_FIRdata_detected imag";
  ATTRIBUTE X_INTERFACE_INFO OF o_FIRdata_real_detected: SIGNAL IS "xilinx.com:user:axi_complex:1.0 o_FIRdata_detected real";
BEGIN
  U0 : myCorrelator
    GENERIC MAP (
      NUM_STATUS_REGS => 11,
      TDM_RATE => 8,
      INPUT_DATA_WIDTH => 12,
      COEFF_WIDTH => 8,
      NUMBER_OF_TAPS => 64,
      CLOG2_NUMBER_OF_TAPSi => 6
    )
    PORT MAP (
      i_FIRcoef_wr => i_FIRcoef_wr,
      i_FIRcoef_addr => i_FIRcoef_addr,
      i_FIRcoef_realValues_wr => i_FIRcoef_realValues_wr,
      i_FIRcoef_imagValues_wr => i_FIRcoef_imagValues_wr,
      i_FIRcoef_realValues_rd => i_FIRcoef_realValues_rd,
      i_FIRcoef_imagValues_rd => i_FIRcoef_imagValues_rd,
      i_sequenceSel => i_sequenceSel,
      i_IQdata => i_IQdata,
      i_IQdata_wr => i_IQdata_wr,
      i_clk => i_clk,
      i_rstn => i_rstn,
      o_status_myDetector => o_status_myDetector,
      o_FIRdata_real_detected => o_FIRdata_real_detected,
      o_FIRdata_imag_detected => o_FIRdata_imag_detected,
      o_detected => o_detected,
      i_clk_fast => i_clk_fast,
      i_rstn_fast => i_rstn_fast
    );
END syncIP_myCorrelator_0_0_arch;
