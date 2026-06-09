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
        DOUT_FIR_COMPLEX_WIDTH              : integer;
        XCORR_SQUARE_WIDTH_AFTER_DIVISION   : integer;
        NORM_SQUARE_WIDTH                   : integer;
        VAL_SUPPRESS                        : integer
    );
    Port (
        i_real_signed                   : in std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
        i_imag_signed                   : in std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
        i_xcorrSquareDivided            : in STD_LOGIC_VECTOR (XCORR_SQUARE_WIDTH_AFTER_DIVISION-1 downto 0);
        i_normSquare                    : in STD_LOGIC_VECTOR (NORM_SQUARE_WIDTH-1 downto 0);
        i_suppressDetection             : in STD_LOGIC;
        
        o_real_signed_detected          : out std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
        o_imag_signed_detected          : out std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
        o_normSquare_detected           : out std_logic_vector(NORM_SQUARE_WIDTH-1 downto 0);
        o_xcorrSquareDivided_detected   : out std_logic_vector(XCORR_SQUARE_WIDTH_AFTER_DIVISION-1 downto 0);        
        o_detected                      : out STD_LOGIC;
        o_detected_toggle               : out STD_LOGIC;
        o_stateDetector                 : out STD_LOGIC;
        o_cntDetection                  : out std_logic_vector(15 downto 0);
        i_clk                           : in std_logic;
        i_arstn                         : in std_logic
    );
end detectorXcorr;

architecture Behavioral of detectorXcorr is
    signal r_counterSuppress : integer range 0 to VAL_SUPPRESS-1;

    --signal r_xcorrSquareDivided: std_logic_vector(XCORR_SQUARE_WIDTH-1-(CLOG2_NORMSQUARE_FILTER_COEFS-LOG2_OF_1_OVER_THRESHOLD) downto 0);
    signal r_stateDetector: std_logic;
    signal r_cntDetection : unsigned(15 downto 0 );
    signal r_detected_toggle: std_logic;
        
        
    signal r_real_signed_detected           :  std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
    signal r_imag_signed_detected           :  std_logic_vector(DOUT_FIR_COMPLEX_WIDTH-1 downto 0);
    signal r_normSquare_detected            :  std_logic_vector(NORM_SQUARE_WIDTH-1 downto 0);
    signal r_xcorrSquareDivided_detected    :  std_logic_vector(XCORR_SQUARE_WIDTH_AFTER_DIVISION-1 downto 0);



begin

    o_normSquare_detected           <= r_normSquare_detected;
    o_xcorrSquareDivided_detected   <= r_xcorrSquareDivided_detected;
    o_real_signed_detected          <= r_real_signed_detected;
    o_imag_signed_detected          <= r_imag_signed_detected;
    o_detected_toggle               <= r_detected_toggle;
    o_stateDetector                 <= r_stateDetector;
    o_cntDetection                  <= std_logic_vector(r_cntDetection);
    
    
    process(i_clk,i_arstn)
    begin
        if(i_arstn='0') then
            o_detected <= '0';
            r_detected_toggle <= '0';
            r_stateDetector <= '0';
            r_cntDetection  <= (others=>'0');
            r_real_signed_detected  <= (others=>'0');
            r_imag_signed_detected  <= (others=>'0');
            r_normSquare_detected  <= (others=>'0');
            r_xcorrSquareDivided_detected  <= (others=>'0');
        elsif(rising_edge(i_clk)) then
            if r_stateDetector = '0' then
                if signed(i_xcorrSquareDivided) > signed( (XCORR_SQUARE_WIDTH_AFTER_DIVISION-1 downto NORM_SQUARE_WIDTH => '0') &  i_normSquare) and i_suppressDetection = '0' then
                    r_cntDetection                  <= r_cntDetection + 1;
                    o_detected                      <= '1';
                    r_detected_toggle               <= not r_detected_toggle;
                    r_real_signed_detected          <= i_real_signed;
                    r_imag_signed_detected          <= i_imag_signed;
                    r_normSquare_detected           <= i_normSquare;
                    r_xcorrSquareDivided_detected   <= i_xcorrSquareDivided;
                    r_stateDetector                 <= '1'; -- suppress the detection
                end if;
            else
                o_detected <= '0';
                if r_counterSuppress = VAL_SUPPRESS-1 then
                    r_counterSuppress           <= 0;
                    r_stateDetector             <= '0'; -- go back to the normal operation
                else
                    r_counterSuppress           <= r_counterSuppress + 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;


