# test for pyodv & odv2orm + subsequent odv plotting tools

import openearthtools.io.pyodv as pyodv

tempDir   = 'c:/temp//'
data_type = 33
plot      = 1
source    = 'pg' #'pg' # 'os'
kmz       = 0 # slow


if source=='os':# pyodv
    import os
    odvDir    = "d:/checkouts/OpenEarthRawData/SeaDataNet/"
    odvDir    = 'c:/pywps/pywps_processes/data_test//'
elif source=='pg': # odv2orm
    import odv2orm_query
    from geoalchemy2.elements import WKTElement
    querytype = 'bbox' #'cdi' # 'bbox'
    f = open('odvconnection.txt')
    dbstring = f.read()
    f.close()

zname        = ""

# point
if data_type==0:
   odvdir       = "635" # "usergd30d98-data_centre635-210311_result"
   LOCAL_CDI_ID = "BP150010"
   edmo         = "635"
   filename     = "BP150010"
   cname        = "SEGMLENG"
   zname        = "COREDIST"
   clims        = []
   bbox         = [-10,10,50,60]

# trajectory
if data_type==1:
   odvdir       = "632" # "userkc30e50-data_centre632-090210_result"
   LOCAL_CDI_ID = "world_N50W10N40E0_20060101_20070101"
   edmo         = "632"
   filename     = "world_N50W10N40E0_20060101_20070101"
   cname        = "PSSTTS01" #"Sea-surface_temp(tw) [C]" # "Wind_direction(dd) [deg]" # mind for WPS urls: use html encoding: space is %20
   clims        = [10,20]
   #cname       = "Wind_direction(dd) [deg]" # mind for WPS urls: use html encoding: space is %20
   #clims       = [0, 360]
   bbox         = [-10,0,40,50]

# timeseries: seperate time column: time_ISO8601
if data_type==21:
   odvdir       = "486"
   LOCAL_CDI_ID = "28060209_PCh_Surf"
   edmo         = "486"
   filename     = "28060209_PCh_Surf_20140514_165015"
   cname        = "CPHLFLPZ" #"chl-a_fluorometry_[ug/l]" # "Wind_direction(dd) [deg]" # mind for WPS urls: use html encoding: space is %20
   clims        = []
   bbox         = [-10,10,40,60]
   
# timeseries seperate time column: Julian
if data_type==22:
   odvdir       = "1526" # "usergd30d98-data_centre1526-2011-04-13_result"
   LOCAL_CDI_ID = "1000"
   edmo         = "1526"
   filename     = "1000_20110413_100100"
   cname        = "ASLVZZ01"
   clims        = []
   bbox         = [-10,10,40,60]   

# water profile: pressure
if data_type==31:
   odvdir       = "630" # "usergd30d98-data_centre630-2011-02-23_result"
   LOCAL_CDI_ID = "CTDCAST_79___42"
   edmo         = "630"
   filename     = "CTDCAST_79___42_20110223_120541"
   cname        = "SIGTPR01" #"Density [kg/m3]"
   zname        = "PRESPS01" #'PRESSURE [dbar]'
   clims        = []
   bbox         = [-10,-5,45,50]
   
# water profile: depth
if data_type==32:
   odvdir       = "729" # "userfg30f3e-data_centre729-2014-06-03_result"
   LOCAL_CDI_ID = "CTD_10961" # excl .txt
   edmo         = "729"
   filename     = "CTD_10961_20140603_012901"
   cname        = "TEMPST01" # "temp"
   zname        = "ADEPZZ01" # 'z [m]'
   clims        = []   
   bbox         = [9,12,55,60]
   
# soil profile: depth
if data_type==33:
   odvdir       = "635" # "usergd30d98-data_centre635-210311_result"
   LOCAL_CDI_ID = "BF080006"
   edmo         = "635"
   filename     = "BF080006"
   cname        = "SEGMLENG"
   zname        = "COREDIST"
   clims        = []
   bbox         = [-10,10,50,60]

if source=='os':# pyodv
    odvname = odvDir + odvdir + '/' + filename + '.txt'
    O       = pyodv.pyodv.Odv.fromfile(odvname)
elif source=='pg': # odv2orm
    if querytype=='cdi':
        O = odv2orm_query.orm_from_cdi (dbstring, cname, edmo+':'+LOCAL_CDI_ID)
    elif querytype=='bbox':
        O = odv2orm_query.orm_from_bbox(dbstring, cname, bbox[0],bbox[1],bbox[2],bbox[3])

if plot and len(O.data) > 0:
    pyodv.odv2profile   (tempDir+source+'_'+LOCAL_CDI_ID+'_'+O.data_type+'_as_profile0.png'   ,O,cname,clims=clims,log10=0,)
    pyodv.odv2profile   (tempDir+source+'_'+LOCAL_CDI_ID+'_'+O.data_type+'_as_profile1.png'   ,O,cname,clims=clims,log10=1)

    pyodv.odv2profile   (tempDir+source+'_'+LOCAL_CDI_ID+'_'+O.data_type+'_as_profile0z.png'  ,O,cname,clims=clims,log10=0,zname=zname)
    pyodv.odv2profile   (tempDir+source+'_'+LOCAL_CDI_ID+'_'+O.data_type+'_as_profile1z.png'  ,O,cname,clims=clims,log10=1,zname=zname)
    
    pyodv.odv2timeseries(tempDir+source+'_'+LOCAL_CDI_ID+'_'+O.data_type+'_as_timeseries0.png',O,cname,clims=clims,log10=0)
    pyodv.odv2timeseries(tempDir+source+'_'+LOCAL_CDI_ID+'_'+O.data_type+'_as_timeseries1.png',O,cname,clims=clims,log10=1)
    
    pyodv.odv2map       (tempDir+source+'_'+LOCAL_CDI_ID+'_'+O.data_type+'_as_map0.png'       ,O,cname,clims=clims,log10=0)
    pyodv.odv2map       (tempDir+source+'_'+LOCAL_CDI_ID+'_'+O.data_type+'_as_map1.png'       ,O,cname,clims=clims,log10=1)  
    
if kmz:
    pyodv.odv2mapkmz    (kmlnamem0,O,cname,clims=clims,log10=0,cmapstr="jet")
    pyodv.odv2mapkmz    (kmlnamem1,O,cname,clims=clims,log10=1,cmapstr="jet")
