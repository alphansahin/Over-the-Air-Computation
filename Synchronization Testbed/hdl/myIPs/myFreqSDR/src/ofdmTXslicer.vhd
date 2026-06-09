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

entity ofdmTXslicer is
    Port (
        data_in : in STD_LOGIC_VECTOR (47 downto 0);
        sel: in STD_LOGIC_VECTOR (2 downto 0);
        inphase_out : out STD_LOGIC_VECTOR (15 downto 0);
        quadrature_out : out STD_LOGIC_VECTOR (15 downto 0)
    );
end ofdmTXslicer;

architecture Behavioral of ofdmTXslicer is
    signal inphase_full : STD_LOGIC_VECTOR (data_in'length/2-1 downto 0);
    signal quadrature_full : STD_LOGIC_VECTOR (data_in'length/2-1 downto 0);
    constant numberOfDACbits: integer := 16;
begin
    inphase_full <= data_in(data_in'length/2-1 downto 0);
    quadrature_full <= data_in(data_in'length-1 downto data_in'length/2);

    slicer : process(sel,inphase_full,quadrature_full)
    begin
        case sel is
            when "000" =>
                inphase_out <= inphase_full(numberOfDACbits-1+0 downto 0);
                quadrature_out <= quadrature_full(numberOfDACbits-1+0 downto 0);
            when "001" =>
                inphase_out <= inphase_full(numberOfDACbits-1+1 downto 1);
                quadrature_out <= quadrature_full(numberOfDACbits-1+1 downto 1);
            when "010" =>
                inphase_out <= inphase_full(numberOfDACbits-1+2 downto 2);
                quadrature_out <= quadrature_full(numberOfDACbits-1+2 downto 2);
            when "011" =>
                inphase_out <= inphase_full(numberOfDACbits-1+3 downto 3);
                quadrature_out <= quadrature_full(numberOfDACbits-1+3 downto 3);
            when "100" =>
                inphase_out <= inphase_full(numberOfDACbits-1+4 downto 4);
                quadrature_out <= quadrature_full(numberOfDACbits-1+4 downto 4);
            when "101" =>
                inphase_out <= inphase_full(numberOfDACbits-1+5 downto 5);
                quadrature_out <= quadrature_full(numberOfDACbits-1+5 downto 5);
            when "110" =>
                inphase_out <= inphase_full(numberOfDACbits-1+6 downto 6);
                quadrature_out <= quadrature_full(numberOfDACbits-1+6 downto 6);
            when others =>
                inphase_out <= inphase_full(numberOfDACbits-1+7 downto 7);
                quadrature_out <= quadrature_full(numberOfDACbits-1+7 downto 7);
        end case;
    end process;
end Behavioral;
