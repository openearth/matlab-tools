from django.shortcuts import render
from django.views import generic
from django.http import HttpResponseRedirect, HttpResponse, JsonResponse
import matplotlib.pyplot as plt
from cStringIO import StringIO
from django.core.servers.basehttp import FileWrapper
from netCDF4 import Dataset
import models
import numpy as np
from highcharts.views import HighChartsLineView


# Create your views here.


class TransectView(generic.View):

    def get(self, request, *args, **kwargs):
        print request.GET.items()
        # url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc'
        url = models.Source.objects.filter(url__icontains='transect.nc').first().url
        aidx = int(request.GET['aidx'])
        tidx = int(request.GET['tidx'])

        T = models.Date.objects.filter(source__url=url, index=tidx)
        time = T.first().date.strftime('%Y')

        # initialize plot
        fig, ax = plt.subplots(figsize=(10, 5))

        # transect data
        ds = Dataset(url)
        trid = ds.variables['id'][aidx]
        cs = ds.variables['cross_shore'][:]
        z = ds.variables['altitude'][tidx, aidx, ]
        mask = z.mask
        ds.close()
        ax.set_title('transect %i (%s)' % (trid, time))
        ax.plot(cs[~mask], z[~mask], label='Profile')

        # dunefoot data
        src_df = models.Source.objects.filter(url__icontains='DF.nc').first()
        url_df = src_df.url
        aidx_df = models.Transect.objects.filter(source=src_df, number=trid)
        tidx_df = models.Date.objects.filter(source=src_df, date__year=time)
        if aidx_df.count() == 1 and tidx_df.count() == 1:
            ds = Dataset(url_df)
            cs_df = ds.variables['dune_foot_threeNAP_cross'][tidx_df.first().index, aidx_df.first().index]
            z_df = ds.variables['dune_foot_threeNAP'][tidx_df.first().index, aidx_df.first().index]
            if not np.isnan(cs_df):
                ax.plot(cs_df, z_df, 'o', label='Dunefoot (NAP %+.2f m)' % z_df)
            ds.close()

        # water line data
        src_wl = models.Source.objects.filter(url__icontains='MHW_MLW.nc').first()
        url_wl = src_wl.url
        aidx_wl = models.Transect.objects.filter(source=src_wl, number=trid)
        tidx_wl = models.Date.objects.filter(source=src_wl, date__year=time)
        if aidx_wl.count() == 1 and tidx_wl.count() == 1:
            ds = Dataset(url_wl)
            mhw = ds.variables['mean_high_water'][aidx_wl.first().index]
            cs_mhw = ds.variables['mean_high_water_cross'][tidx_wl.first().index, aidx_wl.first().index]
            mlw = ds.variables['mean_low_water'][aidx_wl.first().index]
            cs_mlw = ds.variables['mean_low_water_cross'][tidx_wl.first().index, aidx_wl.first().index]
            if not np.isnan(cs_mhw):
                ax.plot(cs_mhw, mhw, 'o', label='MHW (NAP %+.2f m)' % mhw)
            if not np.isnan(cs_mlw):
                ax.plot(cs_mlw, mlw, 'o', label='MLW (NAP %+.2f m)' % mlw)
            ds.close()

        # bkl tkl data
        src_kl = models.Source.objects.filter(url__icontains='BKL_TKL_TND.nc').first()
        url_kl = src_kl.url
        aidx_kl = models.Transect.objects.filter(source=src_kl, number=trid)
        tidx_kl = models.Date.objects.filter(source=src_kl, date__year=time)
        if aidx_kl.count() == 1 and tidx_kl.count() == 1:
            ds = Dataset(url_kl)
            cs_bkl = ds.variables['basal_coastline'][tidx_kl.first().index, aidx_kl.first().index]
            z_bkl = np.interp(cs_bkl, cs[~mask], z[~mask])
            cs_tkl = ds.variables['testing_coastline'][tidx_kl.first().index, aidx_kl.first().index]
            z_tkl = np.interp(cs_tkl, cs[~mask], z[~mask])
            if not np.isnan(cs_bkl):
                ax.plot(cs_bkl, z_bkl, '>', label='BKL')
            if not np.isnan(cs_bkl):
                ax.plot(cs_tkl, z_tkl, '^', label='TKL')
            ds.close()

        # mkl data
        src_mkl = models.Source.objects.filter(url__icontains='MKL.nc').first()
        url_mkl = src_mkl.url
        aidx_mkl = models.Transect.objects.filter(source=src_mkl, number=trid)
        tidx_mkl = models.Date.objects.filter(source=src_mkl, date__year=time)
        if aidx_mkl.count() == 1 and tidx_mkl.count() == 1:
            ds = Dataset(url_mkl)
            cs_mkl = ds.variables['momentary_coastline'][tidx_mkl.first().index, aidx_mkl.first().index]
            z_mkl = np.interp(cs_mkl, cs[~mask], z[~mask])
            ax.plot(cs_mkl, z_mkl, 's', label='MKL')
            ds.close()

        ax.legend(numpoints=1)
        buf = StringIO()
        plotproperties = {'format': 'svg'}
        fig.savefig(buf, **plotproperties)
        buf.seek(0)
        wrapper = FileWrapper(buf)
        # return a response which streams the wrapped buffer.
        return HttpResponse(wrapper, content_type='image/svg+xml')


