try:
  from lxml import etree
  print("running with lxml.etree")
except ImportError:
  try:
    # Python 2.5
    import xml.etree.cElementTree as etree
    print("running with cElementTree on Python 2.5+")
  except ImportError:
    try:
      # Python 2.5
      import xml.etree.ElementTree as etree
      print("running with ElementTree on Python 2.5+")
    except ImportError:
      try:
        # normal cElementTree install
        import cElementTree as etree
        print("running with cElementTree")
      except ImportError:
        try:
          # normal ElementTree install
          import elementtree.ElementTree as etree
          print("running with ElementTree")
        except ImportError:
          print("Failed to import ElementTree from any known place")
import datetime

wml2  = '{http://www.opengis.net/waterml/2.0}'
gml   = '{http://www.opengis.net/gml/3.2}'
om    = '{http://www.opengis.net/om/2.0}'
xlink = '{http://www.w3.org/1999/xlink}'
sa    = '{http://www.opengis.net/sampling/2.0}'
sams  = '{http://www.opengis.net/samplingSpatial/2.0}'

class xmlParseException(Exception):
    '''
    An exception definition to raise exceptions with simple text messages
    '''
    pass

def getNamedChildren(Parent,*elms):
    '''
    Get the elements that are associated with a specific path in an XML tree.
    Parent is the main XML node, and *elms indicates the path from the main
    node to the requested nodes. For all intermediate levels only one node may
    exist; if this is not the case, an exception will be raised. The last tag
    may occur multiple times. A list of elements is returned.
    '''
    for elm in elms[:-1]:
        Parent = getNamedChild(Parent,elm)
    Items = Parent.getchildren()
    for i in range(len(Items)-1,-1,-1):
       if Items[i].tag != elms[-1]:
          Items[i:i+1] = []
    return Items

def getNamedChild(Parent,*elms):
    '''
    Get the element that is associated with a specific path in an XML tree.
    Parent is the main XML node, and *elms indicates the path from the main
    node to the requested node. The path must uniquely point to a single
    element node. That element node is returned.
    '''
    Item = Parent
    for elm in elms:
        Items = getNamedChildren(Item,elm)
        if len(Items)!=1:
            raise xmlParseException('Name "'+elm+'" does not occur a single time')
        Item = Items[0]
    return Item

def str2time(Str):
    '''
    Convert an ISO8601 time string to a datetime object.
    '''
    return datetime.datetime.strptime(Str,'%Y-%m-%dT%H:%M:%S')

def str2period(Str):
    '''
    Convert an ISO8601 time period string to a datetime.timedelta object.
    '''
    if Str[0] != 'P':
        raise xmlParseException('ISO 8601 Period string "'+Str+'" should start with "P"')
    else:
        Sup = Str[1:].upper()
        Slw = Str[1:].lower()
        i0 = 0
        Tpassed = False
        if Sup.find('-')>0:
            # P0000-00-00T00-00-00
            P = datetime.datetime.strptime(Str,'P%Y-%m-%dT%H:%M:%S')
            P = datetime.timedelta(days=P.tm_mday, hours=P.tm_hour, minutes=P.tm_min, seconds=P.tm_sec)
        else:
            # P[00Y][00M][00D]T[00H][00M][00S]
            P = [0,0,0,0,0,0]
            for i in range(len(Sup)):
                if Sup[i] == Slw[i] and i<len(Sup)-1:
                    continue
                elif Sup[i] != Slw[i]:
                    value = Sup[i0:i]
                    unit = Sup[i]
                else:
                    value = Sup[i0:i+1]
                    unit = ''
                #print value,unit
                if unit == 'Y' and not(Tpassed):
                    P[0] = float(value)
                elif unit == 'M' and not(Tpassed):
                    P[1] = float(value)
                elif unit == 'D' and not(Tpassed):
                    P[2] = float(value)
                elif unit == 'T' and value == '':
                    # P00000000T000000 not yet supported
                    Tpassed = True
                elif unit == 'H' and Tpassed:
                    P[3] = float(value)
                elif unit == 'M' and Tpassed:
                    P[4] = float(value)
                elif unit == 'S' and Tpassed:
                    P[5] = float(value)
                else:
                    raise xmlParseException('ISO 8601 Period string "'+Str+'" contains unrecognized character "'+unit+'"')
                i0 = i+1
            P = datetime.timedelta(days=P[2], hours=P[3], minutes=P[4], seconds=P[5])
    return P

