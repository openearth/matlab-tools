#===============================================
#Tide Prediction WPS Function (from OpenEarth)
#===============================================
#JFriedman
#June 19/2015
#===============================================

#import all necessary packages
#=============================
import shapely.geometry # for geometry/wkt format
import owslib.wps # the service
import datetime

#get astronomical tide from location + time
#==========================================
def extractTide(lon = 3, lat = 53, imdate = datetime.datetime.now(), dt = 2.5):

    #make sure to handle longitude when -ve (needs to be from 0 - 360)
    if lon < 0:
        lon = 360 + lon
    point = [lon,lat]
    
    #sort out the temporal extents for the request
    startdate = (imdate - datetime.timedelta(days=dt)).isoformat() 
    enddate = (imdate + datetime.timedelta(days=dt)).isoformat() 
    frequency = 'MINUTELY' #smooth data!
    
    # Open the server
    url = 'http://dtvirt5.deltares.nl/wps' #server to use
    server = owslib.wps.WebProcessingService(url) # By default it will execute a GetCapabilities invocation to the remote service (skip_caps) 

    # inputs is a list of tuples
    geom = shapely.geometry.Point(point)
    location = geom.to_wkt()
    
    # make a dict and use items
    inputs = dict(
        location=location, 
        startdate=startdate, 
        enddate=enddate, 
        frequency=frequency
        )
        
    # if this goes wrong, use verbose=True
    result = server.execute('tidal_predict', inputs=inputs.items())
    # you can also use getOutput to save to a file
    output = result.processOutputs[0] 
    
    data = output.data[0].split("\n")
    data = data[1:]
    DATE = []
    H = []
    for val in data:
        val = val.split(',')
        DATE.append(datetime.datetime.strptime(val[0],'%Y-%m-%d %H:%M:%S'))
        H.append(float(val[1]))
        
    return DATE,H