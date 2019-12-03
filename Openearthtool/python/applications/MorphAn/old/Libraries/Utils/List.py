def Max(list):
	"""
	Returns the maximum value in a list
	"""
	max = list[0]
	for item in list :
		if item > max : 
			max = item
	return max
	
def Min(list):	
	"""
	Returns the minimum value in a list
	"""
	min = list[0]
	for item in list :
		if item < max : 
			min = item
	return min