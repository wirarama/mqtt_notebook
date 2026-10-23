@echo off
setlocal
cd /d "%~dp0"
echo Ini akan menghapus folder: python, mosquitto, downloads
echo Notebook dan konfigurasi TIDAK dihapus.
choice /c YN /m "Lanjutkan"
if errorlevel 2 exit /b 0
if exist "python" rmdir /s /q "python"
if exist "downloads" rmdir /s /q "downloads"
if exist "mosquitto\uninstall.exe" (
    echo Menjalankan uninstaller Mosquitto - klik YES pada UAC ...
    powershell -NoProfile -Command "Start-Process -FilePath '%~dp0mosquitto\uninstall.exe' -ArgumentList '/S' -Verb RunAs -Wait"
)
if exist "mosquitto" rmdir /s /q "mosquitto"
echo Selesai. Jalankan setup.bat untuk memasang ulang.
pause
