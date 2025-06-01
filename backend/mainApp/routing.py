from django.urls import re_path

from mainApp import consumers

websocket_urlpatterns = [
    re_path(r'ws/measurements/$', consumers.MeasurementConsumer.as_asgi()),
]