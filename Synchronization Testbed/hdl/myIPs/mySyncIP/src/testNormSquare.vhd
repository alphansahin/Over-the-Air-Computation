----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/26/2025 11:23:14 AM
-- Design Name: 
-- Module Name: testNormSquare - Behavioral
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_Std.all;
use ieee.std_logic_misc.all;

use ieee.std_logic_textio.all;


library std ;
use std.textio.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testNormSquare is
        generic(
            inputLength: integer := 8
        );
end testNormSquare;

architecture Behavioral of testNormSquare is
    component normSquare is
        generic(
            inputLength: integer := inputLength
        );
        port (
            i_real_signed : in std_logic_vector(inputLength-1 downto 0);
            i_imag_signed : in std_logic_vector(inputLength-1 downto 0);
            o_norm_unsigned : out std_logic_vector(2*inputLength-1 downto 0);
            i_enable: in std_logic;
            i_clk: in std_logic;
            i_arstn: in std_logic
        );
    end component;
    constant clk_period : time := 8ns;
    constant clk_fast_period : time := 1ns;
    signal clk : STD_LOGIC:='0';
    signal arstn : STD_LOGIC;

    signal r_real_signed : std_logic_vector(inputLength-1 downto 0) := std_logic_vector(to_signed(0, inputLength));
    signal r_imag_signed : std_logic_vector(inputLength-1 downto 0) := std_logic_vector(to_signed(0, inputLength));
    signal r_norm_unsigned : std_logic_vector(2*inputLength-1 downto 0);

begin

    ns_inst: component normSquare
        generic map(
        inputLength => 8
    )
        port map (
        i_real_signed => r_real_signed,
        i_imag_signed => r_imag_signed,
        o_norm_unsigned => r_norm_unsigned,
        i_enable=> '1',
        i_clk=>clk,
        i_arstn=>arstn
    );
    
    
    clk_generation: process
    begin
        wait for clk_period/2;
        clk <= not clk; --toggle clock when half of clk_period is over
    end process;
    
    
    process
    begin
        -- hold reset state for 100 ns.
        arstn                   <= '0';
        wait for 20 ns;
        arstn                   <= '1';        
        
        r_real_signed <= std_logic_vector(to_signed(-2**(inputLength-1), inputLength));
        r_imag_signed <= std_logic_vector(to_signed(-2**(inputLength-1), inputLength));

        wait;
    end process;            
end Behavioral;












