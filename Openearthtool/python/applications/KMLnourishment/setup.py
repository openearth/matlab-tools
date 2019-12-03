# -*- coding: utf-8 -*-
"""
$Id: setup.py 8439 2013-04-12 10:40:43Z heijer $
$Date: 2013-04-12 03:40:43 -0700 (Fri, 12 Apr 2013) $
$Author: heijer $
$Revision: 8439 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/KMLnourishment/setup.py $
"""

import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
README = open(os.path.join(here, 'README.txt')).read()
CHANGES = open(os.path.join(here, 'CHANGES.txt')).read()

requires = [
    'pyramid',
    'pyramid_debugtoolbar',
    'waitress',
	'netCDF4',
	'numpy',
	'simplekml',
    ]

setup(name='KMLnourishment',
      version='0.0',
      description='KMLnourishment',
      long_description=README + '\n\n' + CHANGES,
      classifiers=[
        "Programming Language :: Python",
        "Framework :: Pyramid",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
        ],
      author='Kees den Heijer and Giorgio Santinelli',
      author_email='Kees.denHeijer@deltares.nl / Giorgio.Santinelli@deltares.nl',
      url='',
      keywords='web pyramid pylons',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      install_requires=requires,
      tests_require=requires,
      test_suite="kmlnourishment",
      entry_points="""\
      [paste.app_factory]
      main = kmlnourishment:main
      """,
      )
