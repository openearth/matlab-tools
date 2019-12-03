from Libraries.Utils.Project import *
from Libraries.XBeach.XBeach import *


def AddXBeachModel():
	#region 1. Definieer invoer
	x = [ 250.0, 24.375, -5.625, -55.725, -230.625, -2780.625 ]
	z = [ 15.0, 15.0, 3.0, 0.0, -3.0, -20.0 ]
	waterLevel = 5.0
	Hs = 9
	Tp = 16
	D50 = 0.000250
	#endregion

	#region 2. Maak XBeach model
	model = CreateXBeachModel(x,z,waterLevel,Hs,Tp,D50)

	# Zorg dat de naam van het model uniek is. Anders zullen 2 modellen gebruik maken van dezelfde werk directory
	model.Name = GetUniqueName("XBeach model")

	# Plaats het model in een folder
	folder = FindFolder("XBeach berekeningen")
	if (folder == None) :
		folder = AddFolder("XBeach berekeningen")
	
	folder.Add(model) 

	#endregion
