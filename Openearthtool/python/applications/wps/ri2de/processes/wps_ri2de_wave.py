# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#      Lilia Angelova
#      Lilia.Angelova@deltares.nl
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/ri2de/processes/wps_ri2de_calc.py $
# $Keywords: $

# PyWPS

from pywps import Process, Format, FORMATS
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import ComplexOutput
from pywps.app.Common import Metadata

# other
import json
import geojson
import geopandas as gpd
import numpy as np
from osgeo import osr
from osgeo import gdalconst
import os
import xarray as xr
import sys
import time
from scipy import ndimage
from rasterstats import zonal_stats
import rasterio

# local
from processes.utils import *
from processes.utils_raster import *
from processes.utils_vector import *
from processes.utils_geoserver import *

class WpsRi2deWave(Process):

	def __init__(self):
		# Input [in json format ]
		inputs = [LiteralInput('roads_identifier', 'Identifier of the road selection given by the wps_ri2de_roads function', data_type='string'),
				  ComplexInput('layers_setup', 'List of layers/weights to calculate with',
		                       [Format('application/json')],
		                       abstract="Complex input abstract", )]

		# Output [in json format]
		outputs = [ComplexOutput('output_json',
		                         'Ri2DE calculation given a set of susceptibility layers and weights',
		                         supported_formats=[Format('application/json')])]

		super(WpsRi2deWave, self).__init__(
		    self._handler,
		    identifier='ri2de_wave',
		    version='1.0',
		    title='backend process for the RI2DE tool project calculating extreme water level vulnerability',
		    abstract='This process performs the main calculation on affected roads from extreme water levels\
		     and sends back a JSON reply wrapped in the xml/wps format with the wmslayer to show',
		    profile='',
		    metadata=[Metadata('WpsRi2deWave'), Metadata('Ri2DE/calculation')],
		    inputs=inputs,
		    outputs=outputs,
		    store_supported=False,
		    status_supported=False
		)


	def _handler(self, request, response):

		try:
			# Read configuration
			cf = read_config()

			# Read input
			layers_jsonstr, layer_info, roadsId = read_input(request)

			# Get roads GeoJSON and exact bounds
			geoFname = get_roads(cf, roadsId)
			s,w,n,e = get_roads_envelope_geojson(geoFname)


			# Create Gtiff [calculation]
			outfname = 'vulnerability_{}.tif'.format(int(1000000*time.time()))
			vulnfname = os.path.join(os.path.join(cf.get('Settings', 'tmpdir_data'), outfname))
			# vulnerability_calc(calc, vulnfname)

			# roads_file = r"D:\RI2DE\tmp\roads_1572870910620110.geojson"
			# roads_poly = r"D:\RI2DE\tmp\roads_1572870910620110.geojson"
			waves_file = "opt/data/diva_worldwaves.shp"

			#read files and define data frames
			roads_lines = gpd.read_file(geoFname)
			wv = gpd.read_file(waves_file)
			waves = wv[['hs_1_m','geometry']]

			#derive bounding box of roads
			roads_bbox = roads_lines.envelope
			extend = roads_bbox.bounds
			xmin = extend.iloc[0][0]
			ymin = extend.iloc[0][1]
			xmax = extend.iloc[0][2]
			ymax = extend.iloc[0][3]

			#centroid of the bounding box
			roads_bbox_centr = roads_bbox.centroid
			#calculate distances between centroid point and wave points
			distances = [roads_bbox_centr.distance(wave.geometry) for id,wave in waves.iterrows()]
			#index of the closest wave point
			closest_wave = waves.loc[np.argmin(distances)]
			closest_wave_height = closest_wave[0]

			gebco_bbox_xmin = roads_bbox_centr.x[0] - 0.5
			gebco_bbox_xmax = roads_bbox_centr.x[0] + 0.5
			gebco_bbox_ymin = roads_bbox_centr.y[0] - 0.5
			gebco_bbox_ymax = roads_bbox_centr.y[0] + 0.5

			bboxrdnew = (gebco_bbox_xmin,gebco_bbox_ymin,gebco_bbox_xmax,gebco_bbox_ymax)

			s,w,n,e = gebco_bbox_xmin, gebco_bbox_ymin, gebco_bbox_xmax, gebco_bbox_ymax
			#download dem files from geoserver
			# demfname = os.path.join(r"D:\RI2DE\data", "gebco_" + "{}".format(int(time.time())) + ".tif")
			fname = "gebco_" + "{}".format(int(time.time())) + ".tif"
			demfname = os.path.join(os.path.join(cf.get('Settings', 'tmpdir_data'), outfname))

			cut_wcs(s,w,n,e,  "Global_Base_Maps:SRTM30_GEBCO", "https://fast.openearth.eu/geoserver/ows?", demfname)

			#get affine transformations for the zonal_stats
			with rasterio.open(demfname) as src:
			    affine = src.transform

			gebco_array = xr.open_rasterio(demfname)
			#make it 2d array (band is not needed)
			gebco_array = gebco_array.drop('band').squeeze()
			#filter on areas lower than the wave height
			lower_than_wave = xr.where(gebco_array.values < closest_wave_height, gebco_array.values, np.nan)

			result_gebco = gebco_array.copy()
			result_gebco.values = lower_than_wave
			result_gebco = result_gebco.fillna(-999)
			#convert to 1 - areas lower than WH and 0 - areas higher
			binary_elevation = xr.where(result_gebco.values > -999, 1, 0)

			if np.any(result_gebco.values!=-999) == False:  #in this case we don't have areas lower than the projected wave thus no vulnerability
			    print("No affected areas")
			    #TODO Here we have to return all roads as not affected

			else:
			    #Labelling algoritm defining connected components
			    #run the labelling algorithm on that part and extract the connected component that intersects with the seed points
			    print("Labelling connected componenets.")
			    r=2
			    conn=1
			    s = ndimage.generate_binary_structure(r,conn)
			    #labelling connected components
			    labelled_array,num_features = ndimage.label(binary_elevation,structure=s,output=None)
			    labelled_data = result_gebco.copy()
			    labelled_data.values = labelled_array
			    labelled_data.plot()

			    #sample the labelled raster at the wave point thus fiding the connected component (lower land around the wave)
			    zonal_stats_result = zonal_stats(closest_wave.geometry, labelled_data.values, affine=affine)
			    connected_component = zonal_stats_result[0]['max']
			    #extract the connected component from the dem
			    gebco_low_areas = xr.where(labelled_data == connected_component, labelled_data, np.nan)

			    cf=''
			    # apply_road_mask(cf,'D:\RI2DE\data\gebco_low_areas_sliced.tif', roads_file, 'D:\RI2DE\data')
				apply_road_mask(cf, vulnfname, geoFname, self.workdir)

			    #intersect the dem raster with the roads and for the cells that are "shared" there is hazard, all others = 0




            # Apply mask
			# apply_road_mask(cf, vulnfname, geoFname, self.workdir)

			# Upload to GeoServer to TEMP workspace
			layername = os.path.basename(vulnfname).replace('.tif', '')
			wmslayer = geoserver_upload_gtif(cf, layername, vulnfname)

			# Set output
			response.outputs['output_json'].data = write_output(cf, wmslayer)

		except Exception as e:
			res = { 'errMsg' : 'ERROR: {}'.format(e) }
			response.outputs['output_json'].data = json.dumps(res)

		return response
