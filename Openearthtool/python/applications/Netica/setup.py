import os
from setuptools import setup, find_packages

# Utility function to read the README file.
# Used for the long_description.  It's nice, because now 1) we have a top level
# README file and 2) it's easier to type in the README file than to put a raw
# string in below ...
def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

setup(
    name = "Netica",
    version = "0.0.1",
    author = "Kees den Heijer",
    author_email = "C.denheijer@tudelft.nl",
    description = ("Python wrapper for Netica C API"),
    license = "GPL",
    keywords = "Netica, Bayesian Network",
    packages = find_packages(),
    install_requires = ["logging", "ctypes", "numpy"],
    long_description = read('README'),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Environment :: Console",
        "Intended Audience :: Developers",
        "Topic :: Text Processing :: Markup :: LaTeX",
        "Natural Language :: English",
        "Operating System :: OS Independent",
        "Programming Language :: Python",
        "License :: General Public License (GPL)",
    ],
) 