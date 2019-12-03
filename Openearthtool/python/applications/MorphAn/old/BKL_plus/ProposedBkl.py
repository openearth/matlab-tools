def ProposedBklNames():
	return ["Noordwijk","Scheveningen 2013","Delfland 2013","Westkapelle","Nieuwvliet-Groede","Waterdunen - West","Waterdunen - Oost", "Herdijkte Zwarte Polder"]
	#"Scheveningen 2012",
	#"Delfland 2012"
	
def ProposedBkl(name):
	if (name == "Waterdunen - West"):
		""" 2012-09-26 - Ontwerpnota dijkversterking Zwakke Schakel Waterdunen"""
		return [[461],[126]]
	if (name == "Waterdunen - Oost"):
		""" 2012-09-26 - Ontwerpnota dijkversterking Zwakke Schakel Waterdunen"""
		return [[171,188,208,230,251,271,290,308,324,336],[106,104,98,89,100,104,83,80,77,78]]
	if (name == "Noordwijk"):
		""" 2012, Deltares/Arcadis rapport "Achtergrondrapport Basiskustlijn 2012"""
		return [[8075,8100,8125,8150,8175,8200,8225],[219,225,228,234,245,250,228]]
	if (name == "Scheveningen 2013"):
		"""  21 mei 2013 (Brief hh delfland toezeggingen aanpassing)""" 
		return [[9875,9925,9975,10025,10075,10125,10140],[100,175,190,197,190,127,171]]
	if (name == "Scheveningen 2012"):
		"""  2012, Deltares/Arcadis rapport "Achtergrondrapport Basiskustlijn 2012""" 
		return [[9925,9975,10025,10075],[200,190,197,190]]
	if (name == "Delfland 2012"):
		"""  2012, Deltares/Arcadis rapport "Achtergrondrapport Basiskustlijn 2012""" 
		return [[10200,10217,10235,10288,10338,10391,10437,10468,10488,10507,10527,10547,10567,10592,10623,10653,10683,10713,10743,10773,10807,10845,10883,10920,10958,10996,11034,11072,11109,11147,11176,11196,11221,11244,11263,11282,11301,11319,11338,11356,11375,11394],
				[162,137,110,57,27,1,3,21,20,34,32,46,56,56,59,60,59,69,78,76,68,91,82,76,70,71,73,76,71,108,131,142,125,137,135,134,134,140,140,136,136,140]]
	if (name == "Delfland 2013"):
		"""  22 mei 2013 (Brief hh delfland toezeggingen aanpassing)""" 
		return [[10200,10217,10235,10288,10338,10391,10437,10468,10488,10507,10527,10547,10567,10592,10623,10653,10683,10713,10743,10773,10807,10845,10883,10920,10958,10996,11034,11072,11109,11147,11176,11196,11221,11244,11263,11282,11301,11319,11338,11356,11375,11394],
				[192,167,140,87,77,51,53,71,70,84,92,106,116,126,129,170,169,179,188,186,178,201,192,186,180,181,183,186,201,208,211,222,220,232,230,229,229,225,220,216,216,204]]
	if (name == "Westkapelle"):
		"""  2012, Deltares/Arcadis rapport "Achtergrondrapport Basiskustlijn 2012""" 
		return [[1755,1775,1795,1814,1832,1850,1870,1883,1894,1905,1917,1927,1938],
				[80,76,86,82,101,103,124,137,131,139,115,108,109]]
	if (name == "Nieuwvliet-Groede"):
		"""  2012, Deltares/Arcadis rapport "Achtergrondrapport Basiskustlijn 2012""" 
		return [[461,483,496,512,530,558,584,602,619,638,663,684,705,730,751,768,778,791,802],
				[108,71,62,67,85,71,42,39,26,26,72,70,63,70,96,132,153,163,142]]
	if (name == "Herdijkte Zwarte Polder"):
		"""  2007 Kustversterkingsplan: ontwerp zegt 18m zeewaarts richting +110, Roelse zegt onderstaande""" 
		return [[985, 993, 1007, 1021, 1032, 1046, 1068],
				[123, 130, 120, 109, 104, 115, 74]]		
	if (name == "Cadzand Bad - West"):
		"""  2007 Kustversterkingsplan: ontwerp zegt 18m zeewaarts richting 136""" 
		return [[1354, 1363, 1372, 1381, 1391, 1401, 1412],
				[121,  110,  130,  143,  152,  144,  136]]		
	if (name == "Cadzand Bad - Oost"):
		"""  2007 Kustversterkingsplan: ontwerp zegt 18m zeewaarts richting 124""" 
		return [[1214, 1241, 1262, 1282, 1300, 1318, 1335],
				[77,   104,  120,  138,  155, 155, 139]]	
	if (name == "Callantsoog"):
		"""  Verzinsel Kees op basis van Arcadis rapport""" 
		return [[748, 1093, 1503],
				[11, 11, 11]]	
	return [[],[]]
