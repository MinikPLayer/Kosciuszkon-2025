import threading
import os
from django.apps import AppConfig

class MainAppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'mainApp'

    def ready(self):
        # Prevent running twice (still needed for runserver autoreload)
        if os.environ.get('RUN_MAIN') and not os.environ.get('MQTT_STARTED'):
            os.environ['MQTT_STARTED'] = 'true'
            from .connection import start_mqtt
            import mainApp.signals  # noqa
            threading.Thread(target=start_mqtt, daemon=True).start()

        # For Daphne or production ASGI server (RUN_MAIN is not set)
        elif not os.environ.get('RUN_MAIN') and not os.environ.get('MQTT_STARTED'):
            os.environ['MQTT_STARTED'] = 'true'
            from .connection import start_mqtt
            import mainApp.signals  # noqa
            threading.Thread(target=start_mqtt, daemon=True).start()
