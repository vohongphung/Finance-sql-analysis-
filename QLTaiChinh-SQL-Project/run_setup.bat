@echo off
REM ==========================================================
REM  FINANCE DATABASE SETUP SCRIPT
REM ==========================================================

echo ==========================================================
echo             FINANCE DATABASE SETUP - SQL SERVER
echo ==========================================================
echo.

set SERVER=localhost
set SQLCMD_OPTS=-S %SERVER% -E

echo [1/1] Running setup.sql ...
sqlcmd %SQLCMD_OPTS% -i ".\setup.sql"
if errorlevel 1 (
    color 0C
    echo ----------------------------------------------------------
    echo [ERROR] Setup failed. Please check your SQL scripts or
    echo          verify that SQL Server is running.
    echo ----------------------------------------------------------
    pause
    exit /b 1
)

color 0A
echo.
echo ----------------------------------------------------------
echo [SUCCESS] Database setup completed successfully!
echo You can now connect to [QLTaiChinh] for financial analysis.
echo ----------------------------------------------------------
pause
