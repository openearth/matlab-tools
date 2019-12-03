#!/usr/bin/env python
"""
Created on Sat Nov 16 11:19:58 2014

@author: Hessel Winsemius and Tarasinta Perwitasari

$Id: dem_fill_dig_strahler.py 12545 2016-03-03 10:34:37Z winsemi $
$Date: 2016-03-03 02:34:37 -0800 (Thu, 03 Mar 2016) $
$Author: winsemi $
$Revision: 12545 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/sandbox/gis/dem_fill_dig_strahler.py $
$Keywords: $

The functions in this file dig and fill values in a space-borne 
digital elevation model following streamlines as given in a local 
drain direction file. The correction procedure ensures that a stream line
always flows down or remains horizontally. Regions where the elevation lifts
in downstream direction are "digged out"  in downstream direction, or "filled
up" in upstream direction. 

The filling and digging is necessary to remove the
effect of noise, too low resolution with respect to the channel dimensions
or effects of vegetation or islands within the river channel and to ensure
the DEM can be used in hydraulic modelling of river reaches. Typically, this
should be applied before using SRTM HydroSHEDS elevation and flow directions

The methods followed are described in:

Yamazaki, D., Baugh, C. A., Bates, P. D., Kanae, S., Alsdorf, D. E. and 
Oki, T.: Adjustment of a spaceborne DEM for use in floodplain hydrodynamic 
modeling, J. Hydrol., 436-437, 81-91, doi:10.1016/j.jhydrol.2012.02.045,
2012.

From Hessel Winsemius and Arjen Haag:
We adapted the function within a number of projects to enable usage over very
large domains. The original function followed stream lines all the way from their
origin to their outflow point. In this new version, we follow Strahler topology
prevent duplication of corrections across the domain.

Call the function dem_fill_dig to get started.

This tool is part of the hydrotools toolbox in the openearthtools suite.

keywords: DTM, filling routine

"""

import numpy as np
import pdb
import pandas as pd
from scipy.signal import convolve2d

def cut_area(src_arrays, centre, window):
    """
    Function returns a limited array from src array along with the idx axes for y and x coordinates
    src_arrays: list of arrays from which to cut
    centre: (y, x) coordinate of centre point
    window: size of window to use around the centre point

    """
    xmin = np.maximum(centre[1] - window, 0)
    xmax = np.minimum(centre[1] + window + 1, src_arrays[0].shape[1])
    ymin = np.maximum(centre[0] - window, 0)
    ymax = np.minimum(centre[0] + window + 1, src_arrays[0].shape[0])
    
    # check if cut area was on border of src array (used later on to adjust reverse flow directions)
    borders = []
    if centre[1] == 0:
        borders.append('xmin')
    if centre[1] == src_arrays[0].shape[1]-1:
        borders.append('xmax')
    if centre[0] == 0:
        borders.append('ymin')
    if centre[0] == src_arrays[0].shape[0]-1:
        borders.append('ymax')

    # now cut the array
    trg_arrays = []
    for src_array in src_arrays:
        trg_arrays.append(src_array[ymin:ymax, xmin:xmax])
    x_idx_cut = range(xmin, xmax)
    y_idx_cut = range(ymin, ymax)
    return trg_arrays, x_idx_cut, y_idx_cut, borders

def find_upstream_ldd(ldd, y_idx, x_idx, reverse_directions=np.array([[3, 2, 1], [6, 0, 4], [9, 8, 7]])):
    # look for upstream cells
    # cut out a 3x3 windows (1 neighbouring cell)
    (ldd_cut), x_idx_cut, y_idx_cut, borders = cut_area([ldd], (y_idx, x_idx), 1)
    # adjust reverse flow directions for border areas (remove part that is not included in cut of ldd)
    if len(borders) > 0:
        if 'xmax' in borders:
            reverse_directions = reverse_directions[:,[0,reverse_directions.shape[1]-2]]
        if 'ymax' in borders:
            reverse_directions = reverse_directions[[0,reverse_directions.shape[1]-2],:]
        if 'xmin' in borders:
            reverse_directions = reverse_directions[:,[1,reverse_directions.shape[1]-1]]
        if 'ymin' in borders:
            reverse_directions = reverse_directions[[1,reverse_directions.shape[1]-1],:]
    # compare the cut out ldd with the reverse directions to find out
    # which surrounding cell flows to the cell under consideration
    y_up_idx_cut, x_up_idx_cut = np.where(ldd_cut[0]==reverse_directions)
    # find the original idx value of the upstream cells
    y_up_idx = np.atleast_1d(np.array(y_idx_cut)[y_up_idx_cut])
    x_up_idx = np.atleast_1d(np.array(x_idx_cut)[x_up_idx_cut])
    #pdb.set_trace()
    # save old sink cell
    up_sinkcell = [(m, n) for m, n in zip(y_up_idx, x_up_idx)]
    return up_sinkcell

