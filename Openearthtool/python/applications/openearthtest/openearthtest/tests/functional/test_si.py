from openearthtest.tests import *

class TestSiController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='si', action='index'))
        # Test response...
