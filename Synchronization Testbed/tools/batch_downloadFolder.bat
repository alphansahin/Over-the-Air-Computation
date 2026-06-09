set password=%2
set user=%1
set ipAddress=%3
set folderSource=%4
set folderTarget=%5

pscp -pw %password% -r %user%@%ipAddress%:%folderSource% %folderTarget%