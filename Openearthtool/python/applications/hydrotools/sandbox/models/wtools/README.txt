NOTE: The scripts are now hosted under the wflow repository, see:
https://github.com/openstreams/wflow/tree/master/wflow-py/Scripts/wtools_py/
https://github.com/openstreams/wflow/blob/master/wflow-py/wflow/

Once the documentation and all functionality is moved, we can remove this folder.


NOTE: this tool only works in combination with a QGIS installation and the windows path variable set to the following processes:
- gdalwarp
- gdal_translate
- gdal_rasterize

Please try to run these processes on the command-line before running the tools

Executables are stored in the wtools folder

test_citarum can be used to check if WTools works on your computer:
1. test_citarum\1A_CatchRiver_DEMonly.bat can be used to see if you have any problems running the executables
2. to generate a (coarse) WFlow model for the Citarum, use available batches in the following order:
test_citarum\
	1C_CatchRiver_DEM_points_lines_snapped.bat
	2_CreateGrid.bat
	3B_StaticMaps_LandUse.bat
	
Read the documentation for more details