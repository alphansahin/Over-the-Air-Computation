----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2025 02:04:24 PM
-- Design Name: 
-- Module Name: basicSlicer - Behavioral
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

entity basicSlicer is
    Generic (
        dataInWidth : integer :=32;
        dataOut1Width : integer :=12;
        dataOut1Start : integer :=0;
        dataOut2Width : integer :=12;
        dataOut2Start : integer :=16
    );
    Port (
        data_in : in STD_LOGIC_VECTOR (dataInWidth-1 downto 0);
        dataOut1 : out STD_LOGIC_VECTOR (dataOut1Width-1 downto 0);
        dataOut2 : out STD_LOGIC_VECTOR (dataOut2Width-1 downto 0)
    );
end basicSlicer;

architecture Behavioral of basicSlicer is

begin
        dataOut1 <= data_in(dataOut1Start+dataOut1Width-1 downto dataOut1Start);
        dataOut2 <= data_in(dataOut2Start+dataOut2Width-1 downto dataOut2Start);

end Behavioral;