def parseMonitoringPoint(MonPoint):
    '''
    Return a dictionary with Id, Name, Descr, Coord from a MonitoringPoint tree.
    '''
    Loc = {}
    #
    Id = MonPoint.attrib[gml+'id']
    Loc['Id'] = Id
    #
    eName = getNamedChildren(MonPoint,gml+'name')
    if len(eName)==1:
        Name = eName[0].text
    else:
        SF = getNamedChild(MonPoint,sa+'sampledFeature')
        Name = SF.attrib[xlink+'title']
    Loc['Name'] = Name
    #
    eDescr = getNamedChildren(MonPoint,gml+'description')
    if len(eDescr)==1:
        Descr = eDescr[0].text
    else:
        Descr = ''
    Loc['Descr'] = Descr
    #
    Coord = getNamedChild(MonPoint, sams+'shape', gml+'Point', gml+'pos').text.split(' ')
    for j in range(2):
        Coord[j] = float(Coord[j])
    Loc['Coord'] = Coord
    #
    return Loc

def loadWaterML2(FileName):
    '''
    Read WaterML2 file and return location and time series data.
    '''
    FI = {}
    FI['FileName'] = FileName
    FI['FileType'] = "WaterML2"

    Doc = etree.parse(FileName).getroot()

    DXML = getNamedChildren(Doc, wml2+'localDictionary', gml+'Dictionary', gml+'dictionaryEntry')
    Dict = range(len(DXML))
    for i in range(len(DXML)):
        Dict[i] = getNamedChild(DXML[i], gml+'Definition', gml+'name').text
    FI['Dictionary'] = Dict

    LXML = getNamedChildren(Doc, wml2+'samplingFeatureMember', wml2+'MonitoringPoint')
    Locs = range(len(LXML))
    for i in range(len(LXML)):
        Locs[i] = parseMonitoringPoint(LXML[i])
    FI['Location'] = Locs

    #FI['TimeSeries'] = getTimeSeries(Doc,Locs)
    TXML = getNamedChildren(Doc,wml2+'observationMember')
    TimeSeries = range(len(TXML))
    for i in range(len(TXML)):
        TSeries  = getNamedChild(TXML[i],om+'OM_Observation')
        eQName = getNamedChild(TSeries,om+'observedProperty')
        QName = eQName.attrib[xlink+'title']
        #
        LName = '';
        LCoord = [0,0];
        L = getNamedChildren(TSeries,om+'featureOfInterest')
        if len(L)==1:
            MP = getNamedChildren(L[0],wml2+'MonitoringPoint')
            if len(MP)==1:
                Loc = parseMonitoringPoint(MP[0])
                if Loc['Name'] != '':
                    LName = Loc['Name']
                elif Loc['Descr'] != '':
                    LName = Loc['Name']
                LCoord = Loc['Coord']
        if LName == '':
            try:
                LName = L.attrib[xlink+'title']
            except:
                LName = ''
        if LName == '':
            try:
                LName = L.attrib[xlink+'href']
                if LName[0] == '#':
                    LName = LName[1:]
                    for j in range(len(Locs)):
                        if LName == Locs[j]['Id']:
                           if Locs[j]['Name'] != '':
                               LName = Locs[j]['Name']
                           elif Locs[j]['Descr'] != '':
                               LName = Locs[j]['Name']
                           LCoord = Locs[j]['Coord']
            except:
                LName = ''
        #
        D = getNamedChild(TSeries, om+'result', wml2+'MeasurementTimeseries')
        TSName = D.attrib[gml+'id']
        #
        try:
            Str = getNamedChild(D, wml2+'metadata', wml2+'MeasurementTimeseriesMetadata', wml2+'baseTime')
            BeginTime = str2time(Str)
            SP = getNamedChild(D, wml2+'metadata', wml2+'MeasurementTimeseriesMetadata', wml2+'spacing')
            TimeStep = iso8601period(SP.text)
        except:
            BeginTime = []
            TimeStep = []
        #
        U = getNamedChild(D, wml2+'defaultPointMetadata', wml2+'DefaultTVPMeasurementMetadata', wml2+'uom')
        QUnit = U.attrib['code']
        #
        TSV = getNamedChildren(D,wml2+'point')
        Time = range(len(TSV))
        Value = range(len(TSV))
        for j in range(len(TSV)):
            TSVj = getNamedChild(TSV[j],wml2+'MeasurementTVP')
            #
            if len(BeginTime) == 0:
                TStr = getNamedChild(TSVj,wml2+'time').text
                Time[j] = str2time(TStr)
            else:
                Time[j] = BeginTime + (j-1)*TimeStep
            #
            Value[j] = float(getNamedChild(TSVj,wml2+'value').text)
        TimeSeries[i] = {}
        TimeSeries[i]['Time'] = Time
        TimeSeries[i]['Value'] = Value
    FI['TimeSeries'] = TimeSeries
    return FI
