__author__ = 'heijer'

from django.conf.urls import patterns, url
from . import views

from django.views.generic import TemplateView
# from django.core.management import call_command

urlpatterns = patterns('',
    url(r'^transect$', views.TransectView.as_view(), name='transect'),
    url(r'^json/areas$', views.JSONAreaView.as_view(), name='json-areas'),
    url(r'^json/dates$', views.JSONTimeView.as_view(), name='json-dates'),
    url(r'^json/transects$', views.JSONTransectView.as_view(), name='json-transects'),
    url(r'^high/transect$', views.BarView.as_view(), name='high-transect'),
    )
