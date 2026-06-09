set user=%1
set password=%2
set ipAddress=%3
set pyfileDirectoryPath=%4
set pyfileName=%5
set parameters=%6 %7 %8

plink -batch -ssh %user%@%ipAddress% -pw %password% "cd %pyfileDirectoryPath%; python -u %pyfileName% %parameters%"

