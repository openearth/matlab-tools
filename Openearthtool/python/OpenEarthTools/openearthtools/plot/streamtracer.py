from tvtk.api import tvtk
import numpy as np

import sys
# We're going to recurse a bit....
sys.setrecursionlimit(10000)

# Supported cell types
CELLTYPES = {
    2: tvtk.Line().cell_type,
    3: tvtk.Triangle().cell_type,
    4: tvtk.Quad().cell_type,
    5: tvtk.Polygon().cell_type,
    6: tvtk.Polygon().cell_type
}

def flow2grid(xk, yk, elemnode):
    """
    Convert x,y coordinates + adminstration to a vtk unstructured grid.
    xk, yk are the node coordinates
    elemnode is the element node administration (0 based)
    """
    nodex = xk
    nodey = yk

    # convert to vtk adminstration
    cellarraylist = []
    celltypes = []
    offsets = []
    for cell in (elemnode):
        connectivity = cell[cell>=0]
        ncellnodes = (cell >= 0).sum()
        cellx = nodex[connectivity]
        celly = nodey[connectivity]
        cell = np.c_[cellx, celly, np.zeros((ncellnodes,))]
        celltypes.append(CELLTYPES[ncellnodes])
        offsets.append(len(cellarraylist))
        cellarraylist.extend([ncellnodes] + list(connectivity))
    offsets = np.array(offsets)
    celltypes= np.array(celltypes)
    ncells = celltypes.shape[0]

    # buildup the vtk types
    cellarray = tvtk.CellArray()
    cellarray.set_cells(ncells, np.array(cellarraylist))
    grid = tvtk.UnstructuredGrid(points=np.c_[nodex,nodey, np.zeros(nodex.shape)])
    grid.set_cells(celltypes, offsets, cellarray)

    return grid

def cell2point(grid):
    # Transform cell to point data
    cell2pointgrid = tvtk.CellDataToPointData()
    cell2pointgrid.input = grid
    cell2pointgrid.update()
    return cell2pointgrid.output


def maketracer(grid):
    # Create a stream tracer
    st = tvtk.StreamTracer()
    # Set a tracer in each cell
    pd = tvtk.PolyData()

    # Set the points in the streamer
    st.source = pd
    # Connect the grid
    st.input = grid

    # Set some options
    # Lookup a nice cell size
    cells = grid.get_cells().to_array()
    points = grid.points.to_array()


    # Recursively walk through cells
    def eatcells(cells, points):
        if cells.shape[0] > 0:
            n = cells[0]
            yield points[cells[1:(n+1)]]
            for cell in eatcells(cells[(n+1):], points):
                yield cell
    cellsizes = np.array([np.abs(x.max(0) - x.min(0)) for x  in eatcells(cells, points)])
    cellsize = np.max(np.mean(cellsizes,0))
    st.maximum_propagation = cellsize*2.5
    st.integration_step_unit = 1
    st.minimum_integration_step = cellsize/200.0
    st.maximum_integration_step = cellsize/20.0
    st.maximum_number_of_steps = 200
    st.maximum_error = cellsize/200.0
    st.integrator_type = 'runge_kutta45'

    return st


def stream2lines(st):
    """get the lines from the streamtracer"""
    start = 0
    linelist = []
    lines = st.output.lines.data.to_array()
    points = st.output.points.to_array()
    for i in range(st.output.lines.number_of_cells):
        """loop over all lines"""
        n = lines[start]
        idx = lines[start+1:start+n]
        line = points[idx]
        linelist.append(line.tolist())
        start += (n + 1)
    return linelist
