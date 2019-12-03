#region GetModel

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
	
#endregion GetModel

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