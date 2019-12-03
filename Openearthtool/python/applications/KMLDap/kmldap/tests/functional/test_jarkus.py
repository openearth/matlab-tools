from kmldap.tests import *

class TestJarkusController(TestController):

    def test_index(self):
        response = self.app.get(url(controller='jarkus', action='index'))
        response = self.app.get(url(controller="jarkus", action='index', id='7003800'))
    def test_eeg(self):
        response = self.app.get(url(controller="jarkus", action='eeg', id='7003800'))
    def test_mkl(self):
        response = self.app.get(url(controller="jarkus", action='mkl', id='7003800'))
        response = self.app.get(url(controller="jarkus", action='mkl', id='11001520'))
    def test_transectview(self):
        response = self.app.get(url(controller="jarkus", action='overview'))
        response = self.app.get(url(controller="jarkus", action='overview', format="kml"))

    def test_transectplot(self):
        response = self.app.get(url(controller="jarkus", action='transectplot', id='7003800'))
        response = self.app.get(url(controller="jarkus", action='transectplot', id='7003800', format="pdf"))

    def test_alphahistory(self):
        response = self.app.get(url(controller="jarkus", action='alphahistory', id='7003800'))
        response = self.app.get(url(controller="jarkus", action='alphahistory', id='7003800', format="pdf"))
        
    def test_procrustes(self):
        response = self.app.get(url(controller="jarkus", action='procrustes', id='7003800'))
        response = self.app.get(url(controller="jarkus", action='procrustes', id='7003800', format="pdf"))
