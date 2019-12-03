from abc import ABCMeta, abstractmethod, abstractproperty
import os
import inspect

class TestBase(object):
	__metaclass__ = ABCMeta
	
	@abstractproperty
	def name(self):
		pass
		
	@abstractmethod
	def RunTest(self):
		"""Defines the code to execute whenever a test should be run"""
		pass

	def _getrootdir(self):
		"""Returns the root directory of the test definition"""
		return os.path.abspath(inspect.getfile(self.__class__))

#region Helpers -> Move to testhelper class?
	def createlatextable(table):
		# TODO: Should we use this?
		pass

	def savefigure(chartView,filename):
		# TODO: Should we use this?
		pass

	def getfilewriter(filename):
		return open(filename,"r+")

	def closefile(file_obj):
		file_obj.close()

	def getprofileshape(self,shapemode):
		if shapemode == 'reference':
			x = [ -250.0, -24.375, 5.625, 55.725, 230.625, 2780.625 ]
			z = [ 15.0, 15.0, 3.0, 0.0, -3.0, -20.0 ]
			return x,z
		
		return None

	def getscenario(self,scenarioname):
		if scenarioname == 'default':
			return 5.0, 9, 16, 0.000250
#endregion

