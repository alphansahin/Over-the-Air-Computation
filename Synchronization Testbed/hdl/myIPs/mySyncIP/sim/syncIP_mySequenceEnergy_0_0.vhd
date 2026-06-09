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

-- IP VLNV: xilinx.com:module_ref:mySequenceEnergy:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY syncIP_mySequenceEnergy_0_0 IS
  PORT (
    IQ_realImag_in : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    FIR_realImag_in : IN STD_LOGIC_VECTOR(53 DOWNTO 0);
    dout_FIRreal : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    dout_FIRimag : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    dout_xcorrSquareUnsigned : OUT STD_LOGIC_VECTOR(53 DOWNTO 0);
    dout_normSquareUnsigned : OUT STD_LOGIC_VECTOR(29 DOWNTO 0);
    i_clk : IN STD_LOGIC;
    i_rst_n : IN STD_LOGIC
  );
END syncIP_mySequenceEnergy_0_0;

ARCHITECTURE syncIP_mySequenceEnergy_0_0_arch OF syncIP_mySequenceEnergy_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF syncIP_mySequenceEnergy_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT mySequenceEnergy IS
    GENERIC (
      TDM_RATE : INTEGER;
      INPUT_DATA_WIDTH : INTEGER;
      COEFF_WIDTH : INTEGER;
      NUMBER_OF_TAPS : INTEGER;
      CLOG2_NUMBER_OF_TAPS : INTEGER
    );
    PORT (
      IQ_realImag_in : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      FIR_realImag_in : IN STD_LOGIC_VECTOR(53 DOWNTO 0);
      dout_FIRreal : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
      dout_FIRimag : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
      dout_xcorrSquareUnsigned : OUT STD_LOGIC_VECTOR(53 DOWNTO 0);
      dout_normSquareUnsigned : OUT STD_LOGIC_VECTOR(29 DOWNTO 0);
      i_clk : IN STD_LOGIC;
      i_rst_n : IN STD_LOGIC
    );
  END COMPONENT mySequenceEnergy;
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER OF i_clk: SIGNAL IS "XIL_INTERFACENAME i_clk, ASSOCIATED_RESET i_rst_n, FREQ_HZ 10000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN syncIP_clk, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF i_clk: SIGNAL IS "xilinx.com:signal:clock:1.0 i_clk CLK";
  ATTRIBUTE X_INTERFACE_PARAMETER OF i_rst_n: SIGNAL IS "XIL_INTERFACENAME i_rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF i_rst_n: SIGNAL IS "xilinx.com:signal:reset:1.0 i_rst_n RST";
BEGIN
  U0 : mySequenceEnergy
    GENERIC MAP (
      TDM_RATE => 8,
      INPUT_DATA_WIDTH => 12,
      COEFF_WIDTH => 8,
      NUMBER_OF_TAPS => 64,
      CLOG2_NUMBER_OF_TAPS => 6
    )
    PORT MAP (
      IQ_realImag_in => IQ_realImag_in,
      FIR_realImag_in => FIR_realImag_in,
      dout_FIRreal => dout_FIRreal,
      dout_FIRimag => dout_FIRimag,
      dout_xcorrSquareUnsigned => dout_xcorrSquareUnsigned,
      dout_normSquareUnsigned => dout_normSquareUnsigned,
      i_clk => i_clk,
      i_rst_n => i_rst_n
    );
END syncIP_mySequenceEnergy_0_0_arch;
