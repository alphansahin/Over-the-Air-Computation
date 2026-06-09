----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2025 02:33:52 PM
-- Design Name: 
-- Module Name: detectorXcorr - Behavioral
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
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity detectorXcorr is
    Generic(
        log2_of_norm_square_filter_coeffs :integer := 14; -- 16×(2^5-1)^2 ~= 2^14
        log2_of_1_over_threshold :integer := 1; -- 2 means 1/2^2 = 0.25
        bitWidth_xcorrSquare_in: integer := 49; 
        bitWidth_normSquare_in: integer := 28
    );
    Port (
        xcorrSquare_in : in STD_LOGIC_VECTOR (bitWidth_xcorrSquare_in-1 downto 0);
        normSquare_in : in STD_LOGIC_VECTOR (bitWidth_normSquare_in-1 downto 0);
        detectedRepeat : out STD_LOGIC;
        clk: in std_logic;
        enable: in std_logic;
        arstn: in std_logic
    );
end detectorXcorr;

architecture Behavioral of detectorXcorr is
    signal detectedMemory: std_logic_vector(80 downto 0);
    signal xcorrSquareDivided: std_logic_vector(bitWidth_xcorrSquare_in-1-(log2_of_norm_square_filter_coeffs-log2_of_1_over_threshold) downto 0);


    signal detectedSingle: std_logic;
    signal detectedRepeat_r: std_logic;

begin
    xcorrSquareDivided <= xcorrSquare_in(bitWidth_xcorrSquare_in-1 downto log2_of_norm_square_filter_coeffs-log2_of_1_over_threshold);
    detectedRepeat <= detectedRepeat_r;
    detectedRepeat_r <= '1' when detectedMemory(0)='1' and detectedMemory(16)='1'  and detectedMemory(32)='1' and detectedMemory(48)='1' and detectedMemory(64)='1' and detectedMemory(80)='1'  
                             and detectedMemory(1)='0' and detectedMemory(17) ='0' and detectedMemory(33)='0' and detectedMemory(49)='0' and detectedMemory(65)='0'
 else '0';
    detectedSingle <= '1' when unsigned(xcorrSquareDivided) > resize(unsigned(normSquare_in), xcorrSquareDivided'length ) else '0';
    process(clk,arstn)
    begin
        if(arstn='0') then
            detectedMemory   <= (others=>'0');
        elsif(rising_edge(clk)) then
            if(enable='1') then
                if detectedRepeat_r  = '1' then
                    detectedMemory   <= (others=>'0');
                else
                    detectedMemory  <= detectedMemory(detectedMemory'length-2 downto 0) & detectedSingle;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
