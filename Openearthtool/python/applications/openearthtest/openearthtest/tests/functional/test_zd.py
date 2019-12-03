from openearthtest.tests import *

class TestZdController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='zd', action='index'))
        # Test response...
