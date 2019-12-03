#region imports (external libraries or functions)
import itertools as _iter
from operator import itemgetter, attrgetter
import csv
#endregion

# Fill in the name of the model that contains the results
modelName = "Duinveiligheidsmodel"
# Fill in the name and path of the output file (create the directory first, not included in the script)
exportFileName = 'd:/projects/morphan/test.csv'

#region GetModel
# Method needed to retrieve a model given its name from the project

def GetModel(modelName) :
	"""
	Tries to find the first model in the project tree by name
	@param modelName: The name of the model to find (string)
	"""
	
	requestedModel = None
	for item in RootFolder.Items :
		requestedModel = GetModelRecursive(item,modelName)
		if (requestedModel != None) :
			return requestedModel
	
	if (requestedModel == None) :
		print "Model was not found"
	
	return None
	
#endregion

#region GetModelRecursive

def GetModelRecursive(item,modelName) :
	"""
	Looks for the first model with the specified name within an item (model, compositemodel or folder) recursively
	@param item: The item to look into. This can either be a Model, CompositeModel or Folder
	@param modelName: Name of the model to find
	"""
	
	# Is it the asked model?
	if (hasattr(item,'ExplicitWorkingDirectory') and hasattr(item,'Name') and item.Name == modelName) :
		return item
		
	# Does it have child models with this name?
	if (hasattr(item,'Models')) :
		models = item.Models
		for model in models :
			requestedModel = GetModelRecursive(model,modelName)
			if (requestedModel != None) :
				return requestedModel
	
	# Does it have folders that contain this model?
	if (hasattr(item,'Folders')) :
		folders = item.Folders
		for folder in folders :
			requestedModel = GetModelRecursive(folder,modelName)
			if (requestedModel != None) :
				return requestedModel
	
	return None

#endregion

print "Starting export"

# get model
model = GetModel(modelName)

#region Open File and write headers
csvfile = open(exportFileName, 'wb')
writer = csv.writer(csvfile, delimiter=';', quotechar='|', quoting=csv.QUOTE_MINIMAL)
headers = ['Kustvak nummer', 'Locatie', 'Jaar', 'X zeewaarts afslagprofiel']
writer.writerow(headers)
#endregion

#region loop through results in model and write output
for location,resultsGroup in _iter.groupby(sorted(model.ErosionModel.ModelResult.ResultList,key=attrgetter('Location')), attrgetter('Location')):
	for result in sorted(resultsGroup,key=attrgetter('Year')):
		if (result.OutputPointR == None or result.OutputDurosProfile == None):
			writer.writerow([location.AreaId, location.Offset, result.Year, 'NaN'])
		else:
			writer.writerow([location.AreaId, location.Offset, result.Year, result.OutputDurosProfile.XMaximal])

#endregion

# Close the file (which is still open)
csvfile.close()	

print "Finished"