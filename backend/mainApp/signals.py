# mainApp/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from mainApp.models import Measurement
from mainApp.serializers import MeasurementSerializer
import json

@receiver(post_save, sender=Measurement)
def measurement_saved(sender, instance, created, **kwargs):
    if created:
        channel_layer = get_channel_layer()
        serializer = MeasurementSerializer(instance)
        async_to_sync(channel_layer.group_send)(
            "measurements",
            {
                "type": "send_new_measurement",
                "measurements": [serializer.data],  # send as list for consistency
            }
        )
