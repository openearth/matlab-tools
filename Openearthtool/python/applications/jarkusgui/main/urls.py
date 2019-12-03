__author__ = 'heijer'

from django.conf.urls import patterns, url
from . import views

from django.views.generic import TemplateView
# from django.core.management import call_command

urlpatterns = patterns('',
    url(r'^$', TemplateView.as_view(template_name='main/index.html'), name='index'),
    )
