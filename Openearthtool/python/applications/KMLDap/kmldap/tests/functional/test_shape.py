from kmldap.tests import *

class TestShapeController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='shape', action='index'))
        # Test response...
