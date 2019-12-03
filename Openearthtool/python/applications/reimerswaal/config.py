import ConfigParser

class CONF():
    def __init__(self, conf_file_path): 
        self.CONFIG_FILE = conf_file_path

    # Read configuration from file
    def readConfig(self):
        cf = ConfigParser.RawConfigParser()  
        cf.read(self.CONFIG_FILE)
        conf_dict = dict()
        # Geoserver
        conf_dict['GEOSERVER_HOST'] = cf.get('GeoServer', 'host')
        conf_dict['GEOSERVER_WMS'] = cf.get('GeoServer', 'ows_wms')
        conf_dict['GEOSERVER_USER'] = cf.get('GeoServer', 'user')
        conf_dict['GEOSERVER_PASS'] = cf.get('GeoServer', 'pass')
        conf_dict['WORKSPACE_DATA'] = cf.get('GeoServer', 'workspace_data')
        conf_dict['WORKSPACE_TEMP'] = cf.get('GeoServer', 'workspace_temp')
        # Data
        conf_dict['DATA_DIR'] = cf.get('Data', 'original_rasters')
        conf_dict['DATA_RESAMP_DIR'] = cf.get('Data', 'resampled_rasters')
        conf_dict['TEMP_DIR'] = cf.get('Data', 'temp_rasters')

        return conf_dict    