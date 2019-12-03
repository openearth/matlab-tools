from gui.tests import *

class TestInterfaceController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='interface', action='index'))
        # Test response...
