from geoserver.catalog import Catalog
import os
import shutil

# Read configuration
from config import *
conf = CONF(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.txt')).readConfig()

# Clean all layers from a geoserver workspace
def cleanupGeoserver(host, user, passwd, workspace):
    # Connection details
    cat=Catalog(host + '/rest', username=user, password=passwd)
    
    # Then, remove layers and stores
    layers = cat.get_layers(workspace)
    for lay in layers:          
        if workspace in lay.name:                     
            # Layer
            try:
                print('Removing layer -> ' + lay.name)                        
                cat.delete(lay)
                cat.reload()            
            except Exception as e:
                print 'Coud not delete layer: '+lay.name
                print e
            
            # Store delete
            lt = lay.name.split(':')
            storename = lt[1] + '_ds'
   
            print('Removing store -> ' + storename)
            st=cat.get_store(storename)
            cat.delete(st)
            cat.reload()
 
    return

# Clean all files from a temporal directory
def cleanupFilesDirectory(direc, exclude_ext='.txt'):
    for root, dirs, files in os.walk(direc, topdown=False):        
        for name in files:  
            path=os.path.join(root, name)         
            if name.endswith(exclude_ext):
                print('Skipping -> ' + path)
            else:                
                print('Removing -> ' + path)
                try:
                    os.unlink(path)
                except:
                    print('Could not remove -> ' + path)
                    pass
    return

if __name__ == "__main__":      
    # Read configuration
    conf = CONF(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.txt')).readConfig()
    cleanupFilesDirectory(conf['TEMP_DIR'])
    cleanupGeoserver(conf['GEOSERVER_HOST'], conf['GEOSERVER_USER'], conf['GEOSERVER_PASS'], conf['WORKSPACE_TEMP'])    
    print 'Finished Cleaning'
