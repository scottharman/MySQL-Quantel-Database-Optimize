@echo off
setLocal EnableDelayedExpansion
rem     Author:  Scott Harman
rem          Snell Advanced Media
rem     Date:    15/09/2015
rem     Version: 1.5
rem
rem Set default paths
rem Add autorepair and auto version check option to check tables command.
rem Moved table backup up the script to ensure it runs
rem Added flush tables command to ensure that the table backup can be done.

set DB=%1%
set DBPATH=%2%
set BACKUPDIR=%3%
SET PORT=3306
SET USERPASS=%4%

Set PARSEARG="eol=; tokens=1,2,3* delims=/ "
For /F %PARSEARG% %%i in ('DATE /T') Do Set DDMM=%%i%%j%%k
set FTIME=%HHMM%
Set PARSEARG="eol=; tokens=1,2,3* delims=: "
For /F %PARSEARG% %%i in ('TIME /T') Do Set HHMM=%%i%%j%%k
set DATEMONTH=%DDMM%


echo Size of QuentinV3 and MySQl Data Folders (C:\Data)
du -l 1 "C:\Data\QuentinV3"

du -l 2 "C:\Data\MySQL\Data"

echo Display current database Status
mysql -vvv -uqrepl -P%PORT% %DB% -e "flush tables; show processlist; show table status; show slave status \G;"
mysql -vvv -P%PORT% %USERPASS% %DB% -B -t -e "show indexes from browse; show indexes from clips; show indexes from tags; "
mysql -vvv -P%PORT% %USERPASS% %DB% -B -t -e "show indexes from rushes; show indexes from essencefragments; show indexes from rushtimecodes;"
echo Flush Tables
mysqladmin -vvv -P%PORT% -uqrepl flush-tables
echo Backup existing database
7za a "%BACKUPDIR%\%DB%_%DATEMONTH%_%FTIME%.zip" "%DBPATH%%DB%"

echo Backup all tables - any errors here should be sorted out in the next pass.
rem Not strictly necessary - likely to be removed from future versions
mysqldump -vvv -P%PORT% %USERPASS% %DB% > %BACKUPDIR%\%DB%.sql

7za a "%BACKUPDIR%\%DB%_%DATEMONTH%_%FTIME%.zip" "%BACKUPDIR%\%DB%*.sql"

del %BACKUPDIR%\%DB%.sql /q

echo Try to optimize each table, then analyze and repair if necessary
rem echo mysqlcheck -P%PORT% %USERPASS% %DB% -vvv --auto-repair -g --extended --analyze
rem mysqlcheck -P%PORT% %USERPASS% %DB% -vvv --auto-repair -g --extended --analyze

echo mysqlcheck  -P%PORT% %USERPASS% %DB% --optimize -vvv
mysqlcheck  -P%PORT% %USERPASS% %DB% --optimize -vvv

echo mysqlcheck  -P%PORT% %USERPASS% %DB% --analyze --extended -vvv
mysqlcheck  -P%PORT% %USERPASS% %DB% --analyze --extended -vvv

echo mysqlcheck  -P%PORT% %USERPASS% %DB% --auto-repair -g -vvv
mysqlcheck  -P%PORT% %USERPASS% %DB% --auto-repair -g -vvv

echo mysqlcheck  -P%PORT% %USERPASS% %DB% --auto-repair -vvv
mysqlcheck  -P%PORT% %USERPASS% %DB% --auto-repair -vvv


echo Flush Tables
mysqladmin -vvv -P%PORT% -uqrepl flush-tables

echo Show Status
mysql -vvv -uqrepl -P%PORT% %DB% -e "show processlist; show table status; show slave status \G;"

echo Show Indexes
mysql -vvv -P%PORT% %USERPASS%  %DB% -B -t -e "show indexes from browse; show indexes from clips; show indexes from tags; "
mysql -vvv -P%PORT% %USERPASS%  %DB% -B -t -e "show indexes from rushes; show indexes from essencefragments; show indexes from rushtimecodes;"

echo Size of QuentinV3 and MySQl Data Folders (C:\Data)

du -l 1 "C:\Data\QuentinV3"

du -l 2 "C:\Data\MySQL\Data"

echo Operation completed successfully
