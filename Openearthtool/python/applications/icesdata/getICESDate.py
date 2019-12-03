# -*- coding: utf-8 -*-
"""
Created on Mon Apr 22 18:15:49 2013

@author: drs.Ing. Gerrit Hendriksen

purpose is to download data from ICES database using soapservice GetICEData
http://ocean.ices.dk/webservices/hydchem.asmx?op=GetICEData 

dependencies:
 - suds (https://fedorahosted.org/suds/)
"""

from suds.client import Client
import ices_orm


# chemical data
url = 'http://ocean.ices.dk/webservices/hydchem.asmx?WSDL'
client = Client(url)





# biological data available services, I right now don't know how to call this http://dome.ices.dk/Webservices/EcoSystemWebServices.asmx
#numberFilesDatabase
#Get the number of files in the database
#
#numberParametersDatabase
#Get the number of parameters in the database
#
#selectOBISSummaryData
#Select OBIS Schema Species summary
#
#selectOBISdata
#Select OBIS Schema Species information 
url = 'http://dome.ices.dk/Webservices/EcoSystemWebServices.asmx?WSDL'
client = Client(url)

result = client.service.selectOBISdata('Macoma',-4.0,10.0,49.0,58,2000)
#  <scientificName>string</scientificName>
#  <lowerLat>string</lowerLat>
#  <upperLat>string</upperLat>
#  <leftLon>string</leftLon>
#  <rightLon>string</rightLon>
#  <year>string</year>


<s:element name="GetICEData"><s:complexType><s:sequence>
<s:element minOccurs="1" maxOccurs="1" name="ParameterCode" type="tns:ParameterCodeEnum"/>
<s:element minOccurs="1" maxOccurs="1" name="FromYear" type="s:int"/>
<s:element minOccurs="1" maxOccurs="1" name="ToYear" type="s:int"/>
<s:element minOccurs="1" maxOccurs="1" name="FromMonth" type="s:int"/>
<s:element minOccurs="1" maxOccurs="1" name="ToMonth" type="s:int"/>
<s:element minOccurs="1" maxOccurs="1" name="FromLongitude" type="s:double"/>
<s:element minOccurs="1" maxOccurs="1" name="ToLongitude" type="s:double"/>
<s:element minOccurs="1" maxOccurs="1" name="FromLatitude" type="s:double"/>
<s:element minOccurs="1" maxOccurs="1" name="ToLatitude" type="s:double"/>
<s:element minOccurs="1" maxOccurs="1" name="FromPressure" type="s:double"/>
<s:element minOccurs="1" maxOccurs="1" name="ToPressure" type="s:double"/>

<s:enumeration value="TEMP"/>
<s:enumeration value="PSAL"/>
<s:enumeration value="DOXY"/>
<s:enumeration value="PHOS"/>
<s:enumeration value="TPHS"/>
<s:enumeration value="AMON"/>
<s:enumeration value="NTRI"/>
<s:enumeration value="NTRA"/>
<s:enumeration value="NTOT"/>
<s:enumeration value="SLCA"/>
<s:enumeration value="H2SX"/>
<s:enumeration value="PHPH"/>
<s:enumeration value="ALKY"/>
<s:enumeration value="CPHL"/>


result = client.service.GetICEData('DOXY',2003,2012,1,12,-4.0,10.0,49.0,58,0.0,100.0)
avgres = client.service.GetICEDataAverage('TEMP',2010,2010,1,3,2.0,3.0,52.0,52.5,0.0,10.0)
print result
print avgres

from suds.client import Client
url = 'http://ocean.ices.dk/webservices/hydchem.asmx?WSDL'
client = Client(url)
result = client.service.GetICEData('DOXY',2003,2012,1,12,-4.0,10.0,49.0,58,0.0,100.0)

afn = r'D:\temp\doxy_2003-2012.txt' 
af = open(afn,'rb')
af.write('Longitude'+','+'Latitude'+','+'DateTime'+','+'Pressure'+','+'Value'+'\r\n')
for i in range(len(result['ICEData'])):
    af.write(str(result['ICEData'][i]['Longitude'])+','+str(result['ICEData'][i]['Latitude'])+','+str(result['ICEData'][i]['DateTime'])+','+str(result['ICEData'][i]['Pressure'])+','+str(result['ICEData'][i]['Value'])+'\r\n')

af.close()

df = pandas.read_csv(afn)

