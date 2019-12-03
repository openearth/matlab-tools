
https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/delft3dfm/convert_to_dflowfm

These Python scripts are work in progress. In case of problems/questions: contact adri.mourits@deltares.nl

These Python scripts are part of the RegionalHydrologyUrban(RHU) project.

USAGE:
Copy the script "convert_from_SOBEK3.bat" into an empty directory. Follow the instructions in that script.

EPSG:
The EPSG code is hardcoded to be zero (0). RD (28992) is implemented as well. To switch it on:
Open file "writer_dflowfm/UgridWriter.py" in an editor, line 51:
        epsgcode = 0
should be replaced by:
        epsgcode = 28992

APPEND TO 2DMODEL_net.nc
Save you 2d model with cell info in the interacter
Copy writer_dflowfm\UgridWriter.py to writer_dflowfm\UgridWriter-copy.py
Rename writer_dflowfm\UgridWriter_append.py to writer_dflowfm\UgridWriter.py
Go to line 40  "ncfile = Dataset(r'd:\WRIJ_DEM\FM\1D2D_model_final\network\input\UGr7_waterways_clipped_v9_cellinfo_net.nc', 'a', format=outformat)"
and change to "directory\UG+yourgridname_net.nc"


PYTHON
The following installation set seems to work properly:
https://www.anaconda.com/distribution/ Python 3.7
conda install gdal
conda install netCDF4


adri.mourits@deltares.nl
