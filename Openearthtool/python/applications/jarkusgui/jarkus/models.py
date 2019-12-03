from django.db import models

# Create your models here.


class Source(models.Model):
    url = models.URLField()

    def __unicode__(self):
        return self.url


class CoastalArea(models.Model):
    name = models.CharField(max_length=100)
    number = models.IntegerField()
    source = models.ForeignKey(Source)

    def __unicode__(self):
        return '%s (%i)' % (self.name, self.number)

    class Meta:
        ordering = ('number', )


class Transect(models.Model):
    number = models.IntegerField()
    coastal_area = models.ForeignKey(CoastalArea)
    index = models.IntegerField()
    source = models.ForeignKey(Source)

    def __unicode__(self):
        return '%i (%s)' % (self.number, self.coastal_area.name)


class Date(models.Model):
    date = models.DateField()
    index = models.IntegerField()
    source = models.ForeignKey(Source)

    def __unicode__(self):
        return '%s' % self.date.strftime('%Y-%m-%d')

    class Meta:
        ordering = ('-date',)
