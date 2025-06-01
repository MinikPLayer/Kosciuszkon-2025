from django.contrib import admin

from mainApp.models import AppUser, Measurement

# Register your models here.

admin.site.register(AppUser)
admin.site.register(Measurement)