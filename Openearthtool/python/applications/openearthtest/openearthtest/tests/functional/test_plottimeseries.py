from openearthtest.tests import *

class TestPlottimeseriesController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='plottimeseries', action='index'))
        # Test response...
