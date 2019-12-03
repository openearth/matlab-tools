from kmldap.tests import *

class TestWaterbaseController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='waterbase', action='index'))
        # Test response...
