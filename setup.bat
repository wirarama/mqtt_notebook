@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Setup MQTT + Python + Jupyter Notebook
cd /d "%~dp0"

set "ROOT=%CD%"
set "PY_DIR=%ROOT%\python"
set "PY_EXE=%PY_DIR%\python.exe"
set "DL=%ROOT%\downloads"
set "MQ_DIR=%ROOT%\mosquitto"
REM Versi Python portable yang dicoba berurutan (paket resmi python.org via NuGet)
set "PY_VERSIONS=3.12.10 3.12.9 3.12.8 3.12.7"

echo ============================================================
echo   SETUP OTOMATIS: Mosquitto MQTT + Python + Jupyter Notebook
echo   Lokasi instalasi: %ROOT%
echo ============================================================
echo.

if not exist "%DL%" mkdir "%DL%"

REM ------------------------------------------------------------------
REM [1/4] Python portable di folder lokal
REM ------------------------------------------------------------------
echo [1/4] Python portable
if exist "%PY_EXE%" (
    echo    Python lokal sudah ada, dilewati.
    goto :py_ok
)
for %%V in (%PY_VERSIONS%) do (
    if not exist "%PY_EXE%" call :get_python %%V
)
if not exist "%PY_EXE%" (
    echo    [GAGAL] Python tidak bisa diunduh. Periksa koneksi internet.
    goto :fail
)
:py_ok
"%PY_EXE%" --version
echo.

REM ------------------------------------------------------------------
REM [2/4] pip + library Python (paho-mqtt, jupyterlab, dll)
REM ------------------------------------------------------------------
echo [2/4] Memasang pip dan library Python ...
"%PY_EXE%" -m pip --version >nul 2>&1
if errorlevel 1 "%PY_EXE%" -m ensurepip --upgrade
"%PY_EXE%" -m pip install --upgrade pip --no-warn-script-location
if errorlevel 1 goto :fail
"%PY_EXE%" -m pip install -r "%ROOT%\requirements.txt" --no-warn-script-location
if errorlevel 1 (
    echo    [GAGAL] Instalasi library Python gagal.
    goto :fail
)
echo.

REM ------------------------------------------------------------------
REM [3/4] Mosquitto MQTT broker di folder lokal
REM ------------------------------------------------------------------
echo [3/4] Mosquitto MQTT broker
set "MQ_WARN="
if exist "%MQ_DIR%\mosquitto.exe" (
    echo    Mosquitto lokal sudah ada, dilewati.
    goto :mq_ok
)
echo    Installer Mosquitto butuh izin Administrator.
echo    Klik YES pada jendela UAC yang muncul.
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\scripts\install_mosquitto.ps1" -Dest "%MQ_DIR%" -DownloadDir "%DL%"
if not exist "%MQ_DIR%\mosquitto.exe" (
    echo    [PERINGATAN] Mosquitto belum terpasang. Python dan Jupyter tetap bisa dipakai.
    echo    Jalankan setup.bat lagi untuk mencoba ulang.
    set "MQ_WARN=1"
)
:mq_ok
echo.

REM ------------------------------------------------------------------
REM [4/4] Verifikasi
REM ------------------------------------------------------------------
echo [4/4] Verifikasi instalasi
"%PY_EXE%" -c "import paho.mqtt, jupyterlab, pandas, matplotlib; print('   paho-mqtt', paho.mqtt.__version__, '| jupyterlab', jupyterlab.__version__, '| pandas', pandas.__version__)"
if errorlevel 1 goto :fail
if exist "%MQ_DIR%\mosquitto.exe" "%MQ_DIR%\mosquitto.exe" -h 2>&1 | findstr /i /c:"mosquitto version"

echo.
echo ============================================================
if defined MQ_WARN (
    echo   SETUP SELESAI SEBAGIAN - Mosquitto belum terpasang
) else (
    echo   SETUP SELESAI
)
echo ============================================================
echo   start_all.bat      : jalankan broker + Jupyter Lab sekaligus
echo   start_broker.bat   : jalankan broker MQTT saja - port 1883
echo   start_jupyter.bat  : jalankan Jupyter Lab saja
echo   uji_mqtt.bat       : tes publish/subscribe ke broker lokal
echo ============================================================
echo.
pause
exit /b 0

:fail
echo.
echo ============================================================
echo   SETUP GAGAL. Baca pesan error di atas, lalu jalankan ulang.
echo ============================================================
pause
exit /b 1

REM ------------------------------------------------------------------
REM Subrutin: unduh Python portable dari NuGet - paket resmi python.org
REM ------------------------------------------------------------------
:get_python
set "V=%~1"
echo    - mencoba Python %V% ...
set "ZIP=%DL%\python-%V%.zip"
set "TMPX=%DL%\python-%V%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest -UseBasicParsing -Uri 'https://www.nuget.org/api/v2/package/python/%V%' -OutFile '%ZIP%'; exit 0 } catch { exit 1 }"
if errorlevel 1 (
    if exist "%ZIP%" del /q "%ZIP%"
    exit /b 1
)
echo      mengekstrak ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Expand-Archive -Force -LiteralPath '%ZIP%' -DestinationPath '%TMPX%'"
if not exist "%TMPX%\tools\python.exe" exit /b 1
if exist "%PY_DIR%" rmdir /s /q "%PY_DIR%"
move "%TMPX%\tools" "%PY_DIR%" >nul
rmdir /s /q "%TMPX%"
del /q "%ZIP%"
exit /b 0
