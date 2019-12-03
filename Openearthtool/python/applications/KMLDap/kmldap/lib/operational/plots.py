import cStringIO

import matplotlib
matplotlib.use('Agg')
from matplotlib.backends.backend_svg import FigureCanvasSVG
from matplotlib import pyplot as plt

import numpy as np
import numpy.ma

import os, sys, tempfile

import enthought.mayavi
import enthought.mayavi.modules
import enthought.mayavi.tools.pipeline
from enthought.mayavi.tools.pipeline import array2d_source, vector_field, warp_scalar, surface, image_actor
from enthought.mayavi.tools.engine_manager import get_engine
from enthought.mayavi import mlab

mlab.options.offscreen = True

import sii

def timetable(plotproperties=None):
    """create a timeseries plot for a transect"""
    if plotproperties is None:
        plotproperties = {}

    fig = plt.figure(figsize=(6, 3))
    canvas = FigureCanvasSVG(fig)
    f = cStringIO.StringIO()
    points = plt.plot([1,2,3],[4,3,1], '.')[0]
    fig.patch.set_alpha(0.1)
    fig.patch.set_facecolor('green')
    fig.patch.set_gid('iamfigurepatch')
    
    axes = fig.axes[0]
    fig.set_alpha(0)
    fig.set_gid('iamfigure')
    fig.set_url('http://www.nu.nl')
    axes.patch.set_alpha(0.1)
    axes.patch.set_gid('iampatch')
    points.set_gid('iampoints')
    points.set_alpha(0.1)
    circle = plt.Circle((2,2), radius=1)
    circle.set_url('http://www.nu.nl')
    circle.set_gid('IAMCIRCLE')
    axes.add_patch(circle)
    axes.set_axis_off()

    # setup date ticks, maybe this can be done shorter
    datelocator = matplotlib.dates.AutoDateLocator()
    dateformatter = matplotlib.dates.AutoDateFormatter(datelocator)
    if fig.axes:
        fig.axes[0].xaxis.set_major_formatter(dateformatter)
    plotproperties['format'] = 'svg'
    canvas.print_svg(f)
    f.seek(0)
    img = f.read()
    f.close()
    
    return f

def plot(dataset, ti, var, colorbar=True, plotproperties=None, limits=None, threshold=0.5):
    """
    mark the unsafe areas based on criterium of waterdepth > x and current speed >y m/s.

    hv_c = 0.0929(e^0.001906Lm+1.09)**2 (Abt et al. (1989)) <-- best experiment setup...
    threshold = 0.0929*(np.exp(0.001906*1.5*50)+1.09)**2 -> 0.46
    hv_c = 0.004Lm + 0.2 (Karvonen et al. 2000)
    
    """
    
    # define grid
    lat = dataset.variables['lat']
    lon = dataset.variables['lon']
    
    # determine figure type: axes+colorbar or no axes
    if colorbar:
        fig = plt.figure(figsize=(6,4))
        axes = fig.add_axes((0.15, 0.15, 0.7, 0.7))
    else:
        fig = plt.figure(figsize=(18,12))
        axes = fig.add_axes((0.0, 0.0, 1.0, 1.0))
        
    if not var in dataset.variables and var[0:4] == 'sii_':
        # get sii
        data = sii.get_sii(dataset, ti, var, threshold)
        mesh = axes.contourf(lon, lat, data, colors=('b', 'y', 'g', 'r'),
                                levels=[0,1,2,3,4], extend='max', antialiased=True)
    else:
        # get raw data
        data = dataset.variables[var][ti,:]
        mesh = axes.pcolormesh(lon, lat, data)
            
    if colorbar:
        for loc, spine in axes.spines.iteritems():
            if loc in ['left','bottom']:
                spine.set_position(('outward',10)) # outward by 10 points
            elif loc in ['right','top']:
                spine.set_color('none') # don't draw spine
            else:
                raise ValueError('unknown spine location: %s'%loc)
            
        axes.xaxis.set_ticks_position('bottom')
        axes.yaxis.set_ticks_position('left')
        
        fig.colorbar(mesh)
        
        axes.set_title(var)
        axes.set_xlabel('longitude [degrees_east]')
        axes.set_ylabel('latitude [degrees_north]')
    else:
        limits=(lon.min(), lon.max(), lat.min(), lat.max())
        
        axes.axis(limits)
        axes.set_axis_off()
        
    # store image in virtual file
    f = cStringIO.StringIO()
    fig.savefig(f, transparent=True)
    f.seek(0)
    img = f.read()
    f.close()
    
    return img

