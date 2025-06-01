import json
import random
from channels.generic.websocket import AsyncWebsocketConsumer
from asyncio import sleep
from datetime import datetime
import math

class TemperatureConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.accept()
        print("WebSocket connected")
        await self.send_temperature_data()

    async def disconnect(self, close_code):
        print(f"WebSocket disconnected with code: {close_code}")

    async def send_temperature_data(self):
        base_temp = 25.0
        while True:
            try:
                # Simulate daily temperature variation
                hour = datetime.now().hour
                daily_variation = -5 * math.cos(2 * math.pi * hour / 24)
                random_variation = random.uniform(-2, 2)
                temperature = round(base_temp + daily_variation + random_variation, 1)

                await self.send(json.dumps({
                    'temperature': temperature,
                    'timestamp': datetime.now().strftime("%H:%M:%S"),
                    'is_alert': temperature > 30 or temperature < 15
                }))
                await sleep(1)
            except Exception as e:
                print(f"Error in send_temperature_data: {e}")
                break