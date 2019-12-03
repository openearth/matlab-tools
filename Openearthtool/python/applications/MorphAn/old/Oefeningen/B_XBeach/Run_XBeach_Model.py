from Libraries.Utils.Project import *
from Libraries.XBeach.XBeach import *

"""
Deze oefening laat zien hoe met behulp van scripting een XBeach model aan het project
kan worden toegevoegd en gedraaid.

1. Lees eerst het script zorgvuldig door en voer het uit.
2. Probeer nu de invoer te veranderen en run het nieuwe model
3. 
"""

#region 1. Definieer invoer
x = [ 250.0, 24.375, -5.625, -55.725, -230.625, -2780.625 ]
z = [ 15.0, 15.0, 3.0, 0.0, -3.0, -20.0 ]
waterLevel = 5.0
Hs = 9
Tp = 16
D50 = 0.000250

""" Het is belangrijk het project ergens op te slaan, anders kan een XBeach model niet rekenen """
projectPath = "d:\\Test\\XBeachTemp\\XBeach test project.dsproj"

#endregion

#region 2. Maak XBeach model
model = CreateXBeachModel(x,z,waterLevel,Hs,Tp,D50)

""" Zorg dat de naam van het model uniek is. Anders zullen 2 modellen gebruik maken van dezelfde werk directory """
model.Name = GetUniqueName("TestProfiel")

""" Plaats het model in een folder in het project """
folder = FindFolder("XBeach berekeningen")
if (folder == None) :
	folder = AddFolder("XBeach berekeningen")
	
folder.Add(model) 

#endregion

#region 3. Sla het project op
"""
 Opslaan van het project is nodig omdat XBeach modellen anders geen directory hebben om de uitvoer in weg te schrijven.
 Als het project nog niet is opgeslagen zal de gebruiker worden gevraagd om een locatie.
"""

if (Application.ProjectService.ProjectRepository.Path != projectPath):
	Application.SaveProjectAs(projectPath)
else :
	Application.SaveProject()

#endregion

#region 4. Run het model
"""
Geeft geen feedback tijdens de berekening, maar stopt wel de uitvoering van dit script totdat het model klaar is
"""
# Application.ActivityRunner.RunActivity(model)

"""
Geeft feedback tijdens de berekening, maar zorgt ervoor de het script doorloopt, vandaar het while statement erachter
om te zorgen dat we pas verder gaan als het model klaar is
"""
Application.ActivityRunner.Enqueue(model)

while (Application.ActivityRunner.IsRunningActivity(model)) :
	# Wacht totdat de berekening klaar is
	time.sleep(1)
	
#endregion

#region 5. Toon berekend profiel in de interface
""" Opent het standaard scherm voor de uitvoer in dwarsprofiel """
view = CrossShoreOutputView()
view.Data = model
Gui.DocumentViews.Add(view)
Gui.DocumentViews.ActiveView = view

#endregion