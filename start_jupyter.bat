@echo off
setlocal
cd /d "%~dp0"
title Jupyter Lab - MQTT Notebook
if not exist "python\python.exe" (
    echo Python lokal belum terpasang. Jalankan setup.bat terlebih dahulu.
    pause
    exit /b 1
)
echo Membuka Jupyter Lab di browser ... tekan Ctrl+C di jendela ini untuk berhenti.
"%~dp0python\python.exe" -m jupyter lab --notebook-dir="%~dp0notebooks"
pause
