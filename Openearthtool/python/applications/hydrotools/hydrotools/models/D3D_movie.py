# -*- coding: utf-8 -*-
"""
Created on Tue Oct 13 08:39:37 2015

@author: winsemi

$Id: D3D_movie.py 12883 2016-09-09 12:49:48Z hoch $
$Date: 2016-09-09 05:49:48 -0700 (Fri, 09 Sep 2016) $
$Author: hoch $
$Revision: 12883 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/hydrotools/models/D3D_movie.py $
$Keywords: $

"""
# standard packs
import os, sys
import numpy as np
import pdb
# plot packs
import matplotlib.animation as animation
import matplotlib.cm as cm
import matplotlib
import cartopy.crs as ccrs
#import cartopy.feature
from cartopy.io.img_tiles import MapQuestOpenAerial
import matplotlib.pyplot as plt
import shapely.geometry as geom

# file I/O
import netCDF4 as nc

def fmplot(cellcoords, variable, ax, projection, dilation=0.2, **kwargs):
    # I have to recreate the grid for each plot, or do I?
    # dilate the cells a bit by 0.05
    cells_dilate = []
    for cell in cellcoords:
        dilate_by = (cell.max(axis=0)-cell.min(axis=0)).max()*dilation  # maximum coordinate difference
        cell_dilate = np.array(geom.Polygon(cell).buffer(dilate_by).boundary)
        cells_dilate.append(cell_dilate)
    cells = matplotlib.collections.PolyCollection(cells_dilate, **kwargs)
    cells.set_array(variable)
    #cells.set_edgecolors('none')
    #cells.set_linewidths(0.)
    im = ax.add_collection(cells) #, projection)
    # Scale the axis to meet the data
    #ax.autoscale()
    # add a colorbar
    cb = plt.colorbar(cells, ax=ax)  
    # set the labels
    cb.set_label('water depth [m]', fontsize = 18)
    ax.set_xlabel("x[m]", fontsize = 16)
    ax.set_ylabel("y[m]", fontsize = 14)
    # title = "Time:{}".format(fm.get_current_time())
    return im


