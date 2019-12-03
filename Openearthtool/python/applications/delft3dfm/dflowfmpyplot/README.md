dflowfmpyplot
==============

A Python API to utilize data written using the netCDF unstructured grid conventions
[(UGRID)](https://github.com/ugrid-conventions/ugrid-conventions) for Delft3D-FM (dflowfm)


Note:
Only python3 is supported


Background
----------

This is an attmpt to offer Python visualisation solutions for processing Delft3D FM result files

Status
------

The package currently only covers triangular mesh grids, due to its dependence on the pyugrid package.
When support for other grids will be added to pyugrid, other shapes will be supported by this package as well.

It has limited functionality for manipulating and visualizing the data. It provides the ability to read and write
netCDF files, plot HIS data and MAP (only UGRID based v1.1.191 and later) data.
It also provides capability to plot the variables in a similar way the matlab based Quickplot tool does, but currently,
there is no GUI avialable. Please look at the unit test examples and at the examples in the main body of the
read_nc_map.py and read_nc_his.py files..


Development is managed on the Open Earth Tools svn server:
https://svn.oss.deltares.nl/repos/openearthtools/trunk/

The application after checkout will be found in:
/trunk/python/applications/delft3dfm/dflowfmpyplot

More details can be read on the Open Earth Tools page:
https://publicwiki.deltares.nl/display/OET/Join+OpenEarth


Dependencies

https://github.com/SciTools/cartopy You can install it using pip. pip3 install cartopy
https://github.com/pyugrid/pyugrid/ Follow the instructions to install pugrid from their webpage

Test your installation and examples
-----------------------------------

$cd <path/to>/OpenEarthTools/trunk/python/applications/delft3dfm/dflowfmpyplot/pyd3dfm
$python3 read_nc_his.py
$python3 read_nc_map.py

You can also run the unit tests in the tests directory:

python3 -m unittest test_ncHisD3dfm.py
python3 -m unittest test_ncMapD3dfm.py

For convenience there are 2 scripts in the test directory that help with running the unint tests:
 test_his.sh and test_map.sh