from openearthtest.tests import *

class TestHkController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='hk', action='index'))
        # Test response...
