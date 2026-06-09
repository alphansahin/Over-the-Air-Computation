
library ieee ;
use ieee.std_logic_1164.all;


entity top_my2DROM is
    generic (
            INITFILE : string := "aFileMulti.mem";
            ROWS_BITWIDTH : integer := 10;
            COLS_BITWIDTH : integer := 5;
            DATA_BITWIDTH : integer := 8  -- Bit width of each data entry
        );
    
  port (
    CLK       : in  std_logic;
    ADDRESS_ROW   : in  std_logic_vector(ROWS_BITWIDTH-1 downto 0);
    ADDRESS_COL   : in  std_logic_vector(COLS_BITWIDTH-1 downto 0);
    DATAOUT   : out std_logic_vector(DATA_BITWIDTH-1 downto 0)
    );
end entity top_my2DROM;

architecture arc_top_my2DROM of top_my2DROM is
    
--   component myROM is
--     generic (initFile : string := INITFILE);
--     port (
--       CLK        : in  std_logic;          
--       ADDRESS    : in  std_logic_vector;
--       DATAOUT    : out std_logic_vector
--    );
--    end component myROM;
    
   component my2DROM is
     generic (initFile : string := INITFILE);
     port (
       CLK        : in  std_logic;    
       ADDRESS_ROW    : in  std_logic_vector;
       ADDRESS_COL    : in  std_logic_vector;
       DATAOUT    : out std_logic_vector
    );
    end component my2DROM;    

begin
    
--    myROM_inst : myROM
--      generic map (initFile => INITFILE)
--      port map (
--        CLK     => CLK,
--        ADDRESS => ADDRESS_COL  & ADDRESS_ROW, -- I intentionally do this instead of 2d array to make sure it maps to BRAMS
--        DATAOUT => DATAOUT
--    );
    
    
    my2DROM_inst : my2DROM
      generic map (initFile => INITFILE)
      port map (
        CLK     => CLK,
        ADDRESS_ROW => ADDRESS_ROW,
        ADDRESS_COL => ADDRESS_COL,
        DATAOUT => DATAOUT
    );
        

end architecture arc_top_my2DROM;