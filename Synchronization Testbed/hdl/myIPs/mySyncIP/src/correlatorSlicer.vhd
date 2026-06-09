----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2025 02:48:27 PM
-- Design Name: 
-- Module Name: correlatorSlicer - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity correlatorSlicer is
    Port (
        inphase_tx_in : in STD_LOGIC_VECTOR (15 downto 0);
        quadrature_tx_in : in STD_LOGIC_VECTOR (15 downto 0);
        inphase_rx_in : in STD_LOGIC_VECTOR (15 downto 0);
        quadrature_rx_in : in STD_LOGIC_VECTOR (15 downto 0);
        isTXpath: in std_logic;
        inphase_out : out STD_LOGIC_VECTOR (11 downto 0);
        quadrature_out : out STD_LOGIC_VECTOR (11 downto 0);
        iqConcat_out : out STD_LOGIC_VECTOR (31 downto 0);
        iqConcatNoPadding_out : out STD_LOGIC_VECTOR (23 downto 0)
    );
end correlatorSlicer;

architecture Behavioral of correlatorSlicer is
    signal inphase_reg :  STD_LOGIC_VECTOR (11 downto 0);
    signal quadrature_reg : STD_LOGIC_VECTOR (11 downto 0);
begin
    iqConcat_out <= b"0000" & quadrature_reg  & b"0000" & inphase_reg;
    iqConcatNoPadding_out <= quadrature_reg  & inphase_reg;
    quadrature_out <= quadrature_reg;
    inphase_out <= inphase_reg;
    process(isTXpath,inphase_tx_in,quadrature_tx_in,inphase_rx_in,quadrature_rx_in)
    begin
        case isTXpath is
            when '1' =>
                inphase_reg <= inphase_tx_in(15 downto 4);
                quadrature_reg <= quadrature_tx_in(15 downto 4);
            when others =>
                inphase_reg <= inphase_rx_in(11 downto 0);
                quadrature_reg <= quadrature_rx_in(11 downto 0);
        end case;

    end process;

end Behavioral;
