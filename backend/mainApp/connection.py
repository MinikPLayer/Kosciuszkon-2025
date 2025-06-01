import json
import paho.mqtt.client as paho
import ssl
from mainApp.models import Measurement
import django

# Jeśli używasz standalone skryptu, zadbaj o ustawienia Django
# django.setup()  # tylko jeśli ten plik byłby uruchamiany niezależnie

def on_connect(client, userdata, flags, rc):
    print("Połączono z brokerem:", rc)
    client.subscribe("ENERGY_1234")

def on_message(client, userdata, msg):
    print(f"Wiadomość: {msg.topic} → {msg.payload.decode()}")
    if msg.topic == "ENERGY_1234":
        try:
            payload = json.loads(msg.payload.decode())

            Measurement.objects.create(
                sensor="ENERGY_1234_humidity",
                value=payload['humidity']['value']
            )
            Measurement.objects.create(
                sensor="ENERGY_1234_temp",
                value=payload['temp']['value']
            )
        except json.JSONDecodeError as e:
            print(f"Error decoding JSON: {e}")
        except KeyError as e:
            print(f"Missing expected key in payload: {e}")
        except Exception as e:
            print(f"Error processing message: {e}")

def start_mqtt():
    client = paho.Client()
    client.username_pw_set("hivemq.webclient.1741361005809", "Dtf>&v4?XW8pb39BE:xC")
    client.tls_set(tls_version=ssl.PROTOCOL_TLS)
    client.on_connect = on_connect
    client.on_message = on_message

    client.connect("66159fe671ed443f94b00666425069a3.s1.eu.hivemq.cloud", 8883)
    client.loop_forever()
