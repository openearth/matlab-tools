# Python 2.7, created by Pauw on 2017-01-08

# Simulate axial symmetric groundwater flow. The approach of Langevin
# (2008) is followed here. Logaritmic averaging of the horizontal
# hydraulic conductivity should be used. In the LPF package,
# this is done by setting the layflag to 2. In the BCF, this is
# intercellt = 2 or 3.
# The hydraulic properties need to be multiplied by 2 pi and the radial
# distance of the cell node r. The discharge of the well doesn't
# have to be changed. Areally distributed fluxes such as recharge
# are multiplied by 2 pi r.
# This approach works for solute transport and variable density
# also, but only for horizontally homogeneous systems.

# Import Python modules
import math
import os, sys
import numpy as np
#import matplotlib.pyplot as plt
import pandas as pd
from scipy.interpolate import griddata

# JOAN [in order to generate unique temp files we must setup a temporary dir as argument]
if len(sys.argv) == 2:
    tmpdir=sys.argv[1]
else:
    tmpdir='.' # otherwise local directory

# JOAN [in order to execute from pywps we must change directory]
os.chdir(r"D:\onttrekkingtool_zeeland")

# JOAN append ABSOLUTE paths to sys to find appropriate flopy version
sys.path.append(r'D:\onttrekkingtool_zeeland\site_packages\flopy-3.2.4')
import flopy
import flopy.utils.binaryfile as bf

# JOAN append path for Wiebe's library for converting asc to raster/geotif
sys.path.append(r'D:\onttrekkingtool_zeeland\site_packages\Lib_Wiebe')
import raster_func as rf

# Set path of the executable (for now, local at d)
exepath = "mf2005.exe"

# Define the MODFLOW, MT3DMS and SEAWAT models.
name = 'onttrekking'
ml = flopy.modflow.Modflow(modelname=name, exe_path= exepath)
mt = flopy.mt3d.Mt3dms(modelname=name, modflowmodel = ml)
swt = flopy.seawat.Seawat(modelname = name, modflowmodel=ml, mt3dmsmodel=mt,
                          exe_name = exepath)

# define grid for model calculation
# the array r contains the radial distances of the sides of the columns
# it has length ncol + 1. the first number is the left side of the first column,
# the last number is the right side of the last column.
delr = [0.1]
for i in range(35):
    delr.append(delr[i]*1.302) # 1.302 is the expansion factor.
r = np.cumsum(np.array(delr))-(np.array(delr)/2) # coordinates
ncol = len(delr)
nrow=1

# Extract input from user-entered values
df = pd.read_csv(os.path.join(tmpdir, 'input.csv'),skiprows=2,delimiter=';')
xcor = df.x[0] # x coordinate, in RD (m)
ycor = df.y[0] # y coordinate, in RD (m)
# Note that z, x, and y are not actually needed (not used) in the computation
t = df.t[0] # time of the abstraction (d)
Q = df.Q[0] # volumetric discharge rate of the abstraction (m3/d)
Tf = abs(df.Tf[0]) # top filter depth (ground level) (m)
Lf = abs(df.Lf[0]) # length of the filter (m)
Bf = Tf+Lf
Ss = df.Ss[0] # specific storage (m^-1)
Sy = df.Sy[0] # specific yield (-)

# Define GeoTOP Dataframe with Kh and Kv values
index = ['antropogeen','organisch materiaal (veen)','klei',
         'klei zandig, leem, kleiig fijn zand','zand fijn','zand matig grof',
         'zand grof','grind']
data = np.array([[4.9,4.9],[0.07256,0.07256],[0.00384,0.00384],[0.0431,0.0314],
                 [3.1,1.9],[10.4,6.7],[28.4,23.4],[85,85]])
geotop_classes = pd.DataFrame(index = index, data=data,columns = ['Kh','Kv'])

# Read in litho from info_geotop.csv
geotop_info = pd.read_csv(os.path.join(tmpdir, 'info_geotop.csv'),delimiter = ',',
                          names = ['unit','litho','top','bot'])
top = geotop_info.iloc[0].top # might change this! For now, assume it is
# relative to ground level. Groundwater level is 1 m below ground level.
tops = geotop_info.top
bots = geotop_info.bot

Kh = np.zeros(len(np.arange(tops.iloc[0],bots.iloc[-1],0.5)))
Kv = Kh

for i in range(len(geotop_info)):
    Kh[int(geotop_info.top[i]/0.5):int(geotop_info.bot[i]/0.5)] = \
    geotop_classes.loc[geotop_info.loc[i].litho.lower()].Kh
    Kv[int(geotop_info.top[i]/0.5):int(geotop_info.bot[i]/0.5)] = \
    geotop_classes.loc[geotop_info.loc[i].litho.lower()].Kv

# these parameters are for the grid, where the output of the model is
# projected on
cellsize = 5 # m
extent = 500 # m; the extent of the grid (not of the model).

# define vertical distribution of layers
bottoms = -1*np.arange(top+0.5,bots.iloc[-1]+0.5,0.5)
nlay = len(bottoms)

# Define the MODFLOW model
perlen = 1 # period length
nper = int(t/perlen) # 7 days
nstp = 6 # number of time steps

