@echo off
setlocal
cd /d "%~dp0"
title Stop MQTT Broker + Jupyter
echo ============================================================
echo   Menghentikan broker Mosquitto dan Jupyter Lab
echo   yang berjalan dari folder ini.
echo   Simpan dulu notebook yang sedang dibuka di browser.
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\stop_all.ps1" -Root "%~dp0."
echo.
pause
