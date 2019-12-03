__author__ = 'heijer'


from django.core.management.base import BaseCommand
from jarkus import models
from jarkusgui.settings import URLS
from jarkus.lib.nc_explore import get_time, get_id, get_coastalareas


class Command(BaseCommand):
    help = 'Fill DataBase'

    def handle(self, *args, **options):
        for url in URLS:
            src = models.Source.objects.filter(url=url)
            if src.count() > 0:
                continue

            # add source
            src = models.Source(url=url)
            src.save()

            # add coastal areas
            coastal_areas = get_coastalareas(url)
            for ca in coastal_areas:
                caobj = models.CoastalArea(source=src, **ca)
                caobj.save()

            # add times
            for i, t in enumerate(get_time(url)):
                dt = models.Date(date=t, index=i, source=src)
                dt.save()

            # add transect ids
            for i, trid in enumerate(get_id(url)):
                ca_number = int((trid - trid % 1e6) / 1e6)
                ca = models.CoastalArea.objects.get(number=ca_number, source=src)
                trobj = models.Transect(number=trid, index=i, source=src, coastal_area=ca)
                trobj.save()

