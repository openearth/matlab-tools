#region import
from System import *
from DeltaShell.Plugins.MorphAn.Data import *
#endregion

#region GetJarkusMeasurementsSet

def GetJarkusMeasurementsSet(jrkSetName):
	"""
	Find a jarkus measurements set in the first workspace of the rootfolder by name
	@param jrkSetName: The name of the jarkus measuerments set to find
	"""
	
	set = None
	morphAnData = None
	for item in RootFolder.Items : 
		try:
			morphAnData = item.MorphAnData
			set = GetJrkSet(morphAnData,jrkSetName)
			if (set == None) :
				# This exception will be caught and will not be shown.
				raise Exception("No set with the specified name, please check your input")
		except:
			pass
			
	if (morphAnData == None or set == None) : 
		print "Could not find a workspace containing the specified jarkus set"
		return None
	
	return set

#endregion

#region GetJarkusMeasurements

def GetJarkusMeasurements(jrkSetName) :
	"""
	Find all jarkus measurements in the first workspace of the rootfolder by name of the containing set
	@param jrkSetName: The name of the jarkus measuerments set to find
	"""
	
	#region Find first set and morphanData
	
	# Need MorphAnData here because it contains the location filter (not included in the set). This is why we do not use GetJarkusMeasurementsSet
	morphAnData = None
	set = None
	for item in RootFolder.Items : 
		try:
			morphAnData = item.MorphAnData
			set = GetJrkSet(morphAnData,jrkSetName)
			if (set == None) :
				# This exception will be caught and will not be shown.
				raise Exception("No set with the specified name, please check your input")
		except:
			pass
			
	if (morphAnData == None or set == None) : 
		print "Could not find a workspace containing the specified jarkus set"
		return None
		
	#endregion
	
	return MorphAnDataExtensions.Transects(morphAnData,set)
	
#endregion

#region "Private" functions

def GetJrkSet(morphAnData,jrkSetName) :
	"""
	Finds a jarkus measurements set in the specified MorphAn data.
	@param morphAnData: the MorphAnData that should contain the specified jarkus measurements set
	@param jrkSetName: The name of the jarkus measuerments set to find
	"""
	
	for data in morphAnData.JarkusMeasurementsList : 
		print data.Name
		if (data.Name == jrkSetName) : 
			return data
	
	return None
	
#endregion

def GetBoundaryConditionsSet(setName):
	"""
	Find a boundary conditions set in the first workspace of the rootfolder by name
	@param jrkSetName: The name of the jarkus measuerments set to find
	"""
	
	set = None
	morphAnData = None
	for item in RootFolder.Items : 
		try:
			morphAnData = item.MorphAnData
			set = GetBndSet(morphAnData,jrkSetName)
			if (set == None) :
				# This exception will be caught and will not be shown.
				raise Exception("No set with the specified name, please check your input")
		except:
			pass
			
	if (morphAnData == None or set == None) : 
		print "Could not find a workspace containing the specified jarkus set"
		return None
	
	return set
	
def GetBndSet(morphAnData,setName) :
	"""
	Finds a jarkus measurements set in the specified MorphAn data.
	@param morphAnData: the MorphAnData that should contain the specified jarkus measurements set
	@param jrkSetName: The name of the jarkus measuerments set to find
	"""
	
	for data in morphAnData.BoundaryConditionsList : 
		print data.Name
		if (data.Name == setName) : 
			return data
	
	return None
	
#endregion