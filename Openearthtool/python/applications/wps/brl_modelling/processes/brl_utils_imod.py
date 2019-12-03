# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2019 Deltares
#       Gerrit Hendriksen
#       gerrit.hendriksen@deltares.nl
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

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/brl_modelling/processes/brl_utils_geoserver.py $
# $Keywords: $

# system pacakages
import os
import json
import subprocess
import tempfile
from shutil import copyfile
import string
from random import choice, randint

# conda packages
import rasterio
import xarray

# third party
import imod

# local scripts
from processes.brl_utils_vector import createmodelextent
#from processes.brl_utils_geoserver import geoserver_upload_gtif
from processes.brl_utils_geoserver import geoserverUploadGTIFF

def createrandstring():
    allchar = string.ascii_letters
    randstr = "".join(choice(allchar) for x in range(randint(8, 14)))
    return randstr

def mkTempDir(tmpdir):
    # Temporary folder setup, because of permission issues this alternative has been created
    #modeldir=tempfile.mkdtemp()
    foldername = createrandstring().lower()
    modeltmpdir = os.path.join(tmpdir,foldername)
    os.makedirs(modeltmpdir)
    return modeltmpdir

def setupModelRUN(modeltmpdir, modelextent, template_run,factor):
    # Read template
    with open(template_run, 'r') as myfile:
        data=myfile.read()

    # Override configuration (point + margin)    
    #data = data.format(outputfolder=modeltmpdir,     
    data = data.format(x0=str(modelextent[0][0]), 
                       y0=str(modelextent[0][1]), 
                       x1=str(modelextent[1][0]), 
                       y1=str(modelextent[1][1]),
                       f=str(factor))

    # Write run file
    runfile = os.path.join(modeltmpdir, 'imod.run')
    print('runfile: ',runfile)
    with open(runfile, "w") as runf:
        runf.write("%s" % data)
    return runfile

def runModel(exe,runfile):
    currentdir = os.getcwd()
    args = ['chmod','+x',exe]
    subprocess.run(args)
    args = ['./'+os.path.basename(exe),os.path.basename(runfile)]
    print('args: ',args)
    os.chdir(os.path.dirname(exe))
    process = subprocess.run(args, shell=False, check=True)
    print("done:", process.returncode, process.stdout, process.stderr)
    os.chdir(currentdir)

def handleoutput(sc0dir, modeltmpdir,vislayer,watersId):
    # from the tmpdir --> get head for layer of visualisation
    # create a difference raster based on the extent of the scenario vislayer
    sc1 = imod.idf.open(os.path.join(modeltmpdir,'head/head_steady-state_l{}.idf'.format(vislayer)))
    sc0 = imod.idf.open(os.path.join(sc0dir,'head/head_steady-state_l{}.idf'.format(vislayer)))
    
    result = sc0-sc1
    resultgtif = os.path.join(modeltmpdir,''.join(['difhead_',watersId,'.tif']))
    print('resultgtif: ',resultgtif)
    r = result.squeeze('time').squeeze('layer')
    r.attrs["crs"] = "epsg:28992"
    imod.rasterio.write(resultgtif,r,driver='GTIFF')
    return resultgtif
    
def setupgwmodelandrun(cf, watersId,extent,factor,vislayer,calclayer):
    #extent = 5000
    #factor = 4
    # r"C:\Users\hendrik_gt\AppData\Local\Temp\waters_1573655087489443_extent_rd.geojson"
    # in the tmpdir (is the os tempdir) temp files are stored. Based on the watersId a couple of files are stored
    #tmpdir = gettmpdir()
    tmpdir = cf.get('wps', 'tmp')
    print('tmpdir: ',tmpdir)

    fnext = os.path.join(tmpdir,''.join([watersId,'_extent_rd.geojson']))
    print('fnext: ',fnext)
    with open(fnext) as f:
        data = json.load(f)
    bbox_rd = data['coordinates'][0]
    modelextent = createmodelextent(bbox_rd,extent)
    print('modelextent: ',modelextent)
    
    # get the directory from the config file where the template is stored
    modeldir = cf.get('Model', 'modeldir')
    print('modeldir: ',modeldir)
    if os.name == 'nt':
        template_run = os.path.join(modeldir,"nhi_template_nt.run")
    else:
        template_run = os.path.join(modeldir,"nhi_template.run")
    # modeldir = r'D:\projecten\datamanagement\rws\BasisRivierbodemLigging\wps_brl_modelling\model'
    
    # make new temp dir where runfile and modeloutput is stored
    modeltmpdir = mkTempDir(tmpdir)
    print('modeltmpdir: ',modeltmpdir)
    #modeltmpdir = r'C:\Users\hendrik_gt\AppData\Local\Temp\tmp4p112xlp'
    # to make sure imodflow creates output in the target dir, copy de exe and ibound_l1.idf to the modeltmpdir.
    lstfiles = [cf.get('Model','exe'),'ibound_l1.idf','I_accepted_v4_2.txt']
    sp = os.path.dirname(lstfiles[0])
    print('sp: ',sp)
    # copy the exe to modeltmpdir
    exe = os.path.join(modeltmpdir, os.path.basename(lstfiles[0]))
    print('new exe path: ',exe)
    copyfile(lstfiles[0], exe)    
    # copy ibound to modeltmpdir
    copyfile(os.path.join(sp,lstfiles[1]), os.path.join(modeltmpdir, lstfiles[1]))    
    copyfile(os.path.join(sp,lstfiles[2]), os.path.join(modeltmpdir, lstfiles[2]))    
        
    # the function setupModelRUN creates a runfile based on the given parameters, extent and factor of change
    runfile = setupModelRUN(modeltmpdir,modelextent,template_run,factor)
    print('runfile: ',runfile)
    # run the model with the copied exe
    runModel(exe,runfile)
    
    # the sc0dir is the directory which contains all input files and also a dir called def_scenario.
    # this is the initial run, based
    sc0dir = os.path.join(modeldir,'def_scenario')
    file = handleoutput(sc0dir, modeltmpdir,vislayer,watersId)
    return file

def mainHandler(cf,configuration,watersId):
    # rip the config into pieces
    c = json.loads(configuration)
    factor = c['riverbedDifference']
    extent = c['extent']
    calclayer = c['calculationLayer']
    vislayer = c['visualisationLayer']
    print('factor: ',factor)
    try:
        agtif = setupgwmodelandrun(cf, watersId,extent,factor,vislayer,calclayer)
        #agtif = 'opt/pywps/tmp/pywps_process_66n134wv/difhead_waters_1573832155882882.tif'
        wmslayer = geoserverUploadGTIFF(cf, agtif)
        #wmslayer = geoserver_upload_gtif(cf,'_'.join(['difhead',watersId]),agtif)
    except Exception as e:
        print("Error!:", e)
        wmslayer = 'maaiveld:maaiveld'
    return wmslayer

