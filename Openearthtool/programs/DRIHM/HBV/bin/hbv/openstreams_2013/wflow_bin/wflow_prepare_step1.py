#!python
"""
wflow_prepare_step1
===================

wflow data preparation script. Data preparation can be done by hand or using 
the two scripts. This script does the first step. The second script does 
the resampling.


Usage::

    wflow_prepare_step1 -W workdir -I inifile -f -h
    
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



def usage(*args):
    sys.stdout = sys.stderr
    for msg in args: print msg
    print __doc__
    sys.exit(0)


def configget(config,section,var,default):
    """
    gets parameter from config file and returns a default value
    if the parameter is not found
    """
    try:
        ret = config.get(section,var)
    except:
        print "returning default (" + default + ") for " + section + ":" + var
        ret = default
        
    return ret
        


def main():
    """
        
    :ivar masterdem: digital elevation model
    :ivar dem: digital elevation model
    :ivar river: optional river map
    """

    # Default values
    strRiver = 8
    masterdem = "dem.map"
    step1dir = "step1"
    step2dir="step2"
    workdir = "."
    inifile = "wflow_prepare.ini"
    recreate = False
    snapgaugestoriver = False
    
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'W:hI:f')
    except getopt.error, msg:
        usage(msg)


    for o, a in opts:
        if o == '-W': workdir = a
        if o == '-I': inifile = a
        if o == '-h': usage()
        if o == '-f': recreate = True

    tr.setglobaloption("unitcell") 
    os.chdir(workdir)    

    config = ConfigParser.SafeConfigParser()
    config.optionxform = str
    # First read the file in master dir, next in Case dir
    config.read(workdir + "/" + inifile)



    masterdem = config.get("files","masterdem")
    tr.setclone(masterdem)


    strRiver = int(configget(config,"settings","riverorder","4"))
   
    gauges_x = config.get("settings","gauges_x")
    gauges_y = config.get("settings","gauges_y")
    step1dir = config.get("directories","step1dir")
    step2dir = config.get("directories","step2dir")
    #upscalefactor = float(config.get("settings","upscalefactor"))
    outflowdepth = float(config.get("settings","lddoutflowdepth"))
    initialscale = int(config.get("settings","initialscale"))
    csize= float(config.get("settings","cellsize"))

    snapgaugestoriver=bool(int(configget(config,"settings","snapgaugestoriver","1")))
    lddglobaloption=configget(config,"settings","lddglobaloption","lddout")
    tr.setglobaloption(lddglobaloption)
    lu_water= configget(config,"files","lu_water","")
    lu_paved= configget(config,"files","lu_paved","")
    
    # X/Y coordinates of the gauges the system
    exec "X=tr.array(" + gauges_x + ")" 
    exec "Y=tr.array(" + gauges_y + ")" 

    tr.Verbose=1

    # make the directories to save results in
    if not os.path.isdir(step1dir +"/"):
        os.makedirs(step1dir)
    if not os.path.isdir(step2dir):
        os.makedirs(step2dir)    


    if initialscale > 1:
        print "Initial scaling of DEM..."
        os.system("resample -r " + str(initialscale) + " "  + masterdem + " " + step1dir + "/dem_scaled.map")
        print("Reading dem...")
        dem = tr.readmap(step1dir + "/dem_scaled.map") 
    else:
        print("Reading dem...")
        dem = tr.readmap(masterdem)
        
    # See if there is a shape file of the river to burn in 
    try:
        rivshp = config.get("files","river")
    except:
        print "no river file specified"
    else:
        print "river file speficied....."
        rivshpattr = config.get("files","riverattr")
        tr.report(dem * 0.0,step1dir + "/nilmap.map")
        thestr = "gdal_translate -of GTiff " + step1dir + "/nilmap.map " + step1dir + "/riverburn.tif"
        os.system(thestr)
        os.system("gdal_rasterize -burn 1 -l " + rivshpattr + " " + rivshp + " " + step1dir + "/riverburn.tif")
        thestr = "gdal_translate -of PCRaster " + step1dir + "/riverburn.tif " + step1dir + "/riverburn.map"
        os.system(thestr)
        riverburn = tr.readmap(step1dir + "/riverburn.map")
        dem = tr.ifthenelse(riverburn >= 1.0, dem -1000 , dem)
    
        
       
    tr.setglobaloption("unittrue") 
    upscalefactor=int(csize/tr.celllength())

    print("Creating ldd...")
    ldd=tr.lddcreate_save(step1dir +"/ldd.map",dem, recreate, outflowdepth)

    print("Determining streamorder...")
    stro=tr.streamorder(ldd)
    tr.report(stro,step1dir + "/streamorder.map")
    strdir = tr.ifthen(stro >= strRiver, stro)
    tr.report(strdir,step1dir + "/streamorderrive.map")
    tr.report(tr.boolean(tr.ifthen(stro >= strRiver, stro)),step1dir + "/rivers.map")


    tr.setglobaloption("unittrue")

    # outlet (and other gauges if given)
    #TODO: check is x/y set if not skip this
    print("Outlet...")

    outlmap = tr.points_to_map(dem,X,Y,0.5)

    if snapgaugestoriver:
        print "Snapping gauges to nearest river cells..."
        tr.report(outlmap,step1dir + "/orggauges.map")
        outlmap= tr.snaptomap(outlmap,strdir)


    #noutletmap = tr.points_to_map(dem,XX,YY,0.5)
    #tr.report(noutletmap,'noutlet.map')


    tr.report(outlmap,step1dir + "/gauges.map")



        # check if there is a pre-define catchment map
    try:
        catchmask = config.get("files","catchment_mask")
    except:
        print "No catchment mask, finding outlet"
        # Find catchment (overall)
        outlet = tr.find_outlet(ldd)
        sub = tr.subcatch(ldd,outlet)
        tr.report(sub,step1dir + "/catchment_overall.map")
    else:
        print "reading and converting catchment mask....."
        os.system("resample -r " + str(initialscale) + " "  + catchmask + " " + step1dir + "/catchment_overall.map")
        sub = tr.readmap(step1dir + "/catchment_overall.map")

        
     
    print("Scatch...")
    sd = tr.subcatch(ldd,tr.ifthen(outlmap>0,outlmap))
    tr.report(sd,step1dir + "/scatch.map")

    tr.setglobaloption("unitcell")
    print "Upscalefactor: " + str(upscalefactor)
          
    if upscalefactor > 1:
        print("upscale river length1 (checkerboard map)...")
        ck = tr.checkerboard(dem,upscalefactor)
        print("upscale river length2...")
        fact = tr.area_riverlength_factor(ldd, ck,upscalefactor)
        tr.report(fact,step1dir + "/riverlength_fact.map")
    
        #print("make dem statistics...")
        demavg = tr.areaaverage(dem,ck)
        tr.report(demavg,step1dir + "/demavg.map")
    
    
        print("Create DEM statistics...")
    
        demmin = tr.areaminimum(dem,ck)
        tr.report(demmin,step1dir + "/demmin.map")
        demmax = tr.areamaximum(dem,ck)
        tr.report(demmax,step1dir + "/demmax.map")
        # calculate percentiles
        order = tr.areaorder(dem,ck)
        n = tr.areatotal(tr.spatial(tr.scalar(1.0)),ck)
        #: calculate 25 percentile
        perc = tr.area_percentile(dem,ck,n,order,25.0)
        tr.report(perc,step1dir + "/dem25.map")
        perc = tr.area_percentile(dem,ck,n,order,10.0)
        tr.report(perc,step1dir + "/dem10.map")
        perc = tr.area_percentile(dem,ck,n,order,50.0)
        tr.report(perc,step1dir + "/dem50.map")
        perc = tr.area_percentile(dem,ck,n,order,33.0)
        tr.report(perc,step1dir + "/dem33.map")
        perc = tr.area_percentile(dem,ck,n,order,66.0)
        tr.report(perc,step1dir + "/dem66.map")
        perc = tr.area_percentile(dem,ck,n,order,75.0)
        tr.report(perc,step1dir + "/dem75.map")
        perc = tr.area_percentile(dem,ck,n,order,90.0)
        tr.report(perc,step1dir + "/dem90.map")
    else:
         print("No fancy scaling donegoing strait to step2....")
         tr.report(dem,step1dir + "/demavg.map")
         Xul = float(config.get("settings","Xul"))
         Yul = float(config.get("settings","Yul"))
         Xlr = float(config.get("settings","Xlr"))
         Ylr = float(config.get("settings","Ylr"))
         gdalstr = "gdal_translate  -projwin " + str(Xul) + " " + str(Yul) + " " +str(Xlr) + " " +str(Ylr) + " -of PCRaster  " 
         #gdalstr = "gdal_translate  -a_ullr " + str(Xul) + " " + str(Yul) + " " +str(Xlr) + " " +str(Ylr) + " -of PCRaster  " 
         print gdalstr
         tr.report(tr.cover(1.0),step1dir + "/wflow_riverlength_fact.map")
         
         # Now us gdat tp convert the maps
         os.system(gdalstr + step1dir + "/wflow_riverlength_fact.map" + " " + step2dir + "/wflow_riverlength_fact.map")
         os.system(gdalstr + step1dir + "/demavg.map" + " " + step2dir + "/wflow_dem.map")
         os.system(gdalstr + step1dir + "/demavg.map" + " " + step2dir + "/wflow_demmin.map")
         os.system(gdalstr + step1dir + "/demavg.map" + " " + step2dir + "/wflow_demmax.map")
         os.system(gdalstr + step1dir + "/gauges.map" + " " + step2dir + "/wflow_gauges.map")
         os.system(gdalstr + step1dir + "/rivers.map" + " " + step2dir + "/wflow_river.map")
         os.system(gdalstr + step1dir + "/streamorder.map" + " " + step2dir + "/wflow_streamorder.map")
         os.system(gdalstr + step1dir + "/gauges.map" + " " + step2dir + "/wflow_outlet.map")
         os.system(gdalstr + step1dir + "/scatch.map" + " " + step2dir + "/wflow_catchment.map")
         os.system(gdalstr + step1dir + "/ldd.map" + " " + step2dir + "/wflow_ldd.map")
         os.system(gdalstr + step1dir + "/scatch.map" + " " + step2dir + "/wflow_subcatch.map")
         
         if lu_water:
             os.system(gdalstr + lu_water + " " + step2dir + "/WaterFrac.map")

         if lu_paved:
             os.system(gdalstr + lu_paved + " " + step2dir + "/PathFrac.map")

         try:
            lumap = config.get("files","landuse")
         except:
            print "no landuse map...creating uniform map"
            #clone=tr.readmap(step2dir + "/wflow_dem.map")
            tr.setclone(step2dir + "/wflow_dem.map")
            tr.report(tr.nominal(1),step2dir + "/wflow_landuse.map")
         else:
            os.system("resample --clone " + step2dir + "/wflow_dem.map " + lumap + " " + step2dir + "/wflow_landuse.map")

         try:
             soilmap = config.get("files","soil")
         except:
             print "no soil map..., creating uniform map"
             tr.setclone(step2dir + "/wflow_dem.map")
             tr.report(tr.nominal(1),step2dir + "/wflow_soil.map")  
         else:
             os.system("resample --clone " + step2dir + "/wflow_dem.map " + soilmap + " " + step2dir + "/wflow_soil.map")




if __name__ == "__main__":
    main()
