# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#
#   Adopted from https://gitlab.com/deltares/imod/imod-python/tree/master/imod
#
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.


import re
from collections import OrderedDict
from datetime import datetime
from pathlib import Path
import pandas as pd
from struct import pack, unpack

import cftime
import numpy as np


def decompose(path):
    """Parse a path, returning a dict of the parts,
    following the iMOD conventions"""
    if isinstance(path, str):
        path = Path(path)

    parts = path.stem.split("_")
    name = parts[0]
    assert name != "", ValueError("Name cannot be empty")
    d = OrderedDict()
    d["extension"] = path.suffix
    d["directory"] = path.parent
    d["name"] = name

    # Try to get time from idf name, iMODFLOW can output two datetime formats
    for s in parts:
        try:
            dt = datetime.strptime(s, "%Y%m%d%H%M%S")
            d["time"] = cftime.DatetimeProlepticGregorian(*dt.timetuple()[:6])
            break
        except ValueError:
            try:
                dt = datetime.strptime(s, "%Y%m%d")
                d["time"] = cftime.DatetimeProlepticGregorian(
                    *dt.timetuple()[:6])
                break
            except ValueError:
                pass  # no time in dict

    # layer is always last
    p = re.compile(r"^l\d+$", re.IGNORECASE)
    if p.match(parts[-1]):
        d["layer"] = int(parts[-1][1:])
    return d


def compose(d):
    """From a dict of parts, construct a filename,
    following the iMOD conventions"""
    haslayer = "layer" in d
    hastime = "time" in d
    if hastime:
        d["timestr"] = d["time"].strftime("%Y%m%d%H%M%S")
    if haslayer:
        d["layer"] = int(d["layer"])
        if hastime:
            s = "{name}_{timestr}_l{layer}{extension}".format(**d)
        else:
            s = "{name}_l{layer}{extension}".format(**d)
    else:
        if hastime:
            s = "{name}_{timestr}{extension}".format(**d)
        else:
            s = "{name}{extension}".format(**d)
    if "directory" in d:
        return d["directory"].joinpath(s)
    else:
        return s


def _top_bot_dicts(a):
    """Returns a dictionary with the top and bottom per layer"""
    top = np.atleast_1d(a.attrs["top"]).astype(np.float64)
    bot = np.atleast_1d(a.attrs["bot"]).astype(np.float64)
    assert top.shape == bot.shape, '"top" and "bot" attrs should have the same shape'
    if "layer" in a.coords:
        layers = np.atleast_1d(a.coords["layer"].values)
        assert top.shape == layers.shape
        d_top = {laynum: t for laynum, t in zip(layers, top)}
        d_bot = {laynum: b for laynum, b in zip(layers, bot)}
    else:
        assert top.shape == (1,), (
            'if "layer" is not a coordinate, "top"'
            ' and "bot" attrs should hold only one value'
        )
        d_top = {"no_layer": top[0]}
        d_bot = {"no_layer": bot[0]}
    return d_top, d_bot


def _extra_dims(a):
    dims = [dim for dim in a.dims if dim not in ("y", "x")]
    return list(dims)


def _delta(x, coordname):
    dxs = np.diff(x)
    dx = dxs[0]
    atolx = abs(1.0e-6 * dx)
    if not np.allclose(dxs, dx, atolx):
        raise ValueError(
            "DataArray has to be equidistant along {}.".format(coordname))
    return dx


def spatial_reference(a):
    """
    Extracts spatial reference from DataArray.

    If the DataArray coordinates are nonequidistant, dx and dy will be returned
    as 1D ndarray instead of float.

    Parameters
    ----------
    a : xarray.DataArray

    Returns
    --------------
    tuple
        (dx, xmin, xmax, dy, ymin, ymax)

    """
    x = a.x.values
    y = a.y.values
    ncol = x.size
    nrow = y.size

    # Possibly non-equidistant
    if ("dx" in a.coords) and ("dy" in a.coords):
        dx = a.coords["dx"]
        dy = a.coords["dy"]
        if (dx.shape == x.shape) and (dx.size != 1):
            dx = dx.values
            xmin = float(x.min()) - 0.5 * abs(dx[0])
            xmax = float(x.max()) + 0.5 * abs(dx[-1])
        else:
            dx = float(dx)
            xmin = float(x.min()) - 0.5 * abs(dx)
            xmax = float(x.max()) + 0.5 * abs(dx)
        if (dy.shape == y.shape) and (dy.size != 1):
            dy = dy.values
            ymin = float(y.min()) - 0.5 * abs(dy[-1])
            ymax = float(y.max()) + 0.5 * abs(dy[0])
        else:
            dy = float(dy)
            ymin = float(y.min()) - 0.5 * abs(dy)
            ymax = float(y.max()) + 0.5 * abs(dy)
    else:  # Equidistant
        # TODO: decide on decent criterium for what equidistant means
        # make use of floating point epsilon? E.g:
        # https://github.com/ioam/holoviews/issues/1869#issuecomment-353115449
        # TODO: this is basically a work-around for iMODFLOW allowing only
        # square gridcells, ideally 1D IDF have a width of 1.0 (?)
        if ncol == 1:
            dx = dy = _delta(y, "y")
        elif nrow == 1:
            dy = dx = _delta(x, "x")
        else:
            dx = _delta(x, "x")
            dy = _delta(y, "y")

        # as xarray used midpoint coordinates
        xmin = float(x.min()) - 0.5 * abs(dx)
        xmax = float(x.max()) + 0.5 * abs(dx)
        ymin = float(y.min()) - 0.5 * abs(dy)
        ymax = float(y.max()) + 0.5 * abs(dy)

    return dx, xmin, xmax, dy, ymin, ymax


