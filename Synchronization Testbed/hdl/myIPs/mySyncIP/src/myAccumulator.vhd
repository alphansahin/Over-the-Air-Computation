----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2025 04:47:04 PM
-- Design Name: 
-- Module Name: myAccumulator - Behavioral
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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity myAccumulator is
    generic (
        N       : integer;
        log2L   : integer);
    port (
        -- input
        i_acc_dinPlus               : in  std_logic_vector(N-1 downto 0);
        i_acc_dinMinus              : in  std_logic_vector(N-1 downto 0);
        i_enable                    : in  std_logic;
        i_accumulator_reset         : in  std_logic;
        
        o_acc_dout                  : out std_logic_vector(N+log2L+1 - 1 downto 0);
        i_clk                       : in  std_logic;
        i_arstn                     : in  std_logic);
end myAccumulator;

architecture Behavioral of myAccumulator is
    signal r_acc            : signed(N+log2L+1 - 1 downto 0);  -- average accumulator
    signal r_diff           : signed(N downto 0);  -- average accumulator
begin

    o_acc_dout  <= std_logic_vector(r_acc);
    process(i_clk,i_arstn)
    begin
        if i_arstn = '0' then
            r_acc    <= (others=>'0');
            r_diff   <= (others=>'0');
        elsif(rising_edge(i_clk)) then
            if i_accumulator_reset = '1' then
                r_acc    <= (others=>'0');
                r_diff   <= (others=>'0');
            else
                if i_enable = '1' then
                    r_diff <= resize(signed(i_acc_dinPlus),N+1) - resize(signed(i_acc_dinMinus),N+1);
                    r_acc  <= r_acc + resize(r_diff,N+1+log2L)  ;
                end if;
            end if;
        end if;
    end process;
end Behavioral;


