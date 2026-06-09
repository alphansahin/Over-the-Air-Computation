----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/26/2025 05:28:04 PM
-- Design Name: 
-- Module Name: phaseEstimationInput - Behavioral
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

entity phaseEstimationInput is
    generic (
        constant NUM_STATUS_REGS: integer := 1
    );
    Port (
        
        data_o : out std_logic_vector(63 downto 0);
       
        data_i : in std_logic_vector(63 downto 0);
        valid_o : out std_logic;
        syncDetected_i : in std_logic;
        enablePhaseEs_i : in std_logic; 
        
        kVal_i : in std_logic_vector(14 downto 0);
        status_myPhaseEstimation                 : out std_logic_vector (NUM_STATUS_REGS*32-1 downto 0);
        
        clk : in std_logic;
        arstn : in std_logic
    );
end phaseEstimationInput;

architecture Behavioral of phaseEstimationInput is
    signal counter_r: unsigned (15 downto 0);

    constant ZERO : std_logic_vector(31 downto 0) := (others => '0');
    type std_logic_vector_array_t is array (natural range <>) of std_logic_vector(31 downto 0);
    signal status_myPhaseEstimation_r : std_logic_vector_array_t(0 to NUM_STATUS_REGS-1);


begin
    gen_status: for i in 0 to NUM_STATUS_REGS-1 generate
        status_myPhaseEstimation(i*32 +  31 downto i*32) <= status_myPhaseEstimation_r(i);
    end generate gen_status ;
    status_myPhaseEstimation_r(0) <= '0' & kVal_i & std_logic_vector(counter_r);

    process(clk,arstn)
    begin
        if(arstn='0') then
            valid_o <= '0';
            data_o  <= (others=>'0');
            counter_r  <= (others=>'0');
        elsif(rising_edge(clk)) then
            if(syncDetected_i='1' and enablePhaseEs_i = '1') then
                data_o <= data_i;
                valid_o <= '1';
                counter_r <= counter_r + 1;
            else
                valid_o <= '0';
            end if;

        end if;
    end process;

end Behavioral;
