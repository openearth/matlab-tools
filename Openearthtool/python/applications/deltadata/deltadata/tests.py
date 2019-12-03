import unittest

from pyramid import testing
from pyramid.testing import DummyRequest
import pyramid.paster

from pyramid import testing

class ViewTests(unittest.TestCase):
    def setUp(self):
        self.config = testing.setUp()
    def tearDown(self):
        testing.tearDown()

    def test_getpois_nolocation(self):
        from .views import getpois
        request = testing.DummyRequest()
        info = getpois(request)
        self.assertEqual(info['hotspots'], [])
 
class FunctionalTests(unittest.TestCase):
    def setUp(self):
        self.config = testing.setUp()
        from deltadata import main
        app = main({},**{'mako.directories': 'deltadata:templates'})
        from webtest import TestApp
        self.testapp = TestApp(app)
    def tearDown(self):
        testing.tearDown()
    def test_root(self):
        res = self.testapp.get('/', status=200)
        self.failUnless('Pyramid' in res.body)

