@echo off
setlocal
cd /d "%~dp0"
if exist "mosquitto\mosquitto.exe" (
    start "MQTT Broker" "%~dp0start_broker.bat"
    timeout /t 2 /nobreak >nul
) else (
    echo [PERINGATAN] Mosquitto belum terpasang, broker tidak dijalankan.
)
call "%~dp0start_jupyter.bat"
