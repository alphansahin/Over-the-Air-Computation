library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;
use IEEE.Numeric_STD.all;

entity myReciprocal is
    generic (
        A_WIDTH : integer := 10;
        B_WIDTH : integer := 16;
        K_WIDTH : integer := 6
    );
    port (
        clk   : IN  std_logic;  -- Clock signal
        valid : OUT  std_logic :='0' ;  -- Start signal
        a     : IN  std_logic_vector(A_WIDTH-1 downto 0);    -- Input integer a
        b     : IN  std_logic_vector(B_WIDTH-1 downto 0);     -- Input integer b
        k     : OUT std_logic_vector(K_WIDTH-1 downto 0)    -- Output integer k
    );
end myReciprocal;

architecture Behavioral OF myReciprocal IS
    signal akRegTestProduct : std_logic_vector(K_WIDTH+A_WIDTH-1 downto 0); -- Internal signal for k
    signal aReg : std_logic_vector(A_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(0, A_WIDTH)); -- Internal signal for k
    signal bReg : std_logic_vector(B_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(0, B_WIDTH)); -- Internal signal for k
    signal kReg : std_logic_vector(K_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(0, K_WIDTH)); -- Internal signal for k
    signal kRegTest : std_logic_vector(K_WIDTH-1 downto 0); -- Internal signal for k
    signal kBitPosition : std_logic_vector(K_WIDTH-1 downto 0) :=std_logic_vector(to_unsigned(0, K_WIDTH));
begin
    process(clk)
    begin
        -- Implementation 1
        --        if rising_edge(clk) then
        --            if running <= '0' then
        --                running <= '1';
        --                kBitPosition <= std_logic_vector(to_unsigned(2**(K_WIDTH-1), K_WIDTH));
        --                kReg <= std_logic_vector(to_unsigned(0, K_WIDTH));
        --                aReg <= a;
        --                bReg <= b;
        --                valid <= '0';
        --            else
        --                if (akRegTestProduct(K_WIDTH+A_WIDTH-1 downto K_WIDTH+A_WIDTH-B_WIDTH ) <= bReg) then
        --                    kReg <= kRegTest;  -- Keep the bit if valid
        --                end if;
        --                if kBitPosition = std_logic_vector(to_unsigned(0, K_WIDTH)) then
        --                    running <= '0';
        --                    k <= kReg;
        --                    valid <= '1';
        --                end if;
        
        --                kBitPosition <= '0' & kBitPosition(K_WIDTH-1 downto 1);
        --            end if;
        --        end if;
        
        -- Implementation 2
        if rising_edge(clk) then
            if kBitPosition = std_logic_vector(to_unsigned(0, K_WIDTH)) then
                k <= kReg;
                valid <= '1';
                
                kBitPosition <= std_logic_vector(to_unsigned(2**(K_WIDTH-1), K_WIDTH));
                kReg <= std_logic_vector(to_unsigned(0, K_WIDTH));
                aReg <= a;
                bReg <= b;
            else
                valid <= '0';     
                if (akRegTestProduct(K_WIDTH+A_WIDTH-1 downto K_WIDTH+A_WIDTH-B_WIDTH ) <= bReg) then
                    kReg <= kRegTest;  -- Keep the bit if valid
                end if;            
                kBitPosition <= '0' & kBitPosition(K_WIDTH-1 downto 1);    
            end if;
    end if;        
    end process;

    kRegTest <= kReg or kBitPosition;
    akRegTestProduct <= kRegTest * aReg;


end Behavioral;