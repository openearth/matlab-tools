from SharpMap.Data.Providers import ShapeFile
from collections import namedtuple
import csv

%shapeiHWTrajects = r"N:\Projects\1230000\1230088\C. Report - advise\001 Ringtoets\General data\Trajecten en vakindelingen\Basisbestand iHW\waterkeringen_normtrajecten_20160322.shp"
shapeiHWTrajects = r"N:\Projects\1230000\1230088\C. Report - advise\001 Ringtoets\General data\Trajecten en vakindelingen\IHW voorstel\voorbeeld_uf_Dijktrajecten.shp"
nValuesCsv = r"N:\Projects\1230000\1230088\C. Report - advise\001 Ringtoets\011 Release\Functioneel ontwerp\Algemeen deel\N-waardes per traject.csv"
normValues = r"N:\Projects\1230000\1230088\C. Report - advise\001 Ringtoets\011 Release\Functioneel ontwerp\Algemeen deel\160129_Normhoogtes_Wet.csv"
outputFile = r"N:\Projects\1230000\1230088\C. Report - advise\001 Ringtoets\011 Release\Functioneel ontwerp\Algemeen deel\TrajectIdComparison.csv"

class TrajectInfo:
	Traject_ID = ""
	Norm = None
	N = None
	IHW_Available = False
	N_Available  = False
	Norm_Available = False
		
#region Read iHW trajecten
trajectShape = ShapeFile(shapeiHWTrajects, False)
iHWTrajects = {}
for feature in trajectShape.Features:
	trajectID = feature.Attributes['TRAJECT_ID']
	tr = TrajectInfo()
	tr.Traject_ID = trajectID
	tr.IHW_Available = True
	iHWTrajects[trajectID] = tr
#endregion

#region Read Norms
with open(normValues,'rb') as csvfile:
	reader = csv.reader(csvfile, delimiter=';')
	for row in reader:
		id = row[0]
		norm = row[1]
		if (iHWTrajects.has_key(id)):
			iHWTrajects[id].Norm = norm
			iHWTrajects[id].Norm_Available = True
		else:
			tr = TrajectInfo()
			tr.Traject_ID = id
			tr.Norm = norm
			tr.Norm_Available = True
			iHWTrajects[id] = tr
#endregion

#region Read N-values
with open(nValuesCsv,'rb') as csvfile:
	reader = csv.reader(csvfile, delimiter=';')
	for row in reader:
		id = row[0]
		n = row[1]
		if (iHWTrajects.has_key(id)):
			iHWTrajects[id].N = n
			iHWTrajects[id].N_Available = True
		else:
			tr = TrajectInfo()
			tr.Traject_ID = id
			tr.N = n
			tr.N_Available = True
			iHWTrajects[id] = tr
#endregion

with open(outputFile,'wb') as csvfile:
	w = csv.writer(csvfile, delimiter=';', quoting=csv.QUOTE_NONNUMERIC)
	w.writerow(['TRAJECT_ID','Norm','N','PartOfIHW','PartOfNorm','PartOfN'])
	for key in iHWTrajects:
		t = iHWTrajects[key]
		w.writerow([t.Traject_ID,t.Norm,t.N,t.IHW_Available,t.Norm_Available,t.N_Available])