def plot3d(dataset, ti, var, colorbar=True, plotproperties=None, limits=None, warp_scale=3):
    
    # define grid
    lat = dataset.variables['lat']
    lon = dataset.variables['lon']
    
    enthought.mayavi.tools.figure.clf()
    
    data = get_timestep(dataset, ti)
    sources, warps, visuals = set_pipelines(data, warp_scale=warp_scale)
    
    engine = get_engine()
    
    fh, fname = tempfile.mkstemp(suffix='.png')
    img = ''
    
    scene = engine.current_scene.scene
    scene.background=(0,0,0)
    
    '''
    scene.camera.position = [178.27975363873207, -233.104575382924, 69.4489202081852]
    scene.camera.focal_point = [-0.5, -0.5, 7.7924995422363281]
    scene.camera.view_angle = 30.0
    scene.camera.view_up = [-0.082304568656042021, 0.19576445694500177, 0.97719099227089257]
    scene.camera.clipping_range = [74.543080456734231, 584.03205522037115]
    scene.camera.compute_view_plane_normal()
    '''
    
    os.close(fh)
    
    try:
        scene.save_png(fname)
        fh = open(fname,'rb')
        img = fh.read()
        fh.close()
    finally:
        os.unlink(fname)
    
    return img

def set_pipelines(data, warp_scale=3):
    sources = {}
    
    # weird fix called after forest gump
    gump = numpy.ones(data['zb'].shape)
    gump[:,:] = data['zb'][:,:]
    
    sources['zb'] = array2d_source(gump, name='zb')
    sources['zs'] = array2d_source(numpy.ma.masked_array(data['zs']+data['H'],
                                                         mask=data['dry'],
                                                         fill_value=np.nan).filled(),
                                                         name='zs')
    sources['zb_diff'] = array2d_source(data['zb_diff'], name='zb_diff')
    sources['vector'] = vector_field(data['u'],data['v'],data['w'])
    
    warps = {}
    warps['zb'] = warp_scalar(sources['zb'],
                              warp_scale=warp_scale)
    warps['zs'] = warp_scalar(sources['zs'],
                              warp_scale=warp_scale)

    visuals = {}
    visuals['zb'] = surface(warps['zb'], colormap='gist_earth')
    visuals['zs'] = surface(warps['zs'], opacity=0.5,
                            colormap='PuBuGn', vmin=0, vmax=5)
    visuals['zb_diff'] = image_actor(sources['zb_diff'], colormap='PiYG',
                                     opacity=0.5, vmin=-1,vmax=1)
    
    visuals['zb_diff'].actor.position = np.array([  0.,   0., -70.])
    
    visuals['zs'].module_manager.scalar_lut_manager
    visuals['zs'].module_manager.scalar_lut_manager.reverse_lut = True
    visuals['zs'].actor.property.ambient_color=(0.2,0.6,0.7)
    visuals['zs'].actor.property.ambient = 0.20000000000000001
    visuals['zs'].actor.property.diffuse_color = (0.24313725490196078, 0.74509803921568629, 0.39215686274509803)
    visuals['zs'].actor.property.specular_power=3
    visuals['zs'].actor.property.specular = 0.2
    
    return (sources, warps, visuals)

def get_timestep(dataset, ti, thin=1, vars=('u', 'v', 'x', 'y', 'zs', 'zb', 'H')):
    
    ts = {}
    for var in vars:
        if 'time' in dataset.variables[var].dimensions[0]:
            value = dataset.variables[var][ti,::thin,::thin]
        else:
            value = dataset.variables[var][:]
            
        ts[var] = value
        
    # add extra modified variables
    ts['w'] = np.zeros(ts['u'].shape)
    ts['zb0'] = dataset.variables['zb'][0,::thin,::thin]
    ts['zb_diff'] = ts['zb'] - ts['zb0']
    ts['dry'] = np.abs(ts['zs'] - ts['zb']) < sys.float_info.epsilon*10
    ts['ti_max'] = np.nonzero(dataset.variables['globaltime'][:] == dataset.variables['globaltime'][:].max())[0][0]
    
    return ts

def set_timestep(dataset, ti, sources):
    ts = get_timestep(dataset, ti)
    
    sources['zb'].scalar_data = ts['zb']
    sources['zs'].scalar_data = numpy.ma.masked_array(ts['zs']+st['H'],
                                                      mask=ts['dry'],
                                                      fill_value=np.nan).filled()
    sources['zb_diff'].scalar_data = ts['zb_diff']
    
    mlab.title(str(ti))




