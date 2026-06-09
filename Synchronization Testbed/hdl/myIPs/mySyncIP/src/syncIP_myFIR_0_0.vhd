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

-- IP VLNV: xilinx.com:module_ref:myFIR:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY syncIP_myFIR_0_0 IS
  PORT (
    i_clk : IN STD_LOGIC;
    FIRcoef_wr : IN STD_LOGIC;
    FIRcoef_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    FIRcoef_realValues_wr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    FIRcoef_imagValues_wr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    FIRcoef_realValues_rd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    FIRcoef_imagValues_rd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    sequenceSel : IN STD_LOGIC;
    status_myFIR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    readData : OUT STD_LOGIC;
    writeData : OUT STD_LOGIC;
    din_real : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    din_imag : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dout_real : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    dout_imag : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    i_clk_fast : IN STD_LOGIC;
    i_rst_n_fast : IN STD_LOGIC
  );
END syncIP_myFIR_0_0;

ARCHITECTURE syncIP_myFIR_0_0_arch OF syncIP_myFIR_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF syncIP_myFIR_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT myFIR IS
    GENERIC (
      NUM_STATUS_REGS : INTEGER;
      TDM_RATE : INTEGER;
      INPUT_DATA_WIDTH : INTEGER;
      COEFF_WIDTH : INTEGER;
      NUMBER_OF_TAPS : INTEGER;
      CLOG2_NUMBER_OF_TAPSi : INTEGER
    );
    PORT (
      i_clk : IN STD_LOGIC;
      FIRcoef_wr : IN STD_LOGIC;
      FIRcoef_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      FIRcoef_realValues_wr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      FIRcoef_imagValues_wr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      FIRcoef_realValues_rd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      FIRcoef_imagValues_rd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      sequenceSel : IN STD_LOGIC;
      status_myFIR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      readData : OUT STD_LOGIC;
      writeData : OUT STD_LOGIC;
      din_real : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      din_imag : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      dout_real : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
      dout_imag : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
      i_clk_fast : IN STD_LOGIC;
      i_rst_n_fast : IN STD_LOGIC
    );
  END COMPONENT myFIR;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF syncIP_myFIR_0_0_arch: ARCHITECTURE IS "myFIR,Vivado 2022.1";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF syncIP_myFIR_0_0_arch : ARCHITECTURE IS "syncIP_myFIR_0_0,myFIR,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF syncIP_myFIR_0_0_arch: ARCHITECTURE IS "syncIP_myFIR_0_0,myFIR,{x_ipProduct=Vivado 2022.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=myFIR,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,NUM_STATUS_REGS=1,TDM_RATE=8,INPUT_DATA_WIDTH=12,COEFF_WIDTH=8,NUMBER_OF_TAPS=64,CLOG2_NUMBER_OF_TAPSi=6}";
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF syncIP_myFIR_0_0_arch: ARCHITECTURE IS "module_ref";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF din_imag: SIGNAL IS "xilinx.com:user:axi_complex:1.0 din imag";
  ATTRIBUTE X_INTERFACE_INFO OF din_real: SIGNAL IS "xilinx.com:user:axi_complex:1.0 din real";
  ATTRIBUTE X_INTERFACE_INFO OF dout_imag: SIGNAL IS "xilinx.com:user:axi_complex:1.0 dout imag";
  ATTRIBUTE X_INTERFACE_INFO OF dout_real: SIGNAL IS "xilinx.com:user:axi_complex:1.0 dout real";
  ATTRIBUTE X_INTERFACE_PARAMETER OF i_clk: SIGNAL IS "XIL_INTERFACENAME i_clk, FREQ_HZ 10000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN syncIP_clk, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF i_clk: SIGNAL IS "xilinx.com:signal:clock:1.0 i_clk CLK";
BEGIN
  U0 : myFIR
    GENERIC MAP (
      NUM_STATUS_REGS => 1,
      TDM_RATE => 8,
      INPUT_DATA_WIDTH => 12,
      COEFF_WIDTH => 8,
      NUMBER_OF_TAPS => 64,
      CLOG2_NUMBER_OF_TAPSi => 6
    )
    PORT MAP (
      i_clk => i_clk,
      FIRcoef_wr => FIRcoef_wr,
      FIRcoef_addr => FIRcoef_addr,
      FIRcoef_realValues_wr => FIRcoef_realValues_wr,
      FIRcoef_imagValues_wr => FIRcoef_imagValues_wr,
      FIRcoef_realValues_rd => FIRcoef_realValues_rd,
      FIRcoef_imagValues_rd => FIRcoef_imagValues_rd,
      sequenceSel => sequenceSel,
      status_myFIR => status_myFIR,
      readData => readData,
      writeData => writeData,
      din_real => din_real,
      din_imag => din_imag,
      dout_real => dout_real,
      dout_imag => dout_imag,
      i_clk_fast => i_clk_fast,
      i_rst_n_fast => i_rst_n_fast
    );
END syncIP_myFIR_0_0_arch;
