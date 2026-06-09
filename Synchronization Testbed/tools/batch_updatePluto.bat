set user=%1
set password=%2
set ipAddress=%3
set plutoFrameSource=%4
set pathPluto=%5


pscp -pw %password% -r %plutoFrameSource% %user%@%ipAddress%:%pathPluto%
plink -batch -ssh %user%@%ipAddress% -pw %password% "sudo eject %pathPluto%"