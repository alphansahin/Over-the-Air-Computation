library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_Std.all;


use IEEE.STD_LOGIC_UNSIGNED.ALL;

library std ;
use std.textio.all;

entity myROM is
    generic (
        INITFILE : string := "aFile.mem";
        ADDR_WIDTH : integer := 14;
        DATA_WIDTH : integer := 8  -- Bit width of each data entry
    );
    port (
        clk       : in  std_logic;
        address   : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        data_o   : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity myROM;


architecture arc_myROM of myROM is
    constant DEPTH : integer := 2**(ADDR_WIDTH);
    
    type romType is array(0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

    impure function initRomFromFile return romType is
        file data_file : text open read_mode is initFile;
        variable data_fileLine : line;
        variable ROM           : romType;
    begin
        for Ir in 0 to DEPTH-1 loop
            readline(data_file, data_fileLine);
            hread(data_fileLine, ROM(Ir));
        end loop;
        return ROM;
    end function;

    signal rom : romType := initRomFromFile;

    attribute rom_style : string;
    attribute rom_style of rom : signal is "block";

    
begin
    process (clk)
    begin
        if (clk'event and clk = '1') then
            data_o <= rom(to_integer(unsigned(address)));
        end if;
    end process;

end architecture arc_myROM;


