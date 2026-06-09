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

entity my2DROM is
  generic (initFile : string);
  port (
   CLK        : in  std_logic;          
   ADDRESS_ROW    : in  std_logic_vector;
   ADDRESS_COL    : in  std_logic_vector;
   DATAOUT    : out std_logic_vector
);
end entity my2DROM;


architecture arc_my2DROM of my2DROM is
    constant DATA_WIDTH : integer := DATAOUT'length;
    constant ROW_WIDTH : integer := ADDRESS_ROW'length;
    constant COL_WIDTH : integer := ADDRESS_COL'length;
    constant DEPTH : integer := 2**(ROW_WIDTH+COL_WIDTH);
    
    type romType is array(0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

    impure function initRomFromFile return romType is
        file data_file : text open read_mode is initFile;
        file data_file_test : text open write_mode is "test.dat";
        variable data_fileLine : line;
        variable data_fileLine_test : line;
        variable val: std_logic_vector(7 downto 0);
        variable ROM           : romType;
    begin
        for Ir in 0 to 2**ROW_WIDTH-1 loop
            readline(data_file, data_fileLine);
            for Ic in 0 to 2**COL_WIDTH-1 loop
                hread(data_fileLine, val);
                ROM(Ic*(2**ROW_WIDTH)+Ir) := val;
                
                -- hwrite(data_fileLine_test, ROM(Ic*(2**ROW_WIDTH)+Ir));
            end loop;
            -- writeline(data_file, data_fileLine_test);
        end loop;
        return ROM;
    end function;

    signal rom : romType := initRomFromFile;

    attribute rom_style : string;
    attribute rom_style of rom : signal is "block";

    signal dout_int : integer range 0 to 2**DATA_WIDTH - 1;
    signal ADDRESS : std_logic_vector(ROW_WIDTH+COL_WIDTH-1 downto 0);

    
    
begin
    ADDRESS <= ADDRESS_COL & ADDRESS_ROW;
    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            DATAOUT <= rom(to_integer(unsigned(ADDRESS)));
        end if;
    end process;

end architecture arc_my2DROM;
-----------------------------------------------------------------
--   End of File: spROM.vhd
-----------------------------------------------------------------


