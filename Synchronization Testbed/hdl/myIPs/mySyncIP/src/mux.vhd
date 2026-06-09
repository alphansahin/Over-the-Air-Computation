----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/23/2022 01:27:00 PM
-- Design Name: 
-- Module Name: myMapper - Behavioral
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
use IEEE.numeric_std.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux is
	generic (
		dataOutSize: integer := 1
	);
    port ( dataOut : out STD_LOGIC_VECTOR (dataOutSize-1 downto 0);
           dataIn0 : in STD_LOGIC_VECTOR (dataOutSize-1 downto 0);
           dataIn1 : in STD_LOGIC_VECTOR (dataOutSize-1 downto 0);
           selectIn: in STD_LOGIC);
end mux;

architecture Behavioral of mux is

begin
  process (selectIn,dataIn0,dataIn1)  begin
        if selectIn = '0' then
            dataout <= dataIn0;
        else
            dataout <= dataIn1;
        end if;
    end process;
end Behavioral;
