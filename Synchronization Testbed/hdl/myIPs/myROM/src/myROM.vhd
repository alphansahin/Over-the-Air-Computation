-----------------------------------------------------------------
--   File: spROM.sv
--   creates a synchronous single-port rom.
--   Initialization file passed as generic
-----------------------------------------------------------------*/
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
        CLK       : in  std_logic;
        ADDRESS   : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        DATAOUT   : out std_logic_vector(DATA_WIDTH-1 downto 0)
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
    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            DATAOUT <= rom(to_integer(unsigned(ADDRESS)));
        end if;
    end process;

end architecture arc_myROM;
-----------------------------------------------------------------
--   End of File: spROM.vhd
-----------------------------------------------------------------


