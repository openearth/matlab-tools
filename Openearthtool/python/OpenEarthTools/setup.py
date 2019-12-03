from setuptools import setup, find_packages
# import sys, os

version = '0.1.1'


setup(name='OpenEarthTools',
      version=version,
      description="OpenEarth Python utilities",
      long_description="""\
This is the package that contains basic python utilities.""",
      classifiers=[],  # Get strings from pypi.org
      keywords='gis openearth coastal marine',
      author='Fedor Baart',
      author_email='f.baart@tudelft.nl',
      url='http://www.openearth.eu',
      license='GPL',
      packages=find_packages(exclude=['ez_setup', 'examples', 'tests']),
      include_package_data=False,
      zip_safe=False,
      install_requires=[
          # -*- Extra requirements: -*-
      ],
      entry_points="""
      # -*- Entry points: -*-
      """,
      )
