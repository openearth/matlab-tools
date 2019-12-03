import unittest
from pyramid.testing import DummyRequest
import pyramid.paster

from pyramid import testing


class FunctionalTests(unittest.TestCase):
    def setUp(self):
        # this shoulde be something like: path_to_config_file = pkg_resources.resource_path('mypackage', 'tests/tests.ini')
        app = pyramid.paster.get_app('development.ini', 'myapp')
        from webtest import TestApp
        self.app = TestApp(app)
    def test_root(self):
        res = self.app.get('/', status=200)
        self.failUnless('Pyramid' in res.body)
    def test_getpois(self):
        res = self.app.get('/getpois', status=200)
        print(res.body)
        