# MODFLOW
discret = flopy.modflow.ModflowDis(ml,nlay = nlay,nrow = 1, ncol = ncol,\
                         delr=delr, delc=1, top=top,\
                         botm=bottoms, perlen = perlen, nper=nper,
                                   nstp=nstp,steady=False)

# Add the Basic package
ibound = np.ones((nlay,nrow,ncol))
ibound[:,0,-1] = -1
start = np.zeros((nlay, nrow, ncol))
bas = flopy.modflow.ModflowBas(ml,ibound=ibound,strt=start)

# the variable r contains all the sides of the model
Kh_arr = np.ones((nlay,nrow,ncol))
Kv_arr = np.ones((nlay,nrow,ncol))
for i in range(len(Kh)):
    Kh_arr[i,:,:] = Kh[i]
    Kv_arr[i,:,:] = Kv[i]
Ss_arr = Ss*np.ones((nlay,nrow,ncol))
Ss_arr[0,:,:] = Sy
Sy_arr = Sy*np.ones((nlay,nrow,ncol))

# multiply by 2pi r
for i in range(len(delr)):
    Kh_arr[:,0,i] = r[i]*2*math.pi*Kh_arr[:,0,i]
    Kv_arr[:,0,i] = r[i]*2*math.pi*Kv_arr[:,0,i]
    Ss_arr[:,0,i] = r[i]*2*math.pi*Ss_arr[:,0,i]
    Sy_arr[:,0,i] = r[i]*2*math.pi*Sy_arr[:,0,i]

# Add the Block-Centered Flow Package,
lpf = flopy.modflow.ModflowLpf(ml, laytyp = 0, layvka = 0,\
                               hk = Kh_arr, vka = Kv_arr, ss=Ss_arr, sy = Sy_arr, \
                               constantcv=True,layavg = 2)

# Add the well package
# Add the Recharge Package
wels = dict()
debiet = -Q #
nwell = int(Lf/0.5) # number of wells
weights = Kh[int(Tf/0.5):int(Bf/0.5)] / np.sum(Kh[int(Tf/0.5):int(Bf/0.5)])

for p in range(nper):
    dum = []
    for i in range(nwell):
        dum.append([int(Tf/0.5)+i,0,0,debiet*weights[i]])
    wels[p] = dum
wel = flopy.modflow.ModflowWel(ml,stress_period_data = wels)

# Add the Output Control and the PCG Solver Packages.
stress_period_data = dict()
for i in range(nper):
    stress_period_data[(i,nstp-1)] = ['save head','save budget']
    stress_period_data[(i+1,0)] = []
oc = flopy.modflow.ModflowOc(ml,stress_period_data=stress_period_data)
pcg = flopy.modflow.ModflowPcg(ml, mxiter = 500,rclose = 0.001,hclose=1E-4)

# Write all model input
ml.write_input()
flopy.modflow.Modflow.write_name_file(ml)

# run the model (beware of the executeable)

ml.run_model(silent=True)

## Read output

import flopy.utils.binaryfile as bf
hds = bf.HeadFile(name+'.hds')
head = hds.get_alldata()
hdstimes = hds.get_times()

# take the last output time step
headarray = head[-1,1,0,:]

# now, make the grid and project the model outcome on the grid

# create x and y directions
xi = np.arange(cellsize/2.,extent+cellsize/2.,cellsize)
yi = xi

# calculate the distances of the grid to the origin
grid = np.zeros((len(xi),len(yi)))
for x in range(len(xi)):
    for y in range(len(yi)):
        grid[x,y] = math.sqrt(xi[x]**2+yi[y]**2)

# 1) flatten the grid, 2) interpolate the values along the r axis of the
# axisymmetric model, and 3) 'ungrid' the flattened array
grid1d = np.reshape(grid,len(xi)*len(yi),order='C')
gridded = griddata(r,headarray,grid1d)
ungridded = np.reshape(gridded,(len(xi),(len(yi))),order = 'C')

# now we have one quarter of the actual grid. flip over the x axis and
# then the resulting rectange over the y axis
dum = np.vstack((np.flipud(ungridded),ungridded))
finalgrid = np.hstack((np.fliplr(dum),dum))

##
##plt.plot(r,headarray)
##plt.plot(grid1d,gridded,'ro')
##plt.xlim(0,50)
##plt.show()


# now, make the asci
l1 = "NCOLS\t"+str(int(len(xi))*2)+'\n'
l2 = "NROWS\t"+str(int(len(yi))*2)+'\n'
l3 = "XLLCORNER\t"+str(int(xcor-extent))+'\n'
l4 = "YLLCORNER\t"+str(int(ycor-extent))+'\n'
l5 = "CELLSIZE\t"+str(int(cellsize))+'\n'
l6 = "NODATA_VALUE\t"+str(int(-9999.0))
header = l1+l2+l3+l4+l5+l6
np.savetxt('ascigrid.asc',finalgrid, fmt='%.4e',\
           header = header,comments='')

# then make geotif
gi_dic = {'xll':xcor-extent,'yll':ycor-extent,'dx':cellsize,'dy':cellsize,\
          'nrow':len(xi),\
          'ncol':len(yi),'proj':1,'ang':0,'crs':'rd'}

ro = rf.rasterArr(finalgrid,gi=gi_dic)

ro.write(os.path.join(tmpdir, 'output.tif'), raster_format=6)


