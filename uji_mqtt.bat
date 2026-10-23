@echo off
setlocal
cd /d "%~dp0"
title Uji MQTT
if not exist "python\python.exe" (
    echo Python lokal belum terpasang. Jalankan setup.bat terlebih dahulu.
    pause
    exit /b 1
)
echo Pastikan broker sudah berjalan - start_broker.bat - sebelum tes ini.
echo.
"%~dp0python\python.exe" "%~dp0scripts\test_mqtt.py" %*
pause
