set user=%1
set password=%2
set ipAddress=%3


plink -batch -ssh %user%@%ipAddress% -pw %password% "sudo uhubctl -l 2-1 -p 1 -a off; sudo uhubctl -l 2-1 -p 2 -a off; sudo uhubctl -l 2-1 -p 3 -a off; sudo uhubctl -l 2-1 -p 4 -a off; sudo uhubctl -l 2-1 -p 1 -a on; sudo uhubctl -l 2-1 -p 2 -a on; sudo uhubctl -l 2-1 -p 3 -a on; sudo uhubctl -l 2-1 -p 4 -a on;"