def find_downstream(ldd, idx_y, idx_x, flow_dirs=np.array([[7, 8, 9], [4, 5, 6], [1, 2, 3]])):
    """
    Find the index position of the first downstream cell
    
    """
    flow_dir_y = np.array([-1, 0, 1])
    flow_dir_x = np.array([-1, 0, 1])
    
    flow_dir = np.where(flow_dirs==ldd[idx_y, idx_x])
    y_dir, x_dir = flow_dir_y[flow_dir[0]], flow_dir_x[flow_dir[1]]
    idx_y_new = idx_y + y_dir[0]
    idx_x_new = idx_x + x_dir[0]
    return idx_y_new, idx_x_new

def catch_boundary(ldd, pit, ldd_fill, flow_dirs=np.array([[7, 8, 9], [4, 5, 6], [1, 2, 3]])):
    """Establishes which cells on an ldd lie on a catchment boundary (i.e. do 
    not have any upstream inflow points). Isolated pits are removed.
    """
    upstream_cells = np.zeros(ldd.shape)
    for dir_x in range(0, 3):
        for dir_y in range(0, 3):
            if np.logical_or(dir_x != 1, dir_y != 1): # only do this if the 
                                                      # cell is not itself!
                rev_flow_dir = flow_dirs[dir_y, dir_x]  # establish reverse 
                                                        # flow direction
                conv_arr = np.zeros((3, 3)); conv_arr[dir_y, dir_x] = 1.
                upstream_cells += np.int16(convolve2d(ldd,
                                                      conv_arr,
                                                      mode='same') == rev_flow_dir)
            # find where no upstream is found
    upstream_cells[ldd == ldd_fill] = ldd_fill
    catch_bound = np.logical_and(upstream_cells==0, ldd!=pit)
    idx = np.where(catch_bound)

    return idx, catch_bound


def stream_length(ldd, idx_upstream, pit,
                  flow_dirs=np.array([[7, 8, 9], [4, 5, 6], [1, 2, 3]]),
                  streams=None, upstream_points=None):
    """
    Calculate stream lengths by looping over all cells that lie on an upstream
    boundary.
    """
    if not(streams):
        streams = np.zeros(ldd.shape)
    if not(upstream_points):
        upstream_points = {}
        upstream_points['coordinates'] = zip(*idx_upstream)
        upstream_points['lengths'] = []
    else:
        upstream_points['coordinates'] += zip(*idx_upstream)
    for n, idx in enumerate(zip(*idx_upstream)):
        # find the positions of the downstream cells
        idx_down = [idx]
        idx_next = find_downstream(ldd, idx[0], idx[1])
        while np.logical_and(ldd[idx_next] != pit, streams[idx_next] == 0):
            idx_down.append(idx_next)
            idx_next = find_downstream(ldd, idx_next[0], idx_next[1])
            # print idx_next, ldd[idx_next]
        if streams[idx_next] > 0:
            len_next = streams[idx_next]
        else:
            len_next = 0
        # now make the length array
        stretch = len(idx_down) - np.arange(0, len(idx_down)) + len_next
        # write length array to idxs
        streams[zip(*idx_down)] = stretch
        upstream_points['lengths'].append(stretch.max())
    return streams, upstream_points