def write(path, a, nodata=1.0e20):
    """
    Write a 2D xarray.DataArray to a IDF file

    Parameters
    ----------
    path : str or Path
        Path to the IDF file to be written
    a : xarray.DataArray
        DataArray to be written. It needs to have exactly a.dims == ('y', 'x').
    """
    assert a.dims == ("y", "x")
    with open(path, "wb") as f:
        f.write(pack("i", 1271))  # Lahey RecordLength Ident.
        nrow = a.y.size
        ncol = a.x.size
        attrs = a.attrs
        itb = isinstance(attrs.get("top", None), (int, float)) and isinstance(
            attrs.get("bot", None), (int, float)
        )
        f.write(pack("i", ncol))
        f.write(pack("i", nrow))
        dx, xmin, xmax, dy, ymin, ymax = spatial_reference(a)
        # IDF supports only incrementing x, and decrementing y
        if (np.atleast_1d(dx) < 0.0).all():
            raise ValueError("dx must be positive")
        if (np.atleast_1d(dy) > 0.0).all():
            raise ValueError("dy must be negative")

        f.write(pack("f", xmin))
        f.write(pack("f", xmax))
        f.write(pack("f", ymin))
        f.write(pack("f", ymax))
        f.write(pack("f", float(a.min())))  # dmin
        f.write(pack("f", float(a.max())))  # dmax
        f.write(pack("f", nodata))

        if isinstance(dx, float) and isinstance(dy, float):
            ieq = True  # equidistant
            f.write(pack("?", not ieq))  # ieq
        else:
            ieq = False  # nonequidistant
            f.write(pack("?", not ieq))  # ieq

        f.write(pack("?", itb))
        f.write(pack("xx"))  # not used
        if ieq:
            f.write(pack("f", dx))
            f.write(pack("f", -dy))
        if itb:
            f.write(pack("f", attrs["top"]))
            f.write(pack("f", attrs["bot"]))
        if not ieq:
            a.coords["dx"].values.astype(np.float32).tofile(f)
            (-a.coords["dy"].values).astype(np.float32).tofile(f)
        # convert to a numpy.ndarray of float32
        if a.dtype != np.float32:
            a = a.astype(np.float32)
        a = a.fillna(nodata)
        a.values.tofile(f)


def save(path, a, nodata=1.0e20):
    """
    Write a xarray.DataArray to one or more IDF files

    If the DataArray only has `y` and `x` dimensions, a single IDF file is
    written, like the `imod.idf.write` function. This function is more general
    and also supports `time` and `layer` dimensions. It will split these up,
    give them their own filename according to the conventions in
    `imod.util.compose`, and write them each

    Parameters
    ----------
    path : str or Path
        Path to the IDF file to be written. This function decides on the
        actual filename(s) using conventions, so it only takes the directory and
        name from this parameter.
    a : xarray.DataArray
        DataArray to be written. It needs to have exactly a.dims == ('y', 'x').

    Example
    -------
    Consider a DataArray `da` that has dimensions 'layer', 'y' and 'x', with the
    'layer' dimension consisting of layer 1 and 2::

        save('path/to/head', da)

    This writes the following two IDF files: 'path/to/head_l1.idf' and
    'path/to/head_l2.idf'.
    """
    d = decompose(path)
    d["extension"] = ".idf"
    d["directory"].mkdir(exist_ok=True, parents=True)

    # handle the case where they are not a dim but are a coord
    # i.e. you only have one layer but you did a.assign_coords(layer=1)
    # in this case we do want _l1 in the IDF file name
    check_coords = ["layer", "time"]
    for coord in check_coords:
        if (coord in a.coords) and not (coord in a.dims):
            if coord == "time":
                # .item() gives an integer, we need a pd.Timestamp or datetime.datetime
                dt64 = a.coords[coord].values
                val = pd.Timestamp(dt64)
            else:
                val = a.coords[coord].item()
            d[coord] = val

    # Allow tops and bottoms to be written for voxel like IDFs.
    has_topbot = False
    if "top" in a.attrs and "bot" in a.attrs:
        has_topbot = True
        d_top, d_bot = _top_bot_dicts(a)

    # stack all non idf dims into one new idf dimension,
    # over which we can then iterate to write all individual idfs
    extradims = _extra_dims(a)
    if extradims:
        stacked = a.stack(idf=extradims)
        for coordvals, a_yx in list(stacked.groupby("idf")):
            # set the right layer/timestep/etc in the dict to make the filename
            d.update(dict(list(zip(extradims, coordvals))))
            fn = compose(d)
            if has_topbot:
                layer = d.get("layer", "no_layer")
                a_yx.attrs["top"] = d_top[layer]
                a_yx.attrs["bot"] = d_bot[layer]
            write(fn, a_yx)
    else:
        # no extra dims, only one IDF
        fn = compose(d)
        write(fn, a)
