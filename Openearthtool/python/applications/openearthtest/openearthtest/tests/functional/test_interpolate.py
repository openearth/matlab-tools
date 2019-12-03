from openearthtest.tests import *

class TestInterpolateController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='interpolate', action='index'))
        # Test response...
