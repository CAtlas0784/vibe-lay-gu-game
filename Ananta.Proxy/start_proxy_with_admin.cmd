@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Ananta 4229938 Proxy Setup

net session >nul 2>&1
if errorlevel 1 (
    echo [ERROR] This script must be run as Administrator.
    echo Right-click it and choose "Run as administrator".
    pause
    exit /b 1
)

echo [1/2] Preparing certificate and hosts entries...
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0SETUP_PROXY_AS_ADMIN.ps1"
if errorlevel 1 (
    echo [ERROR] Proxy setup failed.
    pause
    exit /b 1
)

echo [2/2] Starting proxy...
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-Proxy.ps1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" echo [ERROR] Proxy stopped with exit code %RC%.
pause
exit /b %RC%
