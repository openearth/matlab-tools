"""
Setup script
"""
import os
import babel
import subprocess
from setuptools import setup, find_packages

HERE = os.path.abspath(os.path.dirname(__file__))
README = open(os.path.join(HERE, 'README.txt')).read()
CHANGES = open(os.path.join(HERE, 'CHANGES.txt')).read()

requires = [
    'pyramid',
    'pyramid_debugtoolbar',
    'pyramid_mako',
    'pyramid_beaker',
    'waitress',
    'pandas',
    'rpy2',
    'Babel',
    'xlwt',
    'matplotlib',
    'ipython',
    'netCDF4',
    'scipy'
    ]


subprocess.call(['make', '-C', 'sealevel/static/data'])

setup(name='sealevel',
      version='0.0',
      description='sealevel',
      long_description=README + '\n\n' + CHANGES,
      classifiers=[
        "Programming Language :: Python",
        "Framework :: Pyramid",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
        ],
      author='',
      author_email='',
      url='',
      message_extractors = {'sealevel': [
          ('**.py', 'python', None),
          ('templates/**.html', 'mako', None),
          ('templates/**.mak', 'mako', None),
          ('static/**', 'ignore', None)]},
      keywords='web pyramid',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      install_requires=requires,
      tests_require=requires,
      test_suite="sealevel",
      entry_points="""\
      [paste.app_factory]
      main = sealevel:main
      """,
      )
