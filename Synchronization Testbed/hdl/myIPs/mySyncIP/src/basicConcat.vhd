----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/08/2025 11:59:00 AM
-- Design Name: 
-- Module Name: basicConcat - Behavioral
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

entity basicConcat is
    Generic (
        dataOutWidth : integer :=32;
        dataIn1Width : integer :=12;
        dataIn1Start : integer :=0;
        dataIn2Width : integer :=12;
        dataIn2Start : integer :=16
    );
    Port (
        dataOut : out STD_LOGIC_VECTOR (dataOutWidth-1 downto 0);
        dataIn1 : in STD_LOGIC_VECTOR (dataIn1Width-1 downto 0);
        dataIn2 : in STD_LOGIC_VECTOR (dataIn2Width-1 downto 0)
    );
end basicConcat;

architecture Behavioral of basicConcat is

    signal dataOut_r: STD_LOGIC_VECTOR (dataOutWidth-1 downto 0):= (others => '0');
begin

    dataOut_r(dataIn2Start+dataIn2Width-1 downto dataIn2Start) <= dataIn2;
    dataOut_r(dataIn1Start+dataIn1Width-1 downto dataIn1Start) <= dataIn1;
    dataOut <= dataOut_r;

end Behavioral;
