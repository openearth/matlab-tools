# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Gerrit Hendriksen, Joan Sala
#
#       gerrit.hendriksen@deltares.nl, joan.salacalero@deltares.nl
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

# $Id: nhimodel_run.py 15858 2019-10-22 15:18:09Z pronk_mn $
# $Date: 2019-10-22 08:18:09 -0700 (Tue, 22 Oct 2019) $
# $Author: pronk_mn $
# $Revision: 15858 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/nhidataportaal/processes/nhimodel_run.py $
# $Keywords: $

# core
import os
import logging
import subprocess
import tempfile

# Local
from coords import *
import raster_func as ra

"""
NHI online modelling input/output functions
- create ouputs
- connect to GeoServer
"""


class nhimodel_RUN():

    def __init__(self, c, tr, ti):
        self.config = c
        self.TEMPLATE_RUN = tr
        self.TEMPLATE_IPF = ti

    # Run model via Process
    def runModel(self, runfile, tmpdir):
        args = [os.path.join(self.config['EXE_LOCATION'],
                             self.config['EXE_NAME']), runfile]

        # Run model
        logging.info('''EXEC [cmd]: {}'''.format(args))
        pro = subprocess.Popen(args,
                               bufsize=0,
                               universal_newlines=True,
                               cwd=tmpdir,
                               stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT)
        lines = []
        while pro.poll() is None:
            line = pro.stdout.readline()
            if 'Elapsed run time:' in line or 'Run end date and time' in line:
                lines.append(line)

        # Write stats to wps log
        logging.info(lines)

    # Temporary dir setup
    def getTempDir(self):
        # Temporary folder setup
        tmpdir = tempfile.mkdtemp()
        return tmpdir

    # Prepare model files
    def setupModelRUN(self, tmpdir, ipffile, layernb, x, y, meters_margin, epsgout='epsg:3857'):
        # Read template
        logging.info('''READING [template]: {}'''.format(self.TEMPLATE_RUN))
        with open(self.TEMPLATE_RUN, 'r') as myfile:
            data = myfile.read()

        # Override configuration (point + margin)
        bbox_rdnew = [x-meters_margin, y-meters_margin,
                      x+meters_margin, y+meters_margin]
        (x0, y0) = change_coords(
            bbox_rdnew[0], bbox_rdnew[1], epsgin='epsg:28992', epsgout=epsgout)
        (x1, y1) = change_coords(
            bbox_rdnew[2], bbox_rdnew[3], epsgin='epsg:28992', epsgout=epsgout)
        bbox = [x0, y0, x1, y1]
        data = data.format(absfileIPF=ipffile, outfolder=tmpdir, x0=str(bbox_rdnew[0]), y0=str(
            bbox_rdnew[1]), x1=str(bbox_rdnew[2]), y1=str(bbox_rdnew[3]), layernb=layernb)

        # Write run file
        runfile = os.path.join(tmpdir, 'imod.run')
        logging.info('''WRITING [runfile]: {}'''.format(runfile))
        with open(runfile, "w") as runf:
            runf.write("%s" % data)
        return runfile, bbox_rdnew, bbox

    # Define extraction file
    def setupAbstractionIPF(self, tmpdir, x, y, absvolume):
        # Read template
        logging.info('''READING [template]: {}'''.format(self.TEMPLATE_IPF))
        with open(self.TEMPLATE_IPF, 'r') as myfile:
            data = myfile.read()
        # Override configuration (point + margin)
        data = data.format(xa=x, ya=y, absvol=absvolume)
        # Write run file
        ipffile = os.path.join(tmpdir, 'abstraction.ipf')
        logging.info('''WRITING [ipffile]: {}'''.format(ipffile))
        with open(ipffile, "w") as runf:
            runf.write("%s" % data)

        return ipffile

    # Convert to GeoTiff
    def produceOutput(self, tmpdir, layernb):
        # Starting head (depends on the layer number)
        start_head_path = os.path.join(
            self.config['HEADS_DIR'], '''head_steady-state_l{}.idf''').format(str(layernb))
        #start_head_path = os.path.join(self.config['HEADS_DIR'], '''head_l{}.idf''').format(str(layernb))
        head1 = ra.raster2arr(start_head_path)
        logging.info('''OUTPUT [nhimodel]: start_head={}, layernb={}'''.format(
            start_head_path, str(layernb)))

        # New calculated head (depends on the layer number)
        calc_head = os.path.join(
            tmpdir+'/head', '''head_steady-state_l{}.idf'''.format(layernb))  # Selected head
        logging.info('''OUTPUT [nhimodel]: calculated_head={}, layernb={}'''.format(
            calc_head, str(layernb)))
        head2 = ra.raster2arr(calc_head)

        # Difference
        head_diff = head2 - head1

        # Output to GeoTiff
        outgtiff = os.path.join(tmpdir, 'head_diff.tif')
        # raster_format 6 is geotiff format, see documentation
        head_diff.write(outgtiff, raster_format=6)
        return outgtiff
