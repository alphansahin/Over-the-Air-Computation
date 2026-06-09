set user=%1
set password=%2
set ipAddress=%3


plink -batch -ssh %user%@%ipAddress% -pw %password% "sudo fuser -k 8080/tcp; sudo fuser -k 8081/tcp;sudo fuser -k 8080/tcp; sudo fuser -k 8081/tcp;"