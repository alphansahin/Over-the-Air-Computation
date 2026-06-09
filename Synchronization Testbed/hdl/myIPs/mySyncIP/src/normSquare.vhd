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
        i_real_signed : in std_logic_vector(inputLength-1 downto 0);
        i_imag_signed : in std_logic_vector(inputLength-1 downto 0);
        o_norm : out std_logic_vector(2*inputLength downto 0);
        i_enable: in std_logic;
        i_clk: in std_logic;
        i_arstn: in std_logic
    );
end normSquare;

architecture behavioral of normSquare is

    signal r_realabs : signed(inputLength-1 downto 0);
    signal r_imagabs : signed(inputLength-1 downto 0);
    signal r_realSquare : signed(2*inputLength-1 downto 0);
    signal r_imagSquare : signed(2*inputLength-1 downto 0);
    signal r_norm : signed(2*inputLength downto 0);

    attribute use_dsp : string;
    attribute use_dsp of r_realSquare : signal is "yes";
    attribute use_dsp of r_imagSquare : signal is "yes" ;
    --attribute use_dsp of r_norm : signal is "yes" ;
begin
    r_realabs <= signed(i_real_signed);
    r_imagabs <= signed(i_imag_signed);
    o_norm <= std_logic_vector(r_norm);

    process(i_clk,i_arstn)
    begin
        if(i_arstn='0') then
            r_realSquare   <= (others=>'0');
            r_imagSquare   <= (others=>'0');
            r_norm   <= (others=>'0');
        elsif(rising_edge(i_clk)) then
            if i_enable = '1' then
                r_realSquare <= r_realabs * r_realabs; -- square the number
                r_imagSquare <= r_imagabs * r_imagabs; -- square the number
                r_norm <= resize(r_realSquare,r_norm'length) + resize(r_imagSquare,r_norm'length); -- add the numbers
            end if;
        end if;
    end process;


end architecture;