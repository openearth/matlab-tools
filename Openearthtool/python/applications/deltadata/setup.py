import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
README = open(os.path.join(here, 'README.txt')).read()
CHANGES = open(os.path.join(here, 'CHANGES.txt')).read()

requires = [
    "Akhet",
    'pyramid',
    'pyramid_debugtoolbar',
    "pyramid_beaker",
    "pyramid_mailer",
    "pyramid_handlers",
    "WebError",
    'waitress',
    "numpy",
    "matplotlib",
    "pyproj",
    "shapely",
    "netCDF4",
    "webtest",
    "coverage",
    "nose"
    ]

setup(name='deltadata',
      version='0.0',
      description="A server that provides a layer showing information about water related safety. ",
      long_description=README + '\n\n' +  CHANGES,
      classifiers=[
        "Programming Language :: Python",
        "Framework :: Pyramid",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
        ],
      author='Fedor Baart',
      author_email='f.baart@tudelft.nl',
      url='http://www.openearth.eu',
      keywords='web pyramid coast',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      install_requires=requires,
      tests_require=requires,
      test_suite="deltadata",
      entry_points = """\
      [paste.app_factory]
      main = deltadata:main
      """,
      )