class JSONAreaView(generic.View):

    def get(self, request, *args, **kwargs):
        # url = models.Source.objects.filter(url__icontains='transect.nc').first().url
        src = models.Source.objects.filter(url__icontains='transect.nc').first()
        cas = models.CoastalArea.objects.filter(source=src)
        context = [{'number': ca.number, 'name': ca.name} for ca in cas]
        return JsonResponse(context, safe=False)


class JSONTimeView(generic.View):

    def get(self, request, *args, **kwargs):
        # url = models.Source.objects.filter(url__icontains='transect.nc').first().url
        src = models.Source.objects.filter(url__icontains='transect.nc').first()
        fmt = '%Y'
        if 'fmt' in request.GET.keys():
            fmt = request.GET['fmt']
        context = [{'date': dt.date.strftime(fmt), 'index': dt.index} for dt in models.Date.objects.filter(source=src)]
        return JsonResponse(context, safe=False)


class JSONTransectView(generic.View):

    def get(self, request, *args, **kwargs):
        url = models.Source.objects.all().first().url
        src = models.Source.objects.filter(url=url).first()
        filterkwargs = {}
        if 'area' in request.GET.keys():
            ca = models.CoastalArea.objects.filter(number=request.GET['area'])
            filterkwargs['coastal_area'] = ca
        context = [{'number': tr.number, 'index': tr.index} for tr in models.Transect.objects.filter(source=src, **filterkwargs)]
        return JsonResponse(context, safe=False)


class BarView(HighChartsLineView):
    # categories = ['Orange', 'Bananas', 'Apples']
    aidx = 200
    tidx = 50
    src = models.Source.objects.all().first()

    @property
    def title(self):
        trid = models.Transect.objects.get(index=self.aidx, source=self.src).number
        yr = models.Date.objects.filter(index=self.tidx, source=self.src).first().date.strftime('%Y')
        return '%i (%s)' % (trid, yr)

    def get_ajax(self, request, *args, **kwargs):
        getitems = dict(request.GET.items())
        if 'aidx' in getitems:
            self.aidx = getitems['aidx']
        if 'tidx' in getitems:
            self.tidx = getitems['tidx']
        return self.render_json_response(self.get_data())

    @property
    def series(self):
        result = []
        ds = Dataset(self.src.url)
        trid = ds.variables['id'][self.aidx]
        cs = ds.variables['cross_shore'][:]
        z = ds.variables['altitude'][self.tidx, self.aidx, ]
        mask = z.mask
        ds.close()
        data = zip(cs[~mask].tolist(),z[~mask].tolist())
        print data
        result.append({'name': 'transect', "data": data})
        return result