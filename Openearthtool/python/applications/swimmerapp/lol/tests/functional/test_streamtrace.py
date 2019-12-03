from lol.tests import *

class TestStreamtraceController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='streamtrace', action='index'))
        # Test response...
    def test_trace(self):
        response = self.app.get(url(controller='streamtrace', action='trace'))