def D3D_movie(nc_map_file, extent, file_out, figsize=(15, 10), variable='s1',
              quiver_x_var=None, quiver_y_var=None,
              satellite=False, zoom_level=4, initial_time_step=0, last_time_step=-1,
              cmap=cm.jet, clim=(-1, 2), interval=60):
    nc_map_file = os.path.abspath(nc_map_file)
    try:
        ds = nc.Dataset(nc_map_file, 'r')
    except RuntimeError:
        print('{:s} is not a valid NetCDF file'.format(nc_map_file))
    try:
        times = ds.variables['time']
        time_obj = nc.num2date(times[:], units=times.units, calendar='gregorian')
        var = ds.variables[variable]
        if variable == 's1':
            # make sure that cells with a zero depth are masked
            mask_depth_zero = True
            var_mask = ds.variables['waterdepth']
        else:
            mask_depth_zero = False
        if np.logical_and(not(quiver_x_var is None), not(quiver_y_var is None)):
            # load the x/y vars for quivering
            quiver_x = ds.variables[quiver_x_var]
            quiver_y = ds.variables[quiver_y_var]
        else:
            quiver_x = None
            quiver_y = None
    except:
        print('time field or variable "{:s}" is not found or improperly formatted'.format(variable))
        # set up the figure
    # test shape of variable
    if var.shape[0] < last_time_step:
        print('variable "{:s}" contains only {:d} time steps, {:d} requested'.format(variable, var.shape[0], last_time_step))
        sys.exit(1)
    if last_time_step == -1:
        last_time_step = var.shape[0]
    # read the cell bounds
    nx = ds.variables['NetNode_x'][:]
    ny = ds.variables['NetNode_y'][:]
    cell_x = ds.variables['FlowElem_xcc'][:]
    cell_y = ds.variables['FlowElem_ycc'][:]
    
    # find the cells that lie within the plot domain
    idx_x = np.logical_and(cell_x <= extent[1], cell_x >= extent[0])
    idx_y = np.logical_and(cell_y <= extent[3], cell_y >= extent[2])
    
    idx = np.where(np.logical_and(idx_x, idx_y))
    
    # print('Amount of cell corners is {:d}'.format(len(nx)))
    # The elements are created by linking the vertices together
    nelemnode = ds.variables['NetElemNode'][:]
    cellcoords = []
    for elem in nelemnode:
        try:
            elemx = nx[elem[~elem.mask]-1]
            elemy = ny[elem[~elem.mask]-1]
        except:
            # no mask found, use negative value
            elemx = nx[elem[elem>0]-1]
            elemy = ny[elem[elem>0]-1]
            
        cell = np.c_[elemx, elemy]
        cellcoords.append(cell)


    def ani_frame(file_out, time_obj, satellite):
        f = plt.figure(figsize=figsize)
        ax = plt.axes(projection=ccrs.PlateCarree())
    
        # 
        ax.set_extent(extent)
    
        # add satellite imagery over extent
        if satellite:
            tiler = MapQuestOpenAerial()
            ax.add_image(tiler, zoom_level)
    
        # start with the first time step
        #pdb.set_trace()
        var_data = var[initial_time_step, idx[0]]
        # mask values with no depth
        if mask_depth_zero:
            mask_data = var_mask[initial_time_step, idx[0]]
            mask_idx = mask_data==0
            var_data = np.ma.masked_where(mask_idx, var_data)
        else:
            mask_idx = np.array([])
        im = fmplot(cellcoords,
                       variable=var_data,
                       ax=ax,
                       projection=ccrs.PlateCarree(),
                       clim=clim,
                       cmap=cmap,
                       linewidths=0.,
                       edgecolors='b')
        #pdb.set_trace()
        if np.logical_and(not(quiver_x is None), not(quiver_y is None)):
            us = quiver_x[initial_time_step, idx[0]]
            vs = quiver_y[initial_time_step, idx[0]]
            quiv = ax.quiver(cell_x, cell_y, 0.05*us, 0.05*vs, color='w', alpha=0.05, width=0.002, headwidth=1., headlength=2.) 
        else:
            quiv = None
        
        title = time_obj[initial_time_step].strftime('%Y-%m-%d %HH:%MM')
        ax.set_title(title)
        def update_img(n, var, time_obj, mask_idx, quiver_x, quiver_y):
            # global var, time_obj
            title = time_obj[n+initial_time_step].strftime('%Y-%m-%d %HH:%MM')
            print('Updating image {:s}'.format(title))
            tmp = var[n+initial_time_step, :]
            tmp = np.ma.masked_where(mask_idx, tmp)
            im.set_array(tmp)
            if np.logical_and(not(quiver_x is None), not(quiver_y is None)):
                us = quiver_x[n+initial_time_step, :]
                vs = quiver_y[n+initial_time_step, :]
                quiv.set_UVC(us, vs)
            ax.set_title(title)
            return im, quiv
    
        #legend(loc=0)
        ani = animation.FuncAnimation(f, update_img,
                                      last_time_step-initial_time_step,
                                      interval=interval, fargs=(var, time_obj, mask_idx, quiver_x, quiver_y))
        FFMpegWriter = animation.writers['ffmpeg']
        writer = FFMpegWriter(fps=10, bitrate=2500) #change fps (default: 25) for speed of animation and bitrate (default: 2500) for output size and quality
        ani.save(file_out, writer=writer, dpi=300) # writer=writer, 
        return im, quiv
    im, quiv = ani_frame(file_out, time_obj, satellite)
    ds.close()
    return im, quiv

plt.close('all')

nc_map_file = r''
extent = (-70, -48, -9, 3)


# extent = (-74, -45, -12, 3)
#extent = (-93, -79, 23, 32)
file_out = r'P:\1220011-dflowfm\3_Case_Studies\3_1_Amazon\FM\1way\1d2d\DFM_OUTPUT_20160523_AMA_1way_1d2dFM\20160523_AMA_1way_1d2dFM_mov.mp4'
im, quiv = D3D_movie(nc_map_file, extent, file_out, initial_time_step=0, last_time_step=-1, variable='waterdepth',
              satellite=True, zoom_level=5, cmap=cm.jet, clim=(0, 20), interval=60)
#im, quiv = D3D_movie(nc_map_file, extent, file_out, initial_time_step=150, last_time_step=151, variable='s1',
#              quiver_x_var='windx', quiver_y_var='windy', satellite=True, zoom_level=5, cmap=cm.jet, clim=(-1, 2), interval=60)
