# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
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
# $Keywords: $

import subprocess
import os

class CMEMSDownload:
    def __init__(self, bbox_in, t0, t1, depth0, depth1, variable, output_dir, output_netcdf, user, pwd, motuserver, service, dataset):
        # Variable params
        self.bbox = bbox_in
        self.variable = variable
        self.depth0 = depth0
        self.depth1 = depth1
        self.t0 = t0
        self.t1 = t1

        ## EXE_SCRIPT
        self.exe_script = os.path.join(os.path.dirname(os.path.realpath(__file__)), './motu-client.py')

        ## AUTH [hardcoded for test]
        self.user = user
        self.pwd = pwd

        ## OUTPUTS
        self.output_dir = output_dir
        self.output_netcdf = output_netcdf

        ## DATASET SELECTION
        self.motuserver = motuserver
        self.service = service
        self.dataset = dataset

    def download(self):
        cmd_format = '{pypath} {script} -u {un} -p {ps} -m {motuUrl} -s {serv} -d {dat} -x {x0} -X {x1} -y {y0} -Y {y1} -t "{t0}" -T "{t1}" -z {z0} -Z {z1} -v {var} -o {odir} -f {outf}'
        cmd_string = cmd_format.format(pypath='python.exe', script=self.exe_script, un=self.user, ps=self.pwd, \
                                       motuUrl=self.motuserver, serv=self.service, dat=self.dataset, \
                                       x0=self.bbox[0], x1=self.bbox[2], y0=self.bbox[1], y1=self.bbox[3], \
                                       t0=self.t0, t1=self.t1, \
                                       z0=self.depth0, z1=self.depth1, \
                                       var=self.variable, \
                                       odir=self.output_dir, outf=self.output_netcdf)

        print subprocess.check_output(cmd_string)

## ======== TEST ========
def test():
    ## FILTERS
    bbox_in = (2.097, 52.715, 4.277, 53.935)
    t0 = "2017-11-06 23:00:00"
    t1 = "2017-11-12 23:00:00" # the week before the workshop
    depth0 = 0.0
    depth1 = 100.0
    variable = 'vosaline'
    ## OUTPUTS
    output_dir='../tmp_data'
    output_netcdf='salinity_cmems.nc'
    ## AUTH
    user = 'adminweb'
    passw = 'adminweb'
    ## DATASET SELECTION
    motuserver = 'http://data.ncof.co.uk/motu-web/Motu'
    service = 'NORTHWESTSHELF_ANALYSIS_FORECAST_PHYS_004_001_b'
    dataset = 'MetO-NWS-PHYS-hi-SAL'

    ## Perform download
    cmems = CMEMSDownload(bbox_in, t0, t1, depth0, depth1, variable, output_dir, output_netcdf, user, passw, motuserver, service, dataset)
    cmems.download()

## ======== MAIN ======== [ Class test ]
if __name__ == "__main__":
    print 'CopernicusMarine loaded'
    #test()