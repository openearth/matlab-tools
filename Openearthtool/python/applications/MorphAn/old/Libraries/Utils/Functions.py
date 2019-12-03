def GetArgumentByName(function, name) :
	"""
	Retrieves a function argument by name
	@param function: The function that contains the argument
	@param name: The name of the argument
	"""
	
	for argument in function.Arguments :
		if argument.Name == name :
			return argument
	
	return None

def GetComponentByName(function, name):
	"""
	Retrieves a function argument by name
	@param function: The function that contains the argument
	@param name: The name of the argument
	"""
	
	for component in function.Components :
		if component.Name == name :
			return component
	
	return None

	
	
