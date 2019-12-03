from setuptools import setup, find_packages
import os

setup(name='ee_coast',
      version='1.0',
      description="Coastal morphology analysis tools using Google Earth Engine",
      long_description="""\
...""",
      classifiers=[], # Get strings from http://pypi.python.org/pypi?%3Aaction=list_classifiers
      keywords='earth-engine landsat coast morphology',
      author='Josh Friedman',
      author_email='josh.friedman@deltares.nl',
      url='http://deltares.nl',
      license='LGPL',
      packages=find_packages(exclude=['ez_setup', 'examples', 'tests']),
      include_package_data=True,
      zip_safe=True,
      cmdclass = {},
      install_requires=[
          'simplekml', 'pykml',# -*- Extra requirements: -*-
      ]
      )


