import unittest

from pyramid import testing


class UnitTests(unittest.TestCase):
    def setUp(self):
        self.config = testing.setUp()

    def tearDown(self):
        testing.tearDown()

    def test_read_netcdf(self):
        from .read_netcdf import species
        df = species()
        self.assertEqual(len(df), 0)
    def test_read_postgis(self):
        from .read_postgis import get_ices_polygon
        poly = get_ices_polygon()
        self.assertRegexpMatches(poly.wkt, r'POLYGON\s+\(\(')
    def test_netcdf_and_postgis(self):
        # we would like to keep these independent
        from .read_postgis import get_ices_polygon
        from .read_netcdf import species
        statsq="34F2"
        aspecies='PO4'
        poly = get_ices_polygon(statsq)
        df = species(apoly=poly, aspecies=aspecies)
        self.assertGreater(len(df), 0)
    def test_netcdf_and_postgis_and_plot(self):
        from .read_postgis import get_ices_polygon
        from .read_netcdf import species, delwaq_species
        from .plots import plot_ts_nc
        statsq="34F2"
        poly = get_ices_polygon(statsq)
        aspecies='PO4'
        df = species(apoly=poly, aspecies=aspecies)
        f = plot_ts_nc(df, statsq, aspecies, delwaq_species())
        self.assertEqual('PNG', f.read()[1:4])
    def test_netcdf_uham_and_postgis(self):
        # we would like to keep these independent
        from .read_postgis import get_ices_polygon
        from .read_netcdf_uham import species
        statsq="34F2"
        aspecies='PO4'
        poly = get_ices_polygon(statsq)
        df = species(apoly=poly, aspecies=aspecies)
        self.assertGreater(len(df), 0)


class ViewTests(unittest.TestCase):
    def setUp(self):
        self.config = testing.setUp()

    def tearDown(self):
        testing.tearDown()

    def test_my_view(self):
        from .views import my_view
        request = testing.DummyRequest()
        info = my_view(request)
        self.assertEqual(info['project'], 'vectors')
    def test_species_view(self):
        from .views import species_view
        request = testing.DummyRequest()
        request.matchdict['species']='PO4'
        request.matchdict['statsq']="34F2"
        response = species_view(request)
        self.assertEqual('PNG', response.body[1:4])
    def test_kml_view(self):
        from .views import kml_view
        request = testing.DummyRequest()
        request.matchdict['species']='PO4'
        request.matchdict['statsq']="34F2"
        response = kml_view(request)
        self.assertEqual('<?xml', response.body[:5])