def fill_dig_streamline(dem, ldd, init_cell_y, init_cell_x, dem_fill=-9999.,
                        ldd_fill=255, pit=-9999., weight_fill=10.,
                        weight_dig=1., z_int_start=1.,
                        flow_dirs=np.array([[7, 8, 9], [4, 5, 6], [1, 2, 3]]),
                        dem_mod=None, strahler=None, cur_strahler=1):
    """
    Fills one streamline of a DEM starting at a user-given upstream point. 
    The result is that elevation values along the streamline are modified
    until the point where already modified values are found (in dem_mod).
    Any non-modified values must be NaN in the dem_mod variable.
    The user must call this function such, that first the longest streamline
    is modified, then the second longest, then third, etcetera
    
    The methodology followed is described by:
    Yamazaki, D., Baugh, C. A., Bates, P. D., Kanae, S., Alsdorf, D. E. and 
    Oki, T.: Adjustment of a spaceborne DEM for use in floodplain hydrodynamic 
    modeling, J. Hydrol., 436-437, 81-91, doi:10.1016/j.jhydrol.2012.02.045,
    2012.
    
    Inputs:
        dem:            2D-array (numpy) with elevation values
        ldd:            2D-array (numpy) with local drain direction values 
                        (default is the PCRaster directions)
        init_cell_x:    idx of x-coordinate of starting point of streamline
        init_cell_y:    idx of y-coordinate of starting point of streamline
        dem_fill:       fill value of missing data in dem
        ldd_fill:       fill value of missing data in ldd
        pit:            value of outflow elevation at pit (e.g. at ocean or 
                        interior basin)
        weight_fill:    weight given to filling of upstream elevation
        weight_dig:     weight given to digging of downstream elevation
        dem_mod=None:   2D-array (numpy) of modified elevation values (NaN 
                        where no modified values are found)
    outputs:
        dem_mod:        see inputs
    
    Note: as dem_mod, you can also insert a reference to an array in a NetCDF file
    This is very useful when the DEM is very large and does not fit in memory 
    at once
    
    """
    reverse_flow_dirs = np.fliplr(np.flipud(flow_dirs))
    reverse_flow_dirs[1, 1] = 0  # set to zero to not confuse things when a pit is encountered
    # if dem_mod does not exist yet, prepare it!
    if dem_mod is None:
        print('Preparing new dem')
        dem_mod = np.zeros(dem.shape)
        dem_mod[:] = np.nan
    if strahler is None:
        print('Preparing Strahler order map')
        strahler = np.zeros(dem.shape)
        strahler[:] = np.nan
    next_strahler_init_cell_y = None
    next_strahler_init_cell_x = None
    downstream_found = False


    # otherwise the DEM is already initialized and can be reused        
    idx_y, idx_x = init_cell_y, init_cell_x
    idx_list = [(idx_y, idx_x)]
    #up_cells = np.array([0.])  # dummy up_cells with length one
    # first make a list of topologically connected cells from the ldd
    # TODO: stop when a confluence is found (include the confluence)
    # stop when a pit (ldd==5) or confluence (more than one upstream cells) is found
    # first check if the point is a single pit without any connections
    if (cur_strahler == 1) and (ldd[idx_y, idx_x] == pit):
        # and if so, set to current strahler value (i.e. 1)
        strahler[idx_y, idx_x] = cur_strahler
    while np.logical_and(ldd[idx_y, idx_x] != pit, downstream_found is False):

        idx_y, idx_x = find_downstream(ldd, idx_y, idx_x, flow_dirs)
        idx_list.append((idx_y, idx_x))
        # check if the cell has more than one upstream cell
        up_cells = find_upstream_ldd(ldd, idx_y, idx_x)
        if len(up_cells) > 1:
            ## Possible conditions
            #


            # check if other tributary is of current strahler order
            # pdb.set_trace()
            if np.isnan(strahler[idx_y, idx_x]):
                # print('Two streams of order {:d} are merging. Saving idx for next order').format(cur_strahler)
                idx_y_list, idx_x_list = zip(*idx_list)
                strahler[idx_y_list[:-1], idx_x_list[:-1]] = cur_strahler
                # check if all upstream cells have the current strahler order. If so, add next point
                if np.any(np.isnan(strahler[zip(*up_cells)])):
                    downstream_found = True  # but don't add the point to the new list
                elif (strahler[zip(*up_cells)] == cur_strahler).sum() >= 2:
                    downstream_found = True
                    next_strahler_init_cell_y = idx_y
                    next_strahler_init_cell_x = idx_x
                    if ldd[idx_y, idx_x] == pit:
                        strahler[idx_y, idx_x] = cur_strahler + 1
                elif ldd[idx_y, idx_x] == pit:  # if all upstream values are filled and
                    strahler[idx_y, idx_x] = cur_strahler

        elif ldd[idx_y, idx_x] == pit:
            downstream_found = True
            idx_y_list, idx_x_list = zip(*idx_list)
            strahler[idx_y_list, idx_x_list] = cur_strahler


    # first fill in the dem_mod with the current elevation
    # find cells that are not yet modified in dem and give these the original dem values
    idx_y_list, idx_x_list = zip(*idx_list)
    idx_y_select = np.array(idx_y_list)[np.isnan(dem_mod[idx_y_list, idx_x_list])]
    idx_x_select = np.array(idx_x_list)[np.isnan(dem_mod[idx_y_list, idx_x_list])]
    dem_mod[idx_y_select, idx_x_select] = dem[idx_y_select, idx_x_select]
    # strahler[idx_y[-1], idx_x[-1]] = cur_strahler + 1


    # loop through all cells in the streamline of present strahler order stream
    for i, (idx_y, idx_x) in enumerate(idx_list[:-1]):
        # first find index of downstream cell
        # idx_y_down, idx_x_down = find_downstream(ldd, idx_y, idx_x, flow_dirs)
        z_min = dem_mod[idx_y, idx_x]
        z_max = dem_mod[idx_list[i+1]]
        # If there are no errors, do nothing and continue
        if z_max <= z_min:
            dem_mod[idx_y, idx_x] = z_min
        else:
            # first ensure that the z_max is not larger than the elevation of the upstream confluence point. This point
            # may not be filled to ensure that no new obstructions are generated for the up-stream reaches.
            z_max = np.minimum(z_max, dem_mod[idx_list[0]])
            z_var = np.arange(z_min, z_max + z_int_start, z_int_start)
            z_var = z_var[z_var <= z_max]
            err_min = 1e12  # make error start value very large
            
            for step, z_mod in enumerate(z_var):
                err = 0.
                down_count = 1  # amount of cells further downstream
                z_down = dem_mod[idx_list[i + down_count]]  # initiate with a very large number
                # loop until lower downstream value is found
                # stop the loop if the error with current elevation modification 
                # is larger than the smallest error found so far
                # or if the downstream elevation is smaller than modified elevation
                while np.logical_and(z_down > z_mod, err < err_min):
                    err += np.maximum(z_mod - z_down, 0)*weight_fill + np.maximum(z_down - z_mod, 0)*weight_dig
                    # np.abs(z_down - z_mod)*weight_down  # add difference between current and down
                    down_count += 1
                    if i + down_count >= len(idx_list):
                        break  # no more downstream cell values available in stream line
                    z_down = dem_mod[idx_list[i + down_count]]
                # now fill cell itself and upstream cells
                up_count = 0
                z_up = dem_mod[idx_list[i + up_count]]
                while np.logical_and(z_up < z_mod, err < err_min):
                    err += np.maximum(z_mod - z_up, 0)*weight_fill + np.maximum(z_up - z_mod, 0)*weight_dig
                    #err += np.abs(z_mod - z_up)*weight_up  # add difference between current and down
                    up_count -= 1
                    if i + up_count < 0:
                        break  # no more upstream cell values available in stream line
                    z_up = dem_mod[idx_list[i + up_count]]
                if err < err_min:
                    err_min = err
                    z_mod_select = z_mod
                # print 'z_down: ', z_down, 'z_mod: ', z_mod, 'error: ', err, 'err_min: ', err_min
            
            # z_mod_select is now optimized. Now perform correction
            # downstream
            down_count = 1
            if not('z_mod_select' in locals()):
                print 'missing z modification due to DEM missing values'
            else:                
                while dem_mod[idx_list[i + down_count]] > z_mod_select:
                    # print i + down_count, len(idx_list)
                    dem_mod[idx_list[i + down_count]] = z_mod_select
                    down_count += 1
                    if len(idx_list) <= i + down_count:
                        # we've reached the downstream end
                        break
                # upstream
                up_count = 0
                while dem_mod[idx_list[i + up_count]] < z_mod_select:
                    dem_mod[idx_list[i + up_count]] = z_mod_select
                    up_count -= 1
