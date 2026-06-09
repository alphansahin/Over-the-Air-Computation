----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2025 11:24:09 AM
-- Design Name: 
-- Module Name: normSquare - Behavioral
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
-- arithmetic functions with Signed or Unsigned architecture
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity normSquare is
    generic(
        inputLength: integer := 8
    );
    port (
        real_signed_i : in std_logic_vector(inputLength-1 downto 0);
        imag_signed_i : in std_logic_vector(inputLength-1 downto 0);
        norm_unsigned_o : out std_logic_vector(2*inputLength-1 downto 0);
        clk: in std_logic;
        arstn: in std_logic
    );
end normSquare;

architecture behavioral of normSquare is


    signal realabs_r : unsigned(inputLength-1 downto 0);
    signal imagabs_r : unsigned(inputLength-1 downto 0);
    signal realSquare_r : unsigned(2*inputLength-1 downto 0);
    signal imagSquare_r : unsigned(2*inputLength-1 downto 0);
    signal norm_r : unsigned(2*inputLength-1 downto 0);
    
    attribute use_dsp : string;
    attribute use_dsp of realSquare_r : signal is "no";
    attribute use_dsp of imagSquare_r : signal is "no" ;   
begin
    realabs_r <= unsigned(abs(signed(real_signed_i)));
    imagabs_r <= unsigned(abs(signed(imag_signed_i)));
    norm_unsigned_o <= std_logic_vector(norm_r);

    process(clk,arstn)
    begin
        if(arstn='0') then
            realSquare_r   <= (others=>'0');
            imagSquare_r   <= (others=>'0');
            norm_r   <= (others=>'0');
        elsif(rising_edge(clk)) then
                realSquare_r <= realabs_r * realabs_r; -- square the number
                imagSquare_r <= imagabs_r * imagabs_r; -- square the number
                norm_r <= realSquare_r + imagSquare_r; -- add the numbers
        end if;
    end process;


end architecture;