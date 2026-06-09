----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/12/2025 04:27:31 PM
-- Design Name: 
-- Module Name: magnitudeEstimator - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


--=====================================================================
--             Alpha * Max + Beta * Min Magnitude Estimator

--Name                  Alpha           Beta       Avg Err   RMS   Peak
--                                                 (linear)  (dB)  (dB)
-----------------------------------------------------------------------
--Min RMS Err      0.947543636291 0.392485425092   0.000547 -32.6 -25.6
--Min Peak Err     0.960433870103 0.397824734759  -0.013049 -31.4 -28.1
--Min RMS w/ Avg=0 0.948059448969 0.392699081699   0.000003 -32.6 -25.7
--1, Min RMS Err   1.000000000000 0.323260990000  -0.020865 -28.7 -23.8
--1, Min Peak Err  1.000000000000 0.335982538000  -0.025609 -28.3 -25.1
--1, 1/2           1.000000000000 0.500000000000  -0.086775 -20.7 -18.6
--1, 1/4           1.000000000000 0.250000000000   0.006456 -27.6 -18.7
--Frerking         1.000000000000 0.400000000000  -0.049482 -25.1 -22.3
--1, 11/32         1.000000000000 0.343750000000  -0.028505 -28.0 -24.8
--1, 3/8           1.000000000000 0.375000000000  -0.040159 -26.4 -23.4
--15/16, 15/32     0.937500000000 0.468750000000  -0.018851 -29.2 -24.1
--15/16, 1/2       0.937500000000 0.500000000000  -0.030505 -26.9 -24.1
--31/32, 11/32     0.968750000000 0.343750000000  -0.000371 -31.6 -22.9
--31/32, 3/8       0.968750000000 0.375000000000  -0.012024 -31.4 -26.1
--61/64, 3/8       0.953125000000 0.375000000000   0.002043 -32.5 -24.3
--61/64, 13/32     0.953125000000 0.406250000000  -0.009611 -31.8 -26.6
--=====================================================================

entity magnitudeEstimator is -- https://dspguru.com/dsp/tricks/magnitude-estimator/ or https://openofdm.readthedocs.io/en/latest/verilog.html
    Generic(
        width_in: integer := 3
    );
    Port (
        inPhase_i: in std_logic_vector(width_in-1 downto 0);
        quadrature_i: in std_logic_vector(width_in-1 downto 0);
        magnitude_o: out std_logic_vector(width_in-1 downto 0);
        clk : in STD_LOGIC;
        arstn : in STD_LOGIC);
end magnitudeEstimator;

architecture Behavioral of magnitudeEstimator is
    signal inPhaseAbs_r: unsigned(width_in-1 downto 0);
    signal quadratureAbs_r: unsigned(width_in-1 downto 0);
    signal max_r: unsigned(width_in-1 downto 0);
    signal min_r: unsigned(width_in-1 downto 0);
    
    signal alpha_r: unsigned(13 downto 0) := "11110101111000";  -- 0.960433870103;
    signal beta_r: unsigned(13 downto 0) := "01100101110110";   -- 0.397824734759;
    signal magnitude_r: unsigned(13+width_in downto 0);
begin
    inPhaseAbs_r <= unsigned(abs(signed(inPhase_i)));
    quadratureAbs_r <= unsigned(abs(signed(quadrature_i)));
    max_r <= inPhaseAbs_r when inPhaseAbs_r > quadratureAbs_r else quadratureAbs_r;
    min_r <= quadratureAbs_r when inPhaseAbs_r > quadratureAbs_r else inPhaseAbs_r;

--    process(clk,arstn)
--    begin
--        if(arstn='0') then
--            magnitude_o   <= (others=>'0');
--        elsif(rising_edge(clk)) then
--            magnitude_o <= std_logic_vector (max_r + resize((min_r(width_in-1 downto 2)), width_in)); -- alpha = 1, beta = 1/4
--        end if;
--    end process;
    
    
    magnitude_o <= std_logic_vector(magnitude_r(13+width_in downto 14));
    process(clk,arstn)
    begin
        if(arstn='0') then
            magnitude_r   <= (others=>'0');
        elsif(rising_edge(clk)) then
            magnitude_r <= max_r*alpha_r + min_r*beta_r; -- alpha = 1, beta = 1/4
        end if;
    end process;

end Behavioral;
