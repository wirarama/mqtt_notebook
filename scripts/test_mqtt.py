"""Tes cepat publish/subscribe ke broker MQTT lokal."""
import sys
import time

import paho.mqtt.client as mqtt

HOST = sys.argv[1] if len(sys.argv) > 1 else "localhost"
PORT = 1883
TOPIC = "uji/setup"
received = []


def on_connect(client, userdata, flags, reason_code, properties):
    print(f"Terhubung ke {HOST}:{PORT} ({reason_code})")
    client.subscribe(TOPIC)


def on_message(client, userdata, msg):
    received.append(msg.payload.decode())
    print(f"  diterima  [{msg.topic}] {msg.payload.decode()}")


client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id="uji-setup")
client.on_connect = on_connect
client.on_message = on_message

try:
    client.connect(HOST, PORT, keepalive=30)
except Exception as exc:  # noqa: BLE001
    print(f"[GAGAL] Tidak bisa terhubung ke broker {HOST}:{PORT} -> {exc}")
    print("Jalankan start_broker.bat terlebih dahulu.")
    sys.exit(1)

client.loop_start()
time.sleep(1)
for i in range(3):
    payload = f"pesan uji {i + 1}"
    client.publish(TOPIC, payload)
    print(f"  dikirim   [{TOPIC}] {payload}")
    time.sleep(0.5)
time.sleep(1)
client.loop_stop()
client.disconnect()

if len(received) == 3:
    print("\n[BERHASIL] Broker MQTT dan paho-mqtt berfungsi normal.")
    sys.exit(0)
print(f"\n[GAGAL] Hanya {len(received)}/3 pesan diterima.")
sys.exit(1)
