from kmldap.tests import *

class TestUsgsController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='usgs', action='index'))
        # Test response...
