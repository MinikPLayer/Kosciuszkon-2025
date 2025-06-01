import json
from channels.generic.websocket import AsyncWebsocketConsumer
from asgiref.sync import sync_to_async
from mainApp.models import Measurement
from mainApp.serializers import MeasurementSerializer


class MeasurementConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.channel_layer.group_add("measurements", self.channel_name)
        await self.accept()
        await self.send_measurements()  # Optional: initial snapshot

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard("measurements", self.channel_name)

    async def receive(self, text_data):
        # Not used unless client sends something
        pass

    async def send_new_measurement(self, event):
        print("dddddddddddddddddddd")
        if event["measurements"][0]['sensor'] == "ENERGY_1234_temp":
            await self.send(text_data=json.dumps({
                "measurements": event["measurements"]
            }, default=str))

    @sync_to_async
    def get_serialized_measurements(self):
        measurements = Measurement.objects.order_by('-saved_at')[:100]
        serializer = MeasurementSerializer(measurements, many=True)
        return serializer.data

    async def send_measurements(self):
        data = await self.get_serialized_measurements()
        await self.send(text_data=json.dumps({"measurements": data}, default=str))
