    # -*- coding: utf-8 -*-
"""
Created on Wed May 11 10:12:14 2016

@author: hegnauer
"""

import sqlite3
from osgeo import ogr
import numpy as np
import shlex

def GetBlock(def_file, crs_def):
    dataBlock = []
    fInput  = open( def_file, 'r')
    logFound= False

    while( not logFound ):
           line = fInput.readline()     # lees regel in, en sla op in variable line (of andere naam indien gewenst)
           if not line: break           # Verlaat de loop, indien fout ten gevolge van End of File, voor fout afhandeling
           line  = line.strip(' ')      # via strip: verwijder leading and trailing blank characters (hier niet nodig, maar nice to know)

#           if (crs_def in line and 'yz' in line): 
           if len(line.split(' ')) > 1:
               if (crs_def == line.split(' ')[2][1:-1] and 'yz' in line): 
                   logFound= True
#                   print "logfound"
               
    line       = fInput.readline()    # Lees volgende regel
    line       = line.strip(' ')      # remove leading and trailing blanks

    nrows = 100 ## Dit is nu nog dummy getal!!
    for row in range(0,nrows):
        line     = fInput.readline()    # Lees volgende regel
        if not 'tble' in line:    
            line     = line.strip(' ')      # remove leading and trailing blanks
            lineSplit= line.split()        # lineSplit is nu een array met de opvolgende samenhangende velden in de input string line

            y = round( float( lineSplit[0] ) ,2)
            z = round( float( lineSplit[1] ) ,2)
#            print y , z
            
            data = {y:z}
            dataBlock.append(data)
        else: 
            break

    fInput.close()
    return dataBlock

path     = r'd:\tools\HYDTools\sandbox\3Di_model_building\sobek'
dat_file = path + '/PROFILE.DAT'
def_file = path + '/PROFILE.DEF'
csv_file = path + '/PROFILE.csv'

f = open(dat_file)
crs_defs = []
for line in f.readlines():
    crs_id = shlex.split(line)[2]
    def_id = shlex.split(line)[4]
    crs_def = {crs_id:def_id}
    crs_defs.append(crs_def)

#crs_defs = crs_defs.sort()

w = open(csv_file, 'w')
w.write('id,shape,width,diameter,level,y,z,closed,height,crs_id\n')
for i in range(0,len(crs_defs)):
    for key, value in crs_defs[i].iteritems():
        try:
            yz = GetBlock(def_file, value)
            y=[]
            z=[]
            for j in range(0,len(yz)):
                y.append(yz[j].keys()[0])
                z.append(yz[j].values()[0])
                
            w.write('%s,4,,,,"%s","%s",,,%s\n' %(i+1,str(y).replace('[','').replace(']',''),str(z).replace('[','').replace(']',''),key))
        except:
            print "Not YZ, return dummy rectangle"
            w.write('%s,1,4,,,,,,1,%s\n' %(i+1,key)) # hierin staan de dummywaarden
w.close()


                




















#conn       = sqlite3.connect(db)
##print conn.execute("PRAGMA foreign_keys").fetchall()
#cursor     = conn.cursor()
#
#tables     = cursor.execute("select name from sqlite_master where type = 'table'").fetchall()
#driver     = ogr.GetDriverByName("Sqlite")
#dataSource = driver.Open(db, 0)
#print "Available tables in SQLITE are:\n"
#for i in range(0, len(dataSource)):
#    print i, dataSource.GetLayer(i).GetName()

#driver = ogr.GetDriverByName('ESRI Shapefile')
#shp = driver.Open(r'c:\3Di\SubGrid\authaya\shapes\Sbk_Prof_n_wgs84.shp')
#layer = shp.GetLayer()
#
#shp_ids = []
#for feature in layer:
#    shp_ids.append(feature.GetField("ID"))