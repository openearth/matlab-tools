#!/usr/bin/env python

import os, sys, pickle

# numpy
import numpy

# matplotlib
import matplotlib
import matplotlib.pyplot

# mayavi
from enthought.mayavi.tools.pipeline import *
from enthought.mayavi.tools.engine_manager import get_engine
from enthought.mayavi import mlab

# pydap
#import pydap.client

# netcdf4
import netCDF4

# sii
#sys.path.append('../applications/KMLDap/kmldap/lib/operational')
import sii


class XB_3DMovieMaker:
    '''
    3D rendering of XBeach model results based on NetCDF resources. Easy
    composition of storyboards in order to produce sleek animations.

    Usage:

    MM = XB_3DMovieMaker(url)
    MM.view(n=60, azimuth=210, elevation=60)  # change view angle
    MM.zoom(n=60, zoom=4)                     # change zoom level (incremental)
    MM.watch(n=120)                           # watch from current position
    '''

    # datasource
    url = ''
    layers = []
    title = ''
    dataset = None
    method = 'netcdf'

    # counters
    time_count = 0
    scene_count = 1

    # camers position
    zoomed = 1
    azimuth = None
    elevation = None
    distance = None
    layer_dist = 1500.
    focalpoint = None
    baseroll = 0

    # render options
    range = (-1, numpy.Inf)
    ratio = 1
    output_dir = '.'
    warp_scale = [50,50]
    margins = (1,1,1,1)
    background = (0,0,0)

    # figure components
    engine = None
    scene = None
    objects = None
    build = False

    def __init__(self, url, layers=['zb','zs','sedero','sii_vel','sii_depvel'], title=''):
        'Connect to NetCDF datasource and construction of 3D model'

        # connect to dataset
        self.url = url
        self.layers = layers
        self.title = title

        self.set_method(self.method)

        # initialize figure
        mlab.options.offscreen = True
        mlab.figure(size=(1600,1200))
        mlab.clf()

    def set_method(self, method):
        'Set read method'

        self.method = method

        if self.method == 'dap':
            self.dataset = pydap.client.open_url(self.url)
            self._pydaptonetcdf()
        else:
            self.dataset = netCDF4.Dataset(self.url, 'r', format='NETCDF4')

    def set_range(self, start, end):
        'Set range of scenes to be rendered from storyboard'

        self.range = (start, end)

    def set_ratio(self, ratio):
        'Set ratio between scenes to be rendered and timestep'

        self.ratio = numpy.max([1,ratio])

    def set_dir(self, outdir):
        'Set output directory'

        self.output_dir = outdir

        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)

    def set_layerdistance(self, distance):
        'Set distance of layers with respect to eachother'

        self.layer_dist = distance

    def set_distance(self, distance):
        'Set distance of camera'

        self.distance = distance

    def set_baseroll(self, roll):
        'Set default roll of camera'

        self.baseroll = roll

    def set_focalpoint(self, focalpoint):
        'Set focal point of camera'

        self.focalpoint = focalpoint

    def set_margins(self, x1=1, x2=1, y1=1, y2=1):
        'Set grid margins'

        self.margins = (max(1,x1), max(1,x2), max(1,y1), max(1,y2))

    def set_background(self, color):
        'Set background color'

        self.background = color

    def set_warpscale(self, both=None, bathy=None, waves=None):
        'Set warp scale of figure'

        if both == None:
            if not bathy == None:
                self.warp_scale[0] = bathy
            if not waves == None:
                self.warp_scale[1] = waves
        else:
            self.warp_scale = [both,both]

    def build_figure(self, show=False, rebuild=False):
        'Construct 3D model with bathymetry, water surface and siis'

        r, sources = self._get_sources(0)

        print 'build figure'

        x = r['globalx']
        y = r['globaly']

        lut = numpy.array([[0,0,255,255],[255,255,0,255],[0,255,0,255],[255,0,0,255]])

        self.objects = {}

        if 'zb' in self.layers:
            print '    layer "zb"'

            self.objects['zb'] = mlab.mesh(x, y, sources['zb'], name='zb', colormap='gist_earth')

        if 'zs' in self.layers:
            print '    layer "zs"'

            self.objects['zs'] = mlab.mesh(x, y, sources['zs'], name='zs', colormap='PuBuGn', opacity=0.5, vmin=0, vmax=self.warp_scale[1]*5)

            # make the waves look a bit more like waves.
            self.objects['zs'].module_manager.scalar_lut_manager
            self.objects['zs'].module_manager.scalar_lut_manager.reverse_lut = True
            self.objects['zs'].actor.property.ambient_color=(0.2,0.6,0.7)
            self.objects['zs'].actor.property.ambient = 0.20000000000000001
            self.objects['zs'].actor.property.diffuse_color = (0.24313725490196078, 0.74509803921568629, 0.39215686274509803)
            self.objects['zs'].actor.property.specular_power=3
            self.objects['zs'].actor.property.specular = 0.2

        dz = 0.

        if 'sedero' in self.layers:
            print '    layer "sedero"'

            dz = dz - self.layer_dist

            self.objects['zb_diff'] = mlab.mesh(x, y, sources['zb_diff'], name='zb_diff', colormap='PiYG', vmin=-1, vmax=1)

            self.objects['zb_diff'].actor.actor.position = numpy.array([0.,0.,dz])
            self.objects['label1'] = mlab.text3d(x.max(), y.max(), dz+250, 'erosion / accretion', color=(1,1,1), orient_to_camera=False, orientation=(90, 0, 180), scale=200)

        if 'sii_vel' in self.layers:
            print '    layer "sii_vel"'

            dz = dz - self.layer_dist

            self.objects['sii_vel'] = mlab.mesh(x, y, sources['sii_vel'], name='sii_vel', vmin=1, vmax=4)

            self.objects['sii_vel'].actor.actor.position = numpy.array([0.,0.,dz])
            self.objects['sii_vel'].module_manager.scalar_lut_manager.lut.table = lut
            self.objects['label2'] = mlab.text3d(x.max(), y.max(), dz+250, 'SII: evacuation, depth velocity', color=(1,1,1), orient_to_camera=False, orientation=(90, 0, 180), scale=200)

        if 'sii_depvel' in self.layers:
            print '    layer "sii_depvel"'

            dz = dz - self.layer_dist

            self.objects['sii_depvel'] = mlab.mesh(x, y, sources['sii_depvel'], name='sii_depvel', vmin=1, vmax=4)

            self.objects['sii_depvel'].actor.actor.position = numpy.array([0.,0.,dz])
            self.objects['sii_depvel'].module_manager.scalar_lut_manager.lut.table = lut
            self.objects['label3'] = mlab.text3d(x.max(), y.max(), dz+250, 'SII: swimmer safety, velocity', color=(1,1,1), orient_to_camera=False, orientation=(90, 0, 180), scale=200)

        if len(self.title)>0:
            self.objects['title'] = mlab.text(0.1, 0.8, self.title, color=(1,1,1), width=0.8)

        mlab.draw()

        if show:
            mlab.show()

        self.engine = get_engine()
        self.scene = self.engine.current_scene.scene
        self.scene.background=self.background

        if self.azimuth == None:
            self.azimuth = mlab.view()[0]
        if self.elevation == None:
            self.elevation = mlab.view()[1]
        if self.distance == None:
            self.distance = mlab.view()[2]
        if self.focalpoint == None:
            self.focalpoint = mlab.view()[3]

        self.built = True

    def update(self, inc=1):
        'Update 3D model to current timestep'

        self.time_count = self.time_count + inc

        if inc > 0 and self.scene_count >= self.range[0] and \
            self.scene_count < self.range[1]:

            r, sources = self._get_sources(self.time_count)

            if 'zb' in self.layers:
                self.objects['zb'].mlab_source.z = sources['zb']

            if 'zs' in self.layers:
                self.objects['zs'].mlab_source.z = sources['zs']

            if 'sedero' in self.layers:
                self.objects['zb_diff'].mlab_source.scalars = sources['zb_diff']

            if 'sii_vel' in self.layers:
                self.objects['sii_vel'].mlab_source.scalars = sources['sii_vel']

            if 'sii_depvel' in self.layers:
                self.objects['sii_depvel'].mlab_source.scalars = sources['sii_depvel']

            mlab.draw()

    def save(self, inc=1):
        'Save current scene to PNG file'

        if not self.built:
            print 'ERROR: run build_figure() first'
            return

        #if numpy.abs(self.zoomed - 1) < .01:
            #self.scene.reset_zoom()

        self.scene.camera.compute_view_plane_normal()

        if self.scene_count % self.ratio == 0 or inc > self.ratio:
            self.update(inc)

        if self.scene_count >= self.range[0] and \
            self.scene_count < self.range[1]:

            self.scene.render()

            fname = os.path.join(self.output_dir, 'scene_'+ \
                str(self.scene_count)+'.png')
            self.scene.save_png(fname)

            print 'render scene #'+str(self.scene_count)+ \
                ' using timestep '+str(self.time_count)

        self.scene_count = self.scene_count + 1

    def watch(self, n=1, inc=1):
        'Generate a sequence of scenes from the current view'

        if self.scene_count < self.range[1]:
            for i in range(n):
                self.save(inc=inc)

                print '    watch'

    def zoom(self, n=1, zoom=2, inc=1):
        'Zoom the current view (zoom>1 is in and zoom<1 is out)'

        if self.scene_count < self.range[1]:
            for i in range(n):
                zoom_factor = float(zoom)**(1./n)
                self.scene.camera.zoom(zoom_factor)
                self.zoomed = self.zoomed*zoom_factor
                self.save(inc=inc)

                print '    zoom: '+str(self.zoomed)

    def view(self, n=1, azimuth=None, elevation=None, inc=1):
        'Change the view of the camera'

        if self.scene_count < self.range[1]:
            if azimuth == None:
                azimuth = self.azimuth
                da = 0
            else:
                da = azimuth - self.azimuth

                #if numpy.abs(da) > 180:
                #    da = numpy.sign(da) * (180 - numpy.abs(da))

            if elevation == None:
                elevation = self.elevation
                de = 0
            else:
                de = elevation - self.elevation

                #if numpy.abs(de) > 180:
                #    de = numpy.sign(de) * (180 - numpy.abs(de))

            for i in range(1,n+1):
                e = self.elevation+de*i/n
                a = self.azimuth+da*i/n % 360

                mlab.view(azimuth=a, elevation=e, \
                    distance=self.distance, focalpoint=self.focalpoint, \
                    reset_roll=True)

                if numpy.abs(e) < 5 or numpy.abs(e-180) < 5:
                    mlab.roll(-a-90)

                self.save(inc=inc)

                print '    view: '+str(mlab.view()[:2])

            self.azimuth = azimuth
            self.elevation = elevation

    ### PRIVATE FUNCTIONS #####################################################

    def _read_dataset(self, ti, thin=1, vars=('globalx', 'globaly', 'zs', 'zb', 'H')):
        'Read variables from dataset and determine secondary variables'

        m = self.margins

        r = {}
        for var in vars:
            dims  = self.dataset.variables[var].dimensions

            if 'globaltime' in dims:
                if dims.index('globaltime') == 0:
                    value = self.dataset.variables[var][ti,:,:]
                else:
                    value = self.dataset.variables[var]
            else:
                value = self.dataset.variables[var]

            if 'globaly' in dims:
                value = value[m[2]:-m[3]:thin,:]
            if 'globalx' in dims:
                value = value[:,m[0]:-m[1]:thin]

            r[var] = value

        r['zb0'] = self.dataset.variables['zb'][0,m[2]:-m[3]:thin,m[0]:-m[1]:thin]
        r['t_max'] = numpy.nonzero(self.dataset.variables['globaltime'][:] == \
            self.dataset.variables['globaltime'][:].max())[0][0]

        r['zb_diff'] = r['zb'] - r['zb0']
        r['dry'] = numpy.abs(r['zs'] - r['zb']) < .01

        return r

    def _get_sources(self, ti, thin=1):
        'Read dataset and siis'

        m = self.margins

        print 'read source'

        r = self._read_dataset(ti, thin=thin)

        sources = {}

        for k in r.keys():
            sources[k] = self._hakkitakki(r[k])

        sources['zs'] = numpy.ma.masked_array(sources['zs']+sources['H'], \
            mask=sources['dry'], fill_value=numpy.nan).filled()

        sources['zb'] = self.warp_scale[0]*sources['zb']
        sources['zs'] = self.warp_scale[1]*sources['zs']

        # get sii's
        sources['sii_vel'] = sii.get_sii(self.dataset, ti, 'sii_vel', 0.5)
        sources['sii_vel'] = sources['sii_vel'][m[2]:-m[3]:thin,m[0]:-m[1]:thin]

        sources['sii_depvel'] = sii.get_sii(self.dataset, ti, 'sii_depvel', 0.46)
        sources['sii_depvel'] = sources['sii_depvel'][m[2]:-m[3]:thin,m[0]:-m[1]:thin]

        return r, sources

    def _hakkitakki(self, a):
        'Hakkitakki, caramba la bamba!'

        if a.ndim == 2:
            r = numpy.ones(a.shape)
            r[:,:] = a[:,:]
        else:
            r = a

        return r

    def _pydaptonetcdf(self):
        'Convert PyDAP data to NetCDF'

        self.dataset.variables = {}
        for var in self.dataset.keys():
            if isinstance(self.dataset[var], pydap.model.GridType):
                self.dataset.variables[var] = self.dataset[var][var]
                self.dataset.variables[var].attributes.update( \
                    self.dataset[var].attributes)
            else:
                self.dataset.variables[var] = self.dataset[var]