from SharpMap.Data.Providers import ShapeFile
import sqlite3
import csv

# shapeLocation = r"d:\Projecten\Ringtoets\Voorbeelddata\NorminformatieEnTrajecten\Normtrajecten_Wetgeving_V29_22jan2016.shp"
shapeLocation = r"N:\Projects\1230000\1230088\C. Report - advise\001 Ringtoets\General data\Trajecten en vakindelingen\IHW voorstel\voorbeeld_uf_Dijktrajecten\voorbeeld_uf_Dijktrajecten.shp"
shapeFile = ShapeFile(shapeLocation, False)

#region Numerics file
outputFileNumerics = r"n:\Projects\1230000\1230088\C. Report - advise\001 Ringtoets\002 HR\Numerics.csv"
with open(outputFileNumerics, 'wb') as csvfile:
    w = csv.writer(csvfile, delimiter=';', quoting=csv.QUOTE_NONNUMERIC)
    w.writerow(['TrajectID',
    			'MechanismID','SubMechanismID',
    			'Rekenmethode',
    			'FORM_StartMethod','FORM_NrIterations','FORM_RelaxationFactor','FORM_EpsBeta','FORM_EpsHOH','FORM_EpsZFunc',
    			'Ds_StartMethod','Ds_Min','Ds_Max','Ds_VarCoefficient',
    			'NI_UMin','NI_Umax','NI_NumberSteps'])
    			
    for traject in shapeFile.Features:
    	traject_id =  traject.Attributes['TRAJECT_ID'] 
    	w.writerow([traject_id,1,1,1,4,50,0.15,0.01,0.01,0.01,2,20000,100000,0.1,-6,6,25])
    	w.writerow([traject_id,11,11,1,4,50,0.15,0.01,0.01,0.01,2,20000,100000,0.1,-6,6,25])
    	w.writerow([traject_id,11,14,1,4,50,0.15,0.01,0.01,0.01,2,20000,100000,0.1,-6,6,25])
    	w.writerow([traject_id,11,16,1,4,50,0.15,0.01,0.01,0.01,2,20000,100000,0.1,-6,6,25])
    	w.writerow([traject_id,3,3,1,4,50,0.15,0.01,0.01,0.01,2,20000,100000,0.1,-6,6,25])
    	w.writerow([traject_id,3,4,1,4,50,0.15,0.01,0.01,0.01,2,20000,100000,0.1,-6,6,25])
    	w.writerow([traject_id,3,5,1,4,50,0.15,0.01,0.01,0.01,2,20000,100000,0.1,-6,6,25])
    	w.writerow([traject_id,101,102,1,4,50,0.15,0.01,0.01,0.01,2,20000,100000,0.1,-6,6,25])
    	w.writerow([traject_id,101,103,1,4,50,0.15,0.01,0.01,0.01,2,20000,100000,0.1,-6,6,25])
#endregion

#region Tijdsintegratie / HydraulicModels tabel
outputFileHydraulicModels = r"n:\Projects\1230000\1230088\C. Report - advise\001 Ringtoets\002 HR\HydraulicModels.csv"
with open(outputFileHydraulicModels, 'wb') as csvfile:
    w = csv.writer(csvfile, delimiter=';', quoting=csv.QUOTE_NONNUMERIC)
    w.writerow(['TrajectID','TijdsIntegratie'])
    			
    for traject in shapeFile.Features:
    	traject_id =  traject.Attributes['TRAJECT_ID'] 
    	w.writerow([traject_id,1])
#endregion

#region DesignTables file
outputFileDesignTables = r"n:\Projects\1230000\1230088\C. Report - advise\001 Ringtoets\002 HR\DesignTables.csv"
with open(outputFileDesignTables, 'wb') as csvfile:
    w = csv.writer(csvfile, delimiter=';', quoting=csv.QUOTE_NONNUMERIC)
    w.writerow(['TrajectID',
    			'Variabele', 
        		'Min', 
        		'Max'])
    			
    for traject in shapeFile.Features:
    	traject_id =  traject.Attributes['TRAJECT_ID'] 
    	w.writerow([traject_id,'Toetspeil',5,15])
    	w.writerow([traject_id,'Q',5,15])
    	w.writerow([traject_id,'Hs',5,15])
    	w.writerow([traject_id,'Tp',5,15])
    	w.writerow([traject_id,'Tm-1,0',5,15])
    	w.writerow([traject_id,'HBN',5,15])
#endregion
