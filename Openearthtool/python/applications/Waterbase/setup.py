from setuptools import setup, find_packages

setup(
    name='Waterbase',
    version='0.1.0',
    author='Bas Hoonhout',
    author_email='bas.hoonhout@deltares.nl',
    packages=find_packages(),
    install_requires = [],
    license='LICENSE.txt',
    description='Waterbase data access toolbox',
    long_description=open('README.txt').read(),
)
