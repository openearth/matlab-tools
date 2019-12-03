This script download the latest GPM grids. It was made as a practical exercise, so can be improved a lot, but works well.

The script downloads different versions (eg Early, Late, Final), which need to be configured in the settings file. For each type you can define the search period (days before now) and a prefix for the output files.

The output files are ArcInfo ASC files, each for one timestep. Why such an old format? Because it is easy to write if you're not very familiar with Python. Writing to NetCDF would be a great improvement.

The script is intended to be run by a scheduler. Every time it runs it compares the data in the catalog with the URLS already downloaded (as registered in the filelistN.txt files). Only new files are downloaded to the configured output folders.


