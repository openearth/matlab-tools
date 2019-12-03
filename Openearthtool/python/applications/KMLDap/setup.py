try:
    from setuptools import setup, find_packages
except ImportError:
    from ez_setup import use_setuptools
    use_setuptools()
    from setuptools import setup, find_packages

setup(
    name='KMLDap',
    version='0.1',
    description='Website for generating KML files and other visualisations from opendap',
    author='Fedor Baart',
    author_email='f.baart@tudelft.nl',
    url='http://openearth.deltares.nl',
    # add packages here if you create extra dependencies
    install_requires=[
        "Pylons>=0.9.7",
        "Pydap",
        "matplotlib",
        "numpy",
        "scipy",
        "netCDF4"
        ],
    # needed for running setup 
    setup_requires=["PasteScript>=1.6.3"],
    packages=find_packages(exclude=['ez_setup']),
    include_package_data=True,
    # dependencies for testing
    tests_require = ['nose'], # nosetests
    test_suite='nose.collector',
    #internationalization support
    package_data={'kmldap': ['i18n/*/LC_MESSAGES/*.mo']},
    #message_extractors={'kmldap': [
    #        ('**.py', 'python', None),
    #        ('templates/**.mako', 'mako', {'input_encoding': 'utf-8'}),
    #        ('public/**', 'ignore', None)]},
    zip_safe=False,
    # for running the webserver
    paster_plugins=['PasteScript', 'Pylons'],
    entry_points="""
    [paste.app_factory]
    main = kmldap.config.middleware:make_app

    [paste.app_install]
    main = pylons.util:PylonsInstaller
    """,
)
