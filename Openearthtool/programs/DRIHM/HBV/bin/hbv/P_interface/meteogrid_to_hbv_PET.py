import scipy
from scipy import interpolate
import netCDF4
import numpy as np
from datetime import *
import calendar
import shutil
import os
import math

print ('Interpolation of the NWP file')
fajla=open('river_case/river_hbv/staticmaps/map.asc','r')

for line in fajla:
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
      
pet_arr=[]
long_arr=[]
time_arr=[]
pi=3.14159


# read coordinates and cell size for hydrological model from map.asc
#-----------------------------------------------------------------------------------------------------------
xul=float(xl)
yul=float(yl+nr*cs)
xlr=float(xl+nc*cs)
ylr=float(yl)
   
xi=np.arange(xl,xlr-cs,cs)
print 'xi', np.shape(xi)
yi=np.arange(yul,yl,-cs)
print 'yi', np.shape(yi)

x=np.arange(xl,xlr-cs,cs)
y=np.arange(yl,yul,cs)

    
nlats=nr
nlons=nc

# open the .nc file and read variables
#-----------------------------------------------------------------------------------------------------------
file_name='river_case/river_hbv/meteo_prepare/NWP_file.nc'
fncfile = netCDF4.Dataset(file_name, 'r')  
stimes=fncfile.variables['time']
dat=fncfile.variables['time_bnds']

for var in  fncfile.variables.values():
  for attr in var.ncattrs():
    if str(attr)=='datestart':
      print '<<attr name>> =', attr
      date_start=str(getattr(var,attr))
      print date_start
    if str(attr)=='dateend':
      print '<<attr name>> =', attr
      date_end=str(getattr(var,attr))
      print date_end  
vreme=stimes[:] 
ntimes=int(len(stimes))-1
print 'ntimes',ntimes

t2m=fncfile.variables['air_temperature']
prec=fncfile.variables['lwe_thickness_of_precipitation_amount']
lat=fncfile.variables['lat']
lon=fncfile.variables['lon']

latitude=lat[:,0]
longitude=lon[0,:]

lon_wrf=int(len(longitude))
lat_wrf=int(len(latitude))


# open the new.nc file for writing
#-----------------------------------------------------------------------------------------------------------
nc_file_name='river_case/river_hbv/meteo_prepare/mapstackPrecipitation.nc'
ncfile = netCDF4.Dataset(nc_file_name, 'w',format='NETCDF3_CLASSIC')

time_dim=ncfile.createDimension('time',ntimes+1)  
lat_dim=ncfile.createDimension('y',nlats)        
lon_dim=ncfile.createDimension('x',nlons)

anal_time=ncfile.createVariable('analysis_time','double',())
anal_time.standard_name='forecast_reference_time'
anal_time.long_name='forecast_reference_time'
anal_time.units='minutes since 1970-01-01 00:00:00.0+0000'
anal_time._CoordinateAxisType='RunTime'

geo_system = ncfile.createVariable('crs', 'i')
geo_system.grid_mapping_name = 'latitude_longitude'
geo_system.longitude_of_prime_meridian = 0.0
geo_system.semi_major_axis = 6378137.0
geo_system.inverse_flattening = 298.257223563

lat=ncfile.createVariable('y','double',('y',))
lat.standard_name= 'latitude'
lat.long_name='y coordinate according to WGS 1984'
lat.units='degrees_north' 
lat.axis="Y"
       
lon=ncfile.createVariable('x','double',('x',))
lon.standard_name='longitude'
lon.long_name='x coordinate according to WGS 1984'
lon.units='degrees_east' 
lon.axis="X"  


time = ncfile.createVariable('time', 'double', ('time',))
time.standard_name='time'
time.long_name='time'
time.units='minutes since 1970-01-01 00:00:00'
      
precip=ncfile.createVariable('P','float',('time','y','x'))
precip.standarad_name='precipitation'
precip.long_name='P'
precip.units='mm'
precip._FillVallue='-9999'
precip.coordinates='analysis_time'
precip.grid_mapping = 'crs'


potevap=ncfile.createVariable('PET','float',('time','y','x'))
potevap.standard_name='potential_evapotranspiration'
potevap.long_name='PET'
potevap.units='mm'
potevap._FillVallue='-9999'
potevap.coordinates='analysis_time'
potevap.grid_mapping = 'crs'
    
temp=ncfile.createVariable('TEMP','float',('time','y','x'))
temp.standard_name='2meter_temperature'
temp.long_name='TEMP'
temp.units='C' 
temp._FillVallue='-9999'
temp.coordinates='analysis_time'
temp.grid_mapping = 'crs'


