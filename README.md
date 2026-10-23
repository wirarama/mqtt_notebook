# MQTT + Python + Jupyter Notebook (Windows, portable)

Semua komponen dipasang **di dalam folder ini** — tidak mengubah Python atau PATH sistem.

## Cara pakai
1. Klik dua kali **`setup.bat`** (butuh internet, sekali saja, ±5–10 menit).
   - Mengunduh Python 3.12 portable → `python\`
   - Memasang paho-mqtt, JupyterLab, pandas, matplotlib
   - Memasang Mosquitto → `mosquitto\` (muncul satu jendela UAC, klik **Yes**)
2. Klik **`start_all.bat`** → broker MQTT jalan di jendela terpisah + Jupyter Lab terbuka di browser.
3. Buka `notebooks/01_mqtt_dasar.ipynb`, jalankan sel satu per satu.

## Daftar file
| File | Fungsi |
|---|---|
| `setup.bat` | Instalasi otomatis (aman dijalankan ulang; komponen yang sudah ada dilewati) |
| `start_all.bat` | Broker + Jupyter Lab |
| `start_broker.bat` | Broker Mosquitto saja (port 1883) |
| `start_jupyter.bat` | Jupyter Lab saja |
| `stop_all.bat` | Hentikan broker + Jupyter Lab (hanya yang berjalan dari folder ini) |
| `uji_mqtt.bat` | Tes publish/subscribe ke broker (`uji_mqtt.bat 192.168.1.10` untuk broker lain) |
| `bersihkan.bat` | Hapus Python, Mosquitto, dan unduhan lokal |
| `config/mosquitto.conf` | Konfigurasi broker (WebSocket & password tersedia sebagai opsi) |
| `requirements.txt` | Daftar library Python — tambahkan lalu jalankan `setup.bat` lagi |

## Catatan
- Saat broker pertama kali dijalankan, Windows Firewall mungkin bertanya — izinkan **Private network** agar ESP32/ESP8266 di jaringan yang sama bisa terhubung ke IP laptop ini.
- Jika port 1883 sudah dipakai (mis. ada Mosquitto lain sebagai Windows Service), hentikan dulu: `net stop mosquitto` (CMD Administrator).
- Pasang library tambahan: `python\python.exe -m pip install nama_library`
