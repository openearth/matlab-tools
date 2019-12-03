from kmldap.tests import *

class TestOperationalController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='operational', action='index'))
        # Test response...
