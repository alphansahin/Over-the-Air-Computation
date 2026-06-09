----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2025 05:44:23 PM
-- Design Name: 
-- Module Name: slicerIQ - Behavioral
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
use ieee.math_real.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ofdmRXslicer is
    Port (
        data_in : in STD_LOGIC_VECTOR (47 downto 0);
        sel: in STD_LOGIC_VECTOR (1 downto 0);
         dataFreq_real_out : out STD_LOGIC_VECTOR (15 downto 0);
         dataFreq_imag_out : out STD_LOGIC_VECTOR (15 downto 0)
    );
end ofdmRXslicer;

architecture Behavioral of ofdmRXslicer is
    signal dataFreq_real_full : STD_LOGIC_VECTOR (data_in'length/2-1 downto 0);
    signal dataFreq_imag_full : STD_LOGIC_VECTOR (data_in'length/2-1 downto 0);
    constant numberOfBits: integer := 16;
begin
    dataFreq_real_full <= data_in(data_in'length/2-1 downto 0);
    dataFreq_imag_full <= data_in(data_in'length-1 downto data_in'length/2);

    slicer : process(sel,dataFreq_real_full,dataFreq_imag_full)
    begin
        case sel is
            when "00" =>
                dataFreq_real_out <= dataFreq_real_full(numberOfBits-1+0 downto 0);
                dataFreq_imag_out <= dataFreq_imag_full(numberOfBits-1+0 downto 0);
            when "01" =>
                dataFreq_real_out <= dataFreq_real_full(numberOfBits-1+1 downto 1);
                dataFreq_imag_out <= dataFreq_imag_full(numberOfBits-1+1 downto 1);
            when "10" =>
                dataFreq_real_out <= dataFreq_real_full(numberOfBits-1+2 downto 2);
                dataFreq_imag_out <= dataFreq_imag_full(numberOfBits-1+2 downto 2);
            when others =>
                dataFreq_real_out <= dataFreq_real_full(numberOfBits-1+3 downto 3);
                dataFreq_imag_out <= dataFreq_imag_full(numberOfBits-1+3 downto 3);
        end case;
    end process;
end Behavioral;
