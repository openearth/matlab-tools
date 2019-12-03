#!python
"""
wflow_prepare_step2
===================

wflow data preparation script. Data preparation can be done by hand or using 
the two scripts. This script does the resampling.


Usage::

    wflow_prepare_step2 -W workdir -I inifile -f -h

::    
    
    -f force recreation of ldd if it already exists
    -h show this information
    -W set the working directory, default is current dir
    -I name of the ini file with settings


$Id: $
"""


try:
    import wflow.wflow_lib as tr
except ImportError:
    import wflow_lib as tr
import os
import os.path
import getopt
import ConfigParser
import sys

tr.Verbose=1



def usage(*args):
    sys.stdout = sys.stderr
    for msg in args: print msg
    print __doc__
    sys.exit(0)
    
def configget(config,section,var,default):
    """
    """
    try:
        ret = config.get(section,var)
    except:
        print "returning default (" + default + ") for " + section + ":" + var
        ret = default
        
    return ret
        


def main():
    """

    """
    workdir = "."
    inifile = "wflow_prepare.ini"
    
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'W:hI:f')
    except getopt.error, msg:
        usage(msg)


    for o, a in opts:
        if o == '-W': workdir = a
        if o == '-I': inifile = a
        if o == '-h': usage()
        if o == '-f': recreate = True
        
    os.chdir(workdir)
      


    tr.setglobaloption("unitcell") 
    config = ConfigParser.SafeConfigParser()
    config.optionxform = str
    # First read the file in master dir, next in Case dir
    config.read(workdir + "/" + inifile)

    step1dir = config.get("directories","step1dir")
    step2dir = config.get("directories","step2dir")
    snapgaugestoriver=bool(int(configget(config,"settings","snapgaugestoriver","1")))

    # make the directories to save results in
    if not os.path.isdir(step1dir +"/"):
        os.makedirs(step1dir)
    if not os.path.isdir(step2dir):
        os.makedirs(step2dir)


    ##first make the clone map
    Xul = float(config.get("settings","Xul"))
    Yul = float(config.get("settings","Yul"))
    Xlr = float(config.get("settings","Xlr"))
    Ylr = float(config.get("settings","Ylr"))
    csize= float(config.get("settings","cellsize"))
    gauges_x = config.get("settings","gauges_x")
    gauges_y = config.get("settings","gauges_y")
    strRiver = int(configget(config,"settings","riverorder","4"))
    outflowdepth = float(config.get("settings","lddoutflowdepth"))
    lddmethod = config.get("settings","lddmethod")
    lddglobaloption=configget(config,"settings","lddglobaloption","lddout")
    tr.setglobaloption(lddglobaloption)

    nrrow = round(abs(Yul - Ylr)/csize)
    nrcol = round(abs(Xlr - Xul)/csize)
    mapstr = "mapattr -s -S -R " +  str(nrrow) + " -C " + str(nrcol) + " -l " + str(csize) + " -x " + str(Xul) + " -y " + str(Yul) + " -P yb2t " + step2dir + "/cutout.map"

    os.system(mapstr)
    tr.setclone(step2dir + "/cutout.map")


    lu_water= configget(config,"files","lu_water","")
    lu_paved= configget(config,"files","lu_paved","")
    
    if lu_water:
        os.system("resample --clone " + step2dir + "/cutout.map " + lu_water + " " + step2dir + "/wflow_waterfrac.map")
        
    if lu_paved:
        os.system("resample --clone " + step2dir + "/cutout.map " + lu_paved + " " + step2dir + "/PathFrac.map")

    #
    try:
        lumap = config.get("files","landuse")
    except:
        print "no landuse map...creating uniform map"
        clone=tr.readmap(step2dir + "/cutout.map")
        tr.report(tr.nominal(clone),step2dir + "/wflow_landuse.map")
    else:
        os.system("resample --clone " + step2dir + "/cutout.map " + lumap + " " + step2dir + "/wflow_landuse.map")

    try:
        soilmap = config.get("files","soil")
    except:
        print "no soil map..., creating uniform map"
        clone=tr.readmap(step2dir + "/cutout.map")
        tr.report(tr.nominal(clone),step2dir + "/wflow_soil.map")  
    else:
        os.system("resample --clone " + step2dir + "/cutout.map " + soilmap + " " + step2dir + "/wflow_soil.map")

    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/dem10.map " + step2dir + "/wflow_dem10.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/dem25.map " + step2dir + "/wflow_dem25.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/dem33.map " + step2dir + "/wflow_dem33.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/dem50.map " + step2dir + "/wflow_dem50.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/dem66.map " + step2dir + "/wflow_dem66.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/dem75.map " + step2dir + "/wflow_dem75.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/dem90.map " + step2dir + "/wflow_dem90.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/demavg.map " + step2dir + "/wflow_dem.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/demmin.map " + step2dir + "/wflow_demmin.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/demmax.map " + step2dir + "/wflow_demmax.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/riverlength_fact.map " + step2dir + "/wflow_riverlength_fact.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/catchment_overall.map " + step2dir + "/catchment_cut.map")
    os.system("resample --clone " + step2dir + "/cutout.map " + step1dir + "/rivers.map " + step2dir + "/wflow_riverburnin.map")

    dem = tr.readmap(step2dir + "/wflow_dem.map")
    demmin = tr.readmap(step2dir + "/wflow_demmin.map")
    demmax = tr.readmap(step2dir + "/wflow_demmax.map")
    catchcut = tr.readmap(step2dir + "/catchment_cut.map")
    # now apply the area of interest (catchcut) to the DEM
    #dem=tr.ifthen(catchcut >=1 , dem)
    #
    riverburn = tr.readmap(step2dir + "/wflow_riverburnin.map")

    # Only burn within the original catchment
    riverburn = tr.ifthen(catchcut >= 1, riverburn)
    # Now setup a very high wall around the catchment that is scale
    # based on the distance to the catchment so that it slopes away from the 
    # catchment
    if lddmethod != 'river':
        print "Burning in highres-river ..."
        disttocatch = tr.spread(tr.nominal(catchcut),0.0,1.0)
        demmax = tr.ifthenelse(tr.scalar(catchcut) >=1.0, demmax, demmax + (tr.celllength() * 100.0) /disttocatch)
        demburn = tr.cover(tr.ifthen(tr.boolean(riverburn), demmin) ,demmax)
    else:
        print "using average dem.."
        demburn = dem


    ldd = tr.lddcreate_save(step2dir + "/wflow_ldd.map",demburn, True, outflowdepth)

    # Find catchment (overall)
    outlet = tr.find_outlet(ldd)
    sub = tr.subcatch(ldd,outlet)
    tr.report(sub,step2dir + "/wflow_catchment.map")
    tr.report(outlet,step2dir + "/wflow_outlet.map")

    # make river map
    strorder = tr.streamorder(ldd)
    tr.report(strorder,step2dir + "/wflow_streamorder.map")
    print strRiver
    river = tr.ifthen(tr.boolean(strorder >= strRiver),strorder)
    tr.report(river,step2dir + "/wflow_river.map")

    # make subcatchments
    #os.system("col2map --clone " + step2dir + "/cutout.map gauges.col " + step2dir + "/wflow_gauges.map")
    exec "X=tr.array(" + gauges_x + ")" 
    exec "Y=tr.array(" + gauges_y + ")" 


    tr.setglobaloption("unittrue")

    outlmap = tr.points_to_map(dem,X,Y,0.5)
    tr.report(outlmap,step2dir + "/wflow_gauges_.map")
      
    if snapgaugestoriver:    
        print "Snapping gauges to river"
        tr.report(outlmap,step2dir + "/wflow_orggauges.map")
        outlmap= tr.snaptomap(outlmap,river)
        
    outlmap = tr.ifthen(outlmap > 0, outlmap)    
    tr.report(outlmap,step2dir + "/wflow_gauges.map")


    scatch = tr.subcatch(ldd,outlmap)
    tr.report(scatch,step2dir + "/wflow_subcatch.map")



if __name__ == "__main__":
    main()
