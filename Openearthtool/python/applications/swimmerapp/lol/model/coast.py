#!/usr/bin/env python
# this model represents a piece of a coast, modelled by a xbeach model.

import pydap.client
import netCDF4
from enthought.tvtk.api import tvtk
import numpy as np

reasons = {1: 'OUT_OF_DOMAIN',
           2: 'NOT_INITIALIZED',
           3: 'UNEXPECTED_VALUE',
           4: 'OUT_OF_LENGTH',
           5: 'OUT_OF_STEPS',
           6: 'STAGNATION'}

units = {0: 'TIME_UNIT',
         1: 'LENGTH_UNIT',
         2: 'CELL_LENGTH_UNIT'}

class Coast(object):
    def __init__(self, url='http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/MICORE/public_html/egmond/scenarios/today/europe/egmond/netcdf/egm.20101010_00z.xb.nc'):
        self.dataset = netCDF4.Dataset(url)
        self._st = None
    def grid(self):
        x = self.dataset.variables['x'][:]
        y = self.dataset.variables['y'][:]
        z = np.array([0.0])
        grid = tvtk.RectilinearGrid(dimensions=np.array([x.size, y.size, z.size]))
        grid.x_coordinates = x
        grid.y_coordinates = y
        grid.z_coordinates = z
        return grid
    def coastline(self, t=0):
        grid = self.grid()
        z = self.dataset.variables['zb'][t,:,:].ravel()
        grid.point_data.scalars = z
        # use a contour filter to look up the coastline
        contour = tvtk.ContourFilter()
        # use a stripper to generate lines
        stripper = tvtk.Stripper()

        # create a contour at level 0
        contour.set_value(0, 0.0)
        contour.input = grid
        contour.update()
        stripper.input = contour.output
        stripper.update()

        # extract linestrings
        start = 0
        linelist = []
        for i in range(stripper.output.lines.number_of_cells):
            """loop over all lines"""
            lines = np.asarray(stripper.output.lines.data, dtype="int")
            points = np.asarray(stripper.output.points)
            n = lines[start]
            idx = lines[start+1:start+n]
            line = points[idx]
            linelist.append(line)
            start += (n + 1)
        # TODO make sure we use the proper coordinates
        return {'contours':linelist}
    def trace(self, t=0, start=np.asarray([[100.0,100.0,0.0]])):
        grid = self.grid()
        # cache the old tracer ...
        if self._st is None:
            self._st = tvtk.StreamTracer()
            
        st = self._st
        pd = tvtk.PolyData()
        # setup the tracer
        st.integrator_type = 'runge_kutta45'
        st.integration_step_unit = 1 # integrate in arc length (meters)...
        st.maximum_propagation = 3000 # maximum of 20 meter
        # st.maximum_integration_step = 0.1 # maximum of 10cm.
        st.minimum_integration_step = 5 # (at least 5 cm)
        st.maximum_integration_step = 100.0 # (maximum of 1 meter)
        # start from start positions
        pd.points = start

        # set the pipelne
        st.input = grid
        st.source = pd

        # download velocity field vectors
        ut = self.dataset.variables['ue'][t,:,:].ravel()
        vt = self.dataset.variables['ve'][t,:,:].ravel()
        wt = np.zeros(ut.shape)

        # set the grid points
        grid.point_data.vectors = np.c_[ut,vt,wt]
        
        # update the field lines
        st.update()

        # do we have any data?
        result = {}
        result['n_streamlines'] = st.output.number_of_cells

        # sometimes we don't get streamlines
        # for example if the velocity is zero
        # or if a point is put outside the domain.
        if result['n_streamlines']:
            assert st.output.cell_data.number_of_arrays == 1
            assert st.output.cell_data.get_array_name(0) == 'ReasonForTermination'
            result['reason_for_termination'] = [reasons[code]
                                                for code
                                                in st.output.cell_data.get_array(0)]

            # extract linestrings
            start = 0
            linelist = []
            for i in range(st.output.lines.number_of_cells):
                """loop over all lines"""
                lines = np.asarray(st.output.lines.data, dtype="int")
                points = np.asarray(st.output.points)
                n = lines[start]
                idx = lines[start+1:start+n]
                line = points[idx]
                linelist.append(line)
                start += (n + 1)
            result['streamlines'] = linelist

            result['arrays'] = {}
            for i in range(st.output.point_data.number_of_arrays):
                array = np.asarray(st.output.point_data.get_array(i))
                arrayname = st.output.point_data.get_array_name(i) or 'Unknown'
                result['arrays'][arrayname] = array
        return result 
