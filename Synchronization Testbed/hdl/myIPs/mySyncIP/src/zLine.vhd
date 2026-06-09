library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity zLine is
    generic (
        DELAY_CYCLES : integer  := 1;  -- The 'k' in z^(-k)
        DATA_WIDTH   : positive := 8   -- Arbitrary data width
    );
    port (
        i_clk  : in  std_logic;
        i_rst_n  : in  std_logic;
        i_enable: in std_logic;
        i_data : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        o_data:  out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity zLine;

architecture rtl of zLine is
    
    
begin
    GEN_0: if DELAY_CYCLES = 0 generate
        o_data <= i_data;
    end generate GEN_0;

    GEN_N: if DELAY_CYCLES > 0 generate
        type signed_array_t is array (natural range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);
        signal delay_regs : signed_array_t(DELAY_CYCLES - 1 downto 0);
    begin
        process(i_clk, i_rst_n)
        begin
            if i_rst_n = '0' then
                -- Reset all registers to zero
                delay_regs <= (others => (others => '0'));
            elsif rising_edge(i_clk) then
                -- Shift data through the registers on each clock cycle
                if DELAY_CYCLES > 0 then
                    if i_enable = '1' then
                        -- The new data is stored in the first register
                        delay_regs(0) <= i_data;
                        -- A generate statement for shifting the rest of the registers
                        for i in 1 to DELAY_CYCLES - 1 loop
                            delay_regs(i) <= delay_regs(i-1);
                        end loop;
                    end if;
                end if;
            end if;
        end process;
        o_data <= delay_regs(DELAY_CYCLES - 1);
    end generate GEN_N;

end architecture rtl;