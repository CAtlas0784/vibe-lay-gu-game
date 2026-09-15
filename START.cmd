@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Ananta 4229938 Private Server

where powershell.exe >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Windows PowerShell was not found.
  pause
  exit /b 3
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Run-All.ps1"
set "rc=%errorlevel%"
if not "%rc%"=="0" pause
exit /b %rc%
