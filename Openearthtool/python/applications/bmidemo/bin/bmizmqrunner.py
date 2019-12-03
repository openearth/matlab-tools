#!/usr/bin/env python
import os
import os.path
import time
import threading
import functools
import numbers
import random
import platform
import itertools

import numpy as np
import zmq
import ujson

import openearthtools.modelapi.bmi
from openearthtools.plot.streamtracer import flow2grid, cell2point, maketracer, stream2lines
from openearthtools.io.dflowfm import UGrid


example = 1

# Locate the libdflow dll
if platform.system() == 'Darwin':
    LIBFMNAME = '/Users/fedorbaart/Documents/checkouts/dflowfm_esmf/src/.libs/libdflowfm.dylib'
    # This is a simulation of a river bend.
    run = '/Users/fedorbaart/Documents/checkouts/cases_unstruc/e00_unstruc/f04_bottomfriction/c016_2DConveyance_bend/input/bendprof.mdu'
    if example > 1:
        run = '/Users/fedorbaart/Documents/checkouts/cases_unstruc/e00_unstruc/f03_advection/c020_Waalgrof/input/waalgrof.mdu'
elif platform.system() == 'Windows':
    import ctypes
    # Also load netcdf dll...
    ctypes.cdll.LoadLibrary(r'd:\checkouts\dflowfm_esmf\bin\Debug\netcdf.dll')
    LIBFMNAME = r'd:\checkouts\dflowfm_esmf\bin\Debug\unstruc.dll'
    run = r'd:\checkouts\cases_unstruc\e00_unstruc\f04_bottomfriction\c016_2DConveyance_bend\input\bendprof.mdu'
    if example > 1:
        run = r'd:\checkouts\cases_unstruc\e00_unstruc\f03_advection\c020_Waalgrof\input\waalgrof.mdu'

rundir, configuration_file = os.path.split(run)

dt = 1.0
if example > 1:
    dt = 5.0

def runner(fm, send):
    """run the model indefinitely"""
    while True:
        fm.update(dt)
        send(fm, vars=['s1'])
        send(fm, vars=['lines'])
        time.sleep(0.1)

def sender(fm, vars, pubsock):
    """send the variables to the publication socket"""
    tag = "get"
    data = {}
    if 's1' in vars:
        s1 = fm.get_1d_double('s1')
        data['s1'] = list(s1)
        tag = 's1'
    if 'lines' in vars:
        ucx = fm.get_1d_double('ucx').copy()
        ucy = fm.get_1d_double('ucy').copy()
        # send over a double 2d message.
        # space separation by convention.
        # Convert to html5 arraybuffer format (just bytes)....
        vectors = (np.c_[ucx,ucy, np.zeros(ucx.shape)])
        grid.cell_data.scalars = np.sqrt(np.sum(vectors**2,1))
        grid.cell_data.vectors = vectors
        # compute new streamlines
        grid.update()
        st.update()
        lines = stream2lines(st)
        data['lines'] = lines
        tag = 'lines'
    jsondata = "".join(ujson.dumps(data, double_precision=4).split())
    message = zmq.Message("{} {}".format(tag, jsondata))
    pubsock.send(message)

def receiver(fm, rcvsock):
    """transform a set message"""
    while True:
        message = rcvsock.recv()
        tag, jsondata = message.split(None,1)
        if tag == 'set':
            data = ujson.loads(jsondata)
            for key in data:
                fm.set_1d_double_at_index(key, int(data[key]), 20.0)
        elif tag == 'grid':
            # Someone needs a grid, better send it.
            xk = fm.get_1d_double('xk').copy()
            yk = fm.get_1d_double('yk').copy()
            if configuration_file == 'waalgrof.mdu':
                xk += 126331.705002
                yk += 422959.946403
            netelemnode = fm.get_2d_int('netelemnode')
            netelemnode = np.ma.masked_array(netelemnode, mask=netelemnode<0)
            # We have enough data..., don't bother with the z...
            grid = UGrid(xk, yk, netelemnode=netelemnode)
            jsondata = grid.export(epsg=28992 if configuration_file == 'waalgrof.mdu' else None)
            message = zmq.Message("{} {}".format(tag, ''.join(jsondata.split())))
            pubsock.send(message)
        else:
            print 'uuuh', tag


if __name__ == '__main__':
    # Wrap the dflow_fm library with the python BMI api (taking into account fortran memory order)
    fm = openearthtools.modelapi.bmi.BMIFortran(libname=LIBFMNAME, rundir=rundir)
    # Initialize the model with the input file

    fm.initialize(configuration_file)

    # Build grid and stream tracer
    # Get topology
    xk = fm.get_1d_double('xk').copy()
    yk = fm.get_1d_double('yk').copy()


    if configuration_file == 'waalgrof.mdu':
        xk += 126331.705002
        yk += 422959.946403

    flowelemnode = fm.get_2d_int('flowelemnode')

    grid  = flow2grid(xk, yk, flowelemnode-1)
    # And grid with cell2points filter
    cell2point_grid = cell2point(grid)
    # Make a streamtracer
    st = maketracer(cell2point_grid)
    # st.maximum_propagation = 50.0
    # st.minimum_integration_step = 0.1
    # st.maximum_integration_step = 1.0
    # st.maximum_error = 0.1

    # This is the way to get cell centers (replace by user points)
    points = grid.points.to_array()
    cells = grid.get_cells()
    cellidx = grid.cell_locations_array.to_array()[1:]
    cellcoords = [points[x[1:]] for x in np.split(cells.to_array(), cellidx)]
    cx, cy, cz = np.array([x.mean(0) for x in cellcoords]).T
    points = np.c_[cx,cy,cz]

    points = np.array(random.sample(points, 100))
    points[:2,:] += (np.random.random(points[:2,:].shape) *10 -5)
    st.source.points = points


    # We're gonna publish model results every 0.01 seconds
    context = zmq.Context()
    pubsock = context.socket(zmq.PUB)
    pubsock.bind("tcp://*:5556")

    # Socket to receive messages on (new water levels)
    rcvsock = context.socket(zmq.PULL)
    rcvsock.connect("tcp://127.0.0.1:5557")

    send = functools.partial(sender, pubsock=pubsock)
    receive = functools.partial(receiver, rcvsock=rcvsock)

    # Pass callback send to runner
    runthread = threading.Thread(target=runner, args=(fm, send))
    rcvthread = threading.Thread(target=receive, args=(fm, ))
    # Set daemon threads so they can exit...
    runthread.setDaemon(True)
    rcvthread.setDaemon(True)
    runthread.start()
    rcvthread.start()

    # Just keep on doing nothing, while background threads do all thw work....
    while True:
        time.sleep(0.1)
