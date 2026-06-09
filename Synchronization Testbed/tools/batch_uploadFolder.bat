set password=%2
set user=%1
set ipAddress=%3
set folderSource=%4
set folderName=%5
set directoryTarget=%6

plink -batch -ssh %user%@%ipAddress% -pw %password% "rm %directoryTarget%/%folderName% -r"
pscp -pw %password% -r %folderSource%\%folderName% %user%@%ipAddress%:%directoryTarget%