# time from .nc file
#-----------------------------------------------------------------------------------------------------------
sbegin_time=date_start
print sbegin_time
send_time=date_end
print send_time


# dates from .nc file
#-----------------------------------------------------------------------------------------------------------
try:
  sbegin_date=datetime.strptime(sbegin_time,'%Y-%m-%d %H:%M:%S')
except ValueError:
  sbegin_date=datetime.strptime(sbegin_time,'%Y-%m-%d %H:%M')
s_begin=sbegin_date.timetuple()
hour_now=s_begin.tm_hour
hours_begin=calendar.timegm(s_begin)/60
print 'pocetak_min', hours_begin

try:
  send_date=datetime.strptime(send_time,'%Y-%m-%d %H:%M:%S')
except ValueError:
  send_date=datetime.strptime(send_time,'%Y-%m-%d %H:%M')
s_end=send_date.timetuple()
hours_end=calendar.timegm(s_end)/60 #pretvaram sekunde u minute
print 'kraj_min', hours_end


# calculation of PET
#-----------------------------------------------------------------------------------------------------------
day_now=s_begin.tm_yday

razlika=int((hours_end-hours_begin)/60)
print 'razlika',razlika


for hour in range(0,razlika+1,1):
  #print hour
  hour_hour=hour_now+hour
  #print 'hour_hour', hour_hour
  if hour_hour>0 and hour_hour % 24==0:
    hour_hour=hour_hour-24
    day_now=day_now+1
    #print 'day_now',day_now
  
  s=0
  for coordinate in latitude: 
    #print 'coordinate', coordinate
    lat_radian=math.radians(float(coordinate))   
    declination=23.45*math.sin(0.98630137*(day_now-81)) 
    declination_rad=math.radians(declination)
    sunset_hangle=math.acos(-math.tan(declination_rad)*math.tan(lat_radian))
    n=(24/pi)*sunset_hangle
    hourly_temp=t2m[hour,0,s,:] # 1D niz-temperatura za fiksiranu latitudu, menja se longituda
    #print 'hourly_temp', hourly_temp
        
    for tem in hourly_temp:
      
      satur_vapor_press=6.108*math.pow(10,7.5*(tem-273.1)/(tem-273.1+237.3))# hPa 1D niz pritisak zas. pare po long
      pet=29.8*n*satur_vapor_press/10/(tem+273.2)/24 # mm/h 1D niz pet za konst latitudu, menja se longituda
      pet_arr.append(pet) #pakovanje liste za jednu latitudu
      

    pet_np_arr=np.array(pet_arr) #lista za jednu latitudu ide u niz
    pet_np_arr=np.transpose(pet_np_arr)
    pet_arr[:]=[]
    s=s+1 
    long_arr.append(pet_np_arr)
  print hour
  nesto=np.array(long_arr)
  print 'nesto',np.shape(nesto)
  time_arr.append(long_arr)

  neko=np.array(time_arr)
  print np.shape(neko)
  long_arr[:]=[]
  #a=raw_input()

# fill variables with data
anal_time=hours_begin
time[:]=np.arange(hours_begin,hours_end+60,60) 
lat[:]=yi
lon[:]=x

x=np.arange(xl,xlr-cs,cs)
print 'x', np.shape(xi)
y=np.arange(yl,yul,cs)
print 'y', np.shape(yi)

for t in range(0,razlika+1,1):

  print 'vreme za interpolaciju', t 
  temperature=t2m[t,0,:,:]
  #print 'temp_shape',np.shape(temperature)
  precipitation=prec[t,:,:]*1000
  potevapotr=neko[t,:,:]
    
  # interpolation 2D scipy    
  temp_inter=scipy.interpolate.RectBivariateSpline(latitude,longitude,temperature,kx=3,ky=3,s=0)
  prec_inter=scipy.interpolate.RectBivariateSpline(latitude,longitude,precipitation,kx=3,ky=3,s=0) 
  pevap_inter=scipy.interpolate.RectBivariateSpline(latitude,longitude,potevapotr,kx=3,ky=3,s=0) 
  
   
  new_temp=temp_inter(y,x)
  new_prec=prec_inter(y,x)
  new_epot=pevap_inter(y,x)

   
  # packing to the neCDF file   
  precip[t,:,:]=new_prec
  temp[t,:,:]=new_temp
  potevap[t,:,:]=new_epot

#close the file
ncfile.close()

print('End of the interpolation')

