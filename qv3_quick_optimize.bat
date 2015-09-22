@echo off
rem  Author:    Scott Harman
rem             Snell Advanced Media
rem  Date:      15/09/2015
rem  Version:   1.5a
SETLOCAL EnableDelayedExpansion
rem Set default paths

set PATH=%PATH%;%~dp0
rem set DB=quentin_v3
IF [%1]==[] ( set DB=quentin_v3 ) else ( set DB=%1 )
echo %DB%
set DBPATH=c:\data\mysql\data\
set BACKUPDIR=%DBPATH%backups\
SET PORT=3306
SET USER=quantel
SET PASS=
Set PARSEARG="eol=; tokens=1,2,3* delims=: "
For /F %PARSEARG% %%i in ('TIME /T') Do Set HHMM=%%i.%%j
set FTIME=%HHMM%
SET LOGs="%~dp0\logs\Quick_Optimize_%DB%_%FTIME%_"
if not exist "%~dp0\logs" mkdir "%~dp0\logs"
if not exist %BACKUPDIR% mkdir %BACKUPDIR%
echo %LOGS%

rem backup database structure
if DEFINED PASS (
    set USERPASS=-u%USER% -p%PASS%
    "%~dp0\_quickoptimize.bat" %DB% %DBPATH% %BACKUPDIR% %USERPASS% 2>&1| logtext %LOGS% "" ECHO STDIN
    ) else (
    set USERPASS=-u%USER%
    "%~dp0\_quickoptimize.bat" %DB% %DBPATH% %BACKUPDIR% %USERPASS% 2>&1| logtext %LOGS% "" ECHO STDIN
)
:EXIT
