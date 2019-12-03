from pywps.Process import WPSProcess  
from types import FloatType, StringType
#import applications.gwdlr.gwdlr

 
class Process(WPSProcess):
     def __init__(self):
         
         WPSProcess.__init__(self,
              identifier       = "gwdlr_get_river_profiles", 
              title            = "This process returns shape files with river" +
                            "profiles and locations from the gwdlr database",
              version          = "1",
              storeSupported   = "false",
              statusSupported  = "false",
              abstract         = "Pilot process SO Global Data")
              
         self.shp_network_name  = self.addLiteralInput(identifier  = "shp_network_name",
                                            title       = "Filename for shapefile with river network output",
                                            type        = StringType)
 
         self.shp_profile_name  = self.addLiteralInput(identifier  = "shp_profile_name",
                                            title       = "Filename for shapefile with river profile output",
                                            type        = StringType)
 
         self.nc_file  = self.addLiteralInput(identifier  = "nc_file",
                                            title       = "Netcdf file (url) containing gwdlr data",
                                            type        = StringType)

         self.lat_min  = self.addLiteralInput(identifier  = "lat_min",
                                            title       = "Minimum latitude of bounding box",
                                            type        = FloatType)
                                            
         self.lat_max  = self.addLiteralInput(identifier  = "lat_max",
                                            title       = "Maximum latitude of bounding box",
                                            type        = FloatType)

         self.lon_min  = self.addLiteralInput(identifier  = "lon_min",
                                            title       = "Minimum longitude of bounding box",
                                            type        = FloatType)

         self.lon_max  = self.addLiteralInput(identifier  = "lon_max",
                                            title       = "Maximum longitude of bounding box",
                                            type        = FloatType)                                            

         self.min_catch  = self.addLiteralInput(identifier  = "min_catch",
                                            title       = "Minimum upstream area of river catchment to be taken into account",
                                            type        = FloatType)
 
         self.min_upstream  = self.addLiteralInput(identifier  = "min_upstream",
                                            title       = "Minimum upstream area to take a pixel into account",
                                            type        = FloatType) 

         self.min_width  = self.addLiteralInput(identifier  = "min_width",
                                            title       = "Minimum river width to be taken into account",
                                            type        = FloatType) 

         self.max_prof_distance  = self.addLiteralInput(identifier  = "max_prof_distance",
                                            title       = "Maximum profile distance",
                                            type        = FloatType) 
      
         self.result_network = self.addComplexOutput(identifier = "shp_network",
                                            title = "Shapefile",
                                            formats = [{"mimeType":"image/shp"}])

         self.result_profile = self.addComplexOutput(identifier = "shp_profile",
                                            title = "Calculated water level for requested location and date",
                                            formats = [{"mimeType":"image/shp"}])    
     
     def execute(self):
         # Input parameters
         shp_network = self.shp_network_name.getValue()
         shp_profile = self.shp_profile_name.getValue()
         nc_file = self.nc_file.getValue()
         lat_min = self.lat_min.getValue()
         lat_max = self.lat_max.getValue()
         lon_min = self.lon_min.getValue()
         lon_max = self.lon_max.getValue()
         min_catch = self.lat_min.getValue()
         min_upstream = self.lat_max.getValue()
         min_width = self.lon_min.getValue()
         max_prof_distance = self.lon_max.getValue()
 
         # Process
         gwdlr.main(shp_network,shp_profile,nc_file,lat_min,lat_max,lon_min,lon_max,min_catch,min_upstream,min_width,max_prof_distance)
 
         # Output
         self.result_network.setValue(result1)
         self.result_profile.setValue(result2)
         return