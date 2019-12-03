from pcraster import *
from pcraster.framework import *
import pcraster as fp
import pcrut
import numpy as np
import ConfigParser
import scipy.io.netcdf as nc
import os


class Obs_to_netcdf(DynamicModel):
  
  def __init__(self,cloneMap):
    DynamicModel.__init__(self)
    setclone(cloneMap)
    
  def initial(self):
    
    os.chdir('work/river_case/river_hbv/staticmaps/') 
    os.system('map2asc -a catchment_cut.map map.asc')
    os.chdir('../../../..')

    for line in open('work/river_case/river_hbv/staticmaps/map.asc'):

      if 'NCOLS' in line:
        ncol=line.split(' ')
        nc=float(ncol[1].strip())

      if 'NROWS' in line:
        nrow=line.split(' ')
        nr=float(nrow[1].strip())
      
      if 'XLLCORNER' in line:
        xll=line.split(' ')
        xl=float(xll[1].strip())

      if 'YLLCORNER' in line:
        yll=line.split(' ')
        yl=float(yll[1].strip())

      if 'CELLSIZE' in line:
        cell_size=line.split(' ')
        cs=float(cell_size[1].strip())

    

    # read coordinates and cell size for hydrological model from map.asc
    #-----------------------------------------------------------------------------------------------------------
    self.xul=xl
    print 'xul',xul
    self.yul=yl+nr*cs
    print 'yul',yul
    self.xlr=xl+nc*cs
    print 'xlr',xlr
    self.ylr=yl
    print 'ylr',ylr

    
    # read number of time steps from .tss file
    self.file_t='work/river_case/river_hbv/meteo_prepare/Tcorr.tss'
    a=open(self.file_t,'rb')
    lines = a.readlines()
    last_line = lines[-1]
    last_line=last_line.split()
    self.vreme=int(last_line[0])
    print self.vreme
        
    self.gaugesMap=fp.readmap('work/river_case/river_hbv/staticmaps/wflow_mgauges.map')
    self.interpolMethod='inv'
    
    self.cell_size=cs
    
    self.nlats=nr
    print self.nlats
    self.nlons=nc
    print self.nlons
    self.t= 0 
    self.ntimes=self.vreme
    
    # open the .nc file for writing
    self.file_nc='work/river_case/river_hbv/meteo_prepare/mapstackPrecipitation_cf.nc'
    self.ncfile = nc.netcdf_file(self.file_nc, 'w') 
    
    # create main attributes
    self.ncfile.Conventions = 'test'
    self.ncfile.title = 'Interpolated observations over the catchment'
    self.ncfile.institution = 'Republic Hydrometeorologic Service of Serbia - www.hidmet.gov.rs'
    self.ncfile.history = 'DRIHM project'
    self.ncfile.references = 'http://cf-pcmdi.llnl.gov/ ; http://cf-pcmdi.llnl.gov/documents/cf-standard-names/ecmwf-grib-mapping'
    self.ncfile.comment = 'Author: Marija Ivkovic'
    self.ncfile.email = 'marija.ivkovic@hidmet.gov.rs'

    # create a dimensions
    lat_dim=self.ncfile.createDimension('y',self.nlats)        
    lon_dim=self.ncfile.createDimension('x',self.nlons)        
    time_dim=self.ncfile.createDimension('t', self.vreme)  
    lev_dim=self.ncfile.createDimension('lev', 1)  
    
    # create variables
    time = self.ncfile.createVariable('t', 'double', ('t',))
    time.standard_name='time'
    time.long_name='time'
    time.units='hours'
    
 
    lat=self.ncfile.createVariable('lat','double',('y','x'))
    lat.standard_name='latitude'
    lat.long_name='latitude coordinate'
    lat.units='degrees_north' 
       

    lon=self.ncfile.createVariable('lon','double',('y','x'))
    lon.standard_name='longitude'
    lon.long_name='longitude coordinate'
    lon.units='degrees_east' 
      
    
    self.precip=self.ncfile.createVariable('lwe_thickness_of_precipitation_amount','float',('t','lev','y','x'))
    self.precip.standard_name='lwe_thickness_of_precipitation_amount'
    self.precip.long_name='lwe_thickness_of_precipitation_amount'
    self.precip.units='mm'
    self.precip.coordinates = 'lon lat'
    self.precip.grid_mapping = 'crs'
    

    self.temp=self.ncfile.createVariable('air_temperature','float',('t','lev','y','x'))
    self.temp.standard_name='air_temperature'
    self.temp.long_name='air_temperature'
    self.temp.units='celsius degrees' 
    self.temp.coordinates = 'lon lat'
    self.temp.grid_mapping = 'crs'

    self.geosystem = self.ncfile.createVariable('crs','float',())
    self.geosystem.grid_mapping_name = 'latitude_longitude'
    self.geosystem.longitude_of_prime_meridian = 0.0
    self.geosystem.semi_major_axis = 6378137.0
    self.geosystem.inverse_flattening = 298.257223563
    self.geosystem.epsg_code = '4326'

    # fill variables with data
    lats=np.arange(self.ylr,self.yul,self.cell_size)
    lons=np.arange(self.xul,self.xlr,self.cell_size)
    latlat,lonslons=np.meshgrid(lats,lons)
    latlat=latlat.transpose()
    lonslons=lonslons.transpose()
    lat[:,:]=latlat
    lon[:,:]=lonslons
    
    self.time=np.arange(0,self.ntimes,1) 
    time[:]=self.time
    
    
  def dynamic(self):

    self.precipTss='work/river_case/river_hbv/meteo_prepare/Pcorr.tss'
    self.precipitation=fp.timeinputscalar(self.precipTss,self.gaugesMap)
    self.precipitation=pcrut.interpolategauges(self.precipitation,self.interpolMethod)
    self.save_to='work/'+str(self.cn)+'_case/'+str(self.cn)+'_hbv/meteo_prepare/Temp/precip'
    self.report(self.precipitation,self.save_to)
    
    self.tempTss='work/river_case/river_hbv/meteo_prepare/Tcorr.tss'
    self.temperature=fp.timeinputscalar(self.tempTss,self.gaugesMap)
    self.temperature=pcrut.interpolategauges(self.temperature,self.interpolMethod)
    self.save_to='work/'+str(self.cn)+'_case/'+str(self.cn)+'_hbv/meteo_prepare/Temp/temp'
    self.report(self.temperature,self.save_to)
  
    self.pmap2numpy=pcr2numpy(self.precipitation,-9999)
    self.tmap2numpy=pcr2numpy(self.temperature,-9999)
        
    self.precip[self.t,0,:,:]=self.pmap2numpy
    self.temp[self.t,0,:,:]=self.tmap2numpy
    
    self.t=self.t+1

file_open='work/river_case/river_hbv/meteo_prepare/Tcorr.tss'
a=open(file_open,'r')
lines = a.readlines()
last_line = lines[-1]
last_line=last_line.split()
vreme=int(last_line[0]) 

       
s=vreme
k=1


myModel = Obs_to_netcdf('work/river_case/river_hbv/staticmaps/catchment_cut.map')
dynModelFw = DynamicFramework(myModel,lastTimeStep=s,firstTimestep=k)
dynModelFw.run()

# close the file
#self.ncfile.close()