#
    return idx_list, dem_mod, strahler, next_strahler_init_cell_y, next_strahler_init_cell_x

def dem_fill_dig(dem, ldd, dem_fill, ldd_fill, pit, weight_fill=1.,
                 weight_dig=10., z_int=1.,
                 flow_dirs=np.array([[7, 8, 9], [4, 5, 6], [1, 2, 3]])):
    """
    This function will modify a given elevation model along the streamlines of
    a local drainage direction map, derived from this elevation model.
    
    The methodology followed is described by:
    Yamazaki, D., Baugh, C. A., Bates, P. D., Kanae, S., Alsdorf, D. E. and 
    Oki, T.: Adjustment of a spaceborne DEM for use in floodplain hydrodynamic 
    modeling, J. Hydrol., 436-437, 81-91, doi:10.1016/j.jhydrol.2012.02.045,
    2012.
    
    Inputs:
        dem:            2D-array (numpy) with elevation values
        ldd:            2D-array (numpy) with local drain direction values 
                        (default is the PCRaster directions)
        dem_fill:       fill value of missing data in dem
        ldd_fill:       fill value of missing data in ldd
        pit:            value of outflow elevation at pit (e.g. at ocean or 
                        interior basin)
        weight_fill:    weight given to filling of upstream elevation
        weight_dig:     weight given to digging of downstream elevation
        z_int:          stepwise interval of modification to elevation
        flow_dirs:      2D-array (3x3 numpy) of the flow directions used in ldd
                        default is the PCRaster directions 
                        [[7, 8, 9], [4, 5, 6], [1, 2, 3]]
    outputs:
        dem_mod:        2D-array (numpy) with modified elevation

    """
    # first find all cells that lie on a catchment boundary. These are cells 
    # that do not have any upstream cells and are not pit cells (isolated)
    idx, catch_bound = catch_boundary(ldd, 5, ldd_fill, flow_dirs=flow_dirs)
    # TODO: check if 4 commented lines below are still necessary after changing to Strahler order
    # streams, upstream_points = stream_length(ldd, idx, 5)
    # # sort the list of upstream point lengths
    # lengths_sorted = pd.DataFrame(upstream_points).sort(columns=['lengths'],
    #                                                     ascending=False)

    # correct the DEM according to the sorted lengths, starting with the longest
    dem_mod = None

    # initiate strahler order map
    strahler = None
    cur_strahler = 1
    while len(idx[0] > 1):
        # prepare empty lists for confluence points of next strahler order
        print('Preparing strahler order {:d} with {:d} start points'.format(cur_strahler, len(idx[0])))
        next_idx_x = []
        next_idx_y = []
        for n, (init_cell_y, init_cell_x) in enumerate(zip(*idx)):  # enumerate(lengths_sorted['coordinates']):
            # print('treating stream {:d} of {:d}').format(n + 1, len(lengths_sorted['coordinates']))
            idx_list,\
            dem_mod,\
            strahler,\
            next_strahler_init_cell_y,\
            next_strahler_init_cell_x = fill_dig_streamline(dem, ldd, init_cell_y,
                                init_cell_x, dem_fill=dem_fill,
                                ldd_fill=ldd_fill, pit=5, weight_fill=10.,
                                weight_dig=1., z_int_start=0.05,
                                dem_mod=dem_mod, strahler=strahler, cur_strahler=cur_strahler)
            # collect the next strahler order (if any) [added '>= 0' because it would otherwise only work for values larger than 1]
            if next_strahler_init_cell_y >= 0:
                next_idx_y.append(next_strahler_init_cell_y)
                next_idx_x.append(next_strahler_init_cell_x)
        idx = (np.array(next_idx_y), np.array(next_idx_x))
        cur_strahler += 1
    print('Filling missing data')
    dem_mod[np.isnan(dem_mod)] = dem_fill
    #gdal_writemap(r'd:\svn\openearthtools\python\applications\hydrotools\hydrotools\gis\dem_mod.map', 'PCRaster', x, y, dem_mod, dem_fill)
    return dem_mod, strahler

