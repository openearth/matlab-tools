import os
try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup
from setuptools import find_packages
here = os.path.abspath(os.path.dirname(__file__))

README = open(os.path.join(here, 'README.txt')).read()
CHANGES = open(os.path.join(here, 'CHANGES.txt')).read()

requires = [
    'basemap',
    'netCDF4',
    'pandas',
    'PyWavelets',
    'numpy',
    'matplotlib',
    'gdal',
    'fiona']

print ('The following subpackages are installed:')
print find_packages(exclude=['tests*', 'sandbox', 'notebooks'])
#setup(**config)
setup(name='Hydrotools',
    description='Deltares Hydrotools',
    author='',
    url='',
    keywords='hydrology statistics meteorology gis',
    include_package_data=True,
    install_requires=requires,
    download_url='',
    author_email='',
    version='0.1',
    packages=find_packages(exclude=['tests*', 'sandbox', 'notebooks']) # ['hydrotools', 'hydrotools.gis', 'hydrotools.models'],
    )