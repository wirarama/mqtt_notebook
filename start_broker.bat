@echo off
setlocal
cd /d "%~dp0"
title MQTT Broker - Mosquitto - port 1883
if not exist "mosquitto\mosquitto.exe" (
    echo Mosquitto belum terpasang. Jalankan setup.bat terlebih dahulu.
    pause
    exit /b 1
)
echo ============================================================
echo   Mosquitto MQTT broker berjalan di localhost:1883
echo   Konfigurasi : config\mosquitto.conf
echo   Tutup jendela ini atau tekan Ctrl+C untuk menghentikan.
echo ============================================================
"%~dp0mosquitto\mosquitto.exe" -c "%~dp0config\mosquitto.conf" -v
echo.
echo Broker berhenti. Jika muncul "Only one usage of each socket address",
echo port 1883 sudah dipakai broker lain - hentikan dulu broker tersebut.
pause
