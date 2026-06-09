----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/03/2025 01:58:32 PM
-- Design Name: 
-- Module Name: FIRcontroller - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_misc.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FIRcontroller is
    generic (
        log2_number_Of_FIR_coefficients : integer := 4;
        bitWidth_FIR_coefficients : integer := 6
    );
    Port ( 
        FIR_coef_i : in STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 );
        FIR_isConfigurationLoaded_o : out STD_LOGIC;
        FIR_reload_last : out STD_LOGIC;
        FIR_reload_ready : in STD_LOGIC;
        FIR_reload_valid : out STD_LOGIC;
        FIR_reload_data : out STD_LOGIC_VECTOR (7 downto 0);

        FIR_config_ready  : in STD_LOGIC;
        FIR_config_valid : out STD_LOGIC;
        FIR_config_data : out STD_LOGIC_VECTOR (7 downto 0);

        FIR_arst_o : out STD_LOGIC;    
    
        clk                                 :   IN    std_logic;  -- ufix1
        arstn                               :   IN    std_logic  -- ufix1
    );
end FIRcontroller;

architecture Behavioral of FIRcontroller is
    signal FIR_coef_pre : STD_LOGIC_VECTOR ( (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients-1 downto 0 ) := std_logic_vector(to_unsigned(0, (2**log2_number_Of_FIR_coefficients)*bitWidth_FIR_coefficients));
    signal FIR_indexCoef : STD_LOGIC_VECTOR ( log2_number_Of_FIR_coefficients-1 downto 0 ) := std_logic_vector(to_unsigned(0, log2_number_Of_FIR_coefficients));
    signal FIR_state : STD_LOGIC_VECTOR(2 downto 0) := (others=>'0');
    signal FIR_config_change : STD_LOGIC;
    signal allOneForFIRcoeffs :STD_LOGIC_VECTOR(log2_number_Of_FIR_coefficients-1 downto 0 ) :=  (others => '1');    

    type coefArrayType is array(0 to (2**log2_number_Of_FIR_coefficients)-1) of  STD_LOGIC_VECTOR ( bitWidth_FIR_coefficients-1 downto 0 );
    signal FIR_coefArray: coefArrayType;
    
begin

    FIR_config_change <= or_reduce((FIR_coef_i) xor ( FIR_coef_pre));

    process(arstn,clk)
    begin
        if arstn = '0' then
            FIR_state <= (others=> '0');
            FIR_arst_o <= '0';
            FIR_config_valid <= '0';
            FIR_reload_valid <= '0';
            FIR_reload_last <= '0';
            FIR_isConfigurationLoaded_o <= '0';
            FIR_indexCoef <= (others=> '0');
            FIR_reload_data <= b"00000000";
            FIR_config_data <= b"00000000";
        elsif rising_edge(clk) then
   
            -- Xcorr:
            FIR_coef_pre <= FIR_coef_i;

            case FIR_state is
                when "000" =>
                    FIR_arst_o <= '0';
                    FIR_state <= b"001";
                when "001" =>
                    FIR_arst_o <= '1';
                    FIR_state <= b"010";
                when b"010" =>
                    FIR_reload_data <= b"00" & FIR_coefArray( to_integer(unsigned(FIR_indexCoef)));

                    if FIR_reload_ready = '1' then
                        if FIR_indexCoef = allOneForFIRcoeffs then
                            FIR_state <= b"011";
                            FIR_reload_last <= '1';
                        end if;
                        FIR_reload_valid <= '1';
                        FIR_indexCoef <= std_logic_vector(unsigned(FIR_indexCoef) + 1);
                    else
                        FIR_reload_valid <= '0';
                    end if;
                when b"011" =>
                    FIR_reload_valid <= '0';
                    FIR_reload_last <= '0';
                    if FIR_config_ready = '1' then
                        FIR_config_valid <= '1';
                        FIR_state <= b"100";
                    end if;
                when others =>
                    FIR_config_valid <= '0';
                    if FIR_config_change = '1' then
                        FIR_isConfigurationLoaded_o <= '0';
                        FIR_arst_o <= '0';
                        FIR_state <= b"000";
                    else
                        FIR_isConfigurationLoaded_o <= '1';
                    end if;
            end case;

        end if;
    end process;


    process(FIR_coef_i)
    begin
        for i in 0 to 2**log2_number_Of_FIR_coefficients-1 loop
            FIR_coefArray(2**log2_number_Of_FIR_coefficients-1-i) <= FIR_coef_i(bitWidth_FIR_coefficients-1+bitWidth_FIR_coefficients*i downto bitWidth_FIR_coefficients*i);
        end loop;
    end process;    
    
    
    
end Behavioral;
