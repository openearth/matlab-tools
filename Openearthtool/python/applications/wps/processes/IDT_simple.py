"""
IDT Wrapper tool (viewer.openearth.nl) 
"""

from pywps.Process import WPSProcess  
import ftplib
import lxml.builder
import lxml.etree
import socket
import cStringIO
import re
import os
import string
import random
import zipfile
from zipfile import ZipFile
from time import sleep
from types import StringType, FloatType, IntType
import numpy as np

class Process(WPSProcess):
    def __init__(self):

        ##
        # Process initialization
        WPSProcess.__init__(self,
            identifier = "IDT_simple",
            title="Interactive Dredge Planning Tool",
            abstract="""WPS implementation of the Interactive Dredge Planning Tool of
            viewer.openearth.nl; this version is limited in the number of parameters
            but is used to show the usability of WPS. In this case the WPS process itself
            is a wrapper for executing the original Matlab tool""",
            version = "0.1",
            storeSupported = True,
            statusSupported = True)

        ##
        # Adding process inputs
        
        self.lon1In   = self.addLiteralInput(identifier="lon1In",
                    title="Longitude for tidal prediciton in WGS84",
                    type = FloatType)

        self.lat1In   = self.addLiteralInput(identifier="lat1In",
                    title = "Lattitude for tidal prediciton in WGS84",
                    type = FloatType)

        self.lon2In   = self.addLiteralInput(identifier="lon2In",
                    title="Longitude for tidal prediciton in WGS84",
                    type = FloatType)
                    
        self.lat2In   = self.addLiteralInput(identifier="lat2In",
                    title = "Lattitude for tidal prediciton in WGS84",
                    type = FloatType)

        self.scnameIn  = self.addLiteralInput(identifier="scnameIn",
                    title = "Scenario Name",
                    type = StringType)

        self.nparticlesIn = self.addLiteralInput(identifier="nparticlesIn",
                    title = "Number of particles for simulation",
                    type = IntType,
                    default = 5000)        

        self.tdurationIn   = self.addLiteralInput(identifier="tdurationIn",
                    title = "Length of the simulation in minutes",
                    type = IntType,
                    default = 1)

        ##
        # Adding process outputs

        self.kmlOut = self.addComplexOutput(identifier="kmlOut",
                    title="KML file of model output",
                    formats=[{"mimeType":"application/vnd.google-earth.kml+xml"}])

        #self.textOut = self.addLiteralOutput(identifier = "text",
        #       	   title="Output literal data")

    ##
    # Execution part of the process
    def execute(self):
        
        #FTP server credentials:
        #import os
        #import ConfigParser
        #path = os.path.expanduser('~/.wps/config'))
        #config = ConfigParser.ConfigParser()
        #f = open(path)
        #config.readfp(f)
        #user = config.get('matlab_ftp', 'user')
        #passwd = config.get('matlab_ftp', 'password')
        #f.close()
        
        user = ""
        passwd = ""
        
        #FTP folders
        host = "viewer.openearth.nl"
        path = "htdocs/php/tool/input/"
        status = "htdocs/php/tool/status/"
        outputfolder = "htdocs/php/tool/output/"
        kmlfolder = "htdocs/php/tool/kml/"
        
        #Login to server
        server = ftplib.FTP(host=host, user=user, passwd=passwd)
        server.dir()
        server.cwd(path)

        #Definition of user identifiers
        userIP = socket.gethostbyname(socket.gethostname())
        #userID = 'jTEST'
        
        #Generation of new unique 5 digit code
        def newcode(server, path='/srv/www/htdocs/php/tool/status'):
            codes_in_use = set()
            pattern = re.compile(r'_([A-Za-z]{5})\.')
            for fname in server.nlst(path):
                match = pattern.search(os.path.split(fname)[-1])
                if match:
                    codes_in_use.add(match.group(1))
            for i in xrange(10000):
                code = "".join(random.choice(string.ascii_letters) for i in range(5))
                if not code in codes_in_use:
                    return code
                
        #Generate new code
        uID = newcode(server)

        #Create XML file
        E = lxml.builder.ElementMaker()

        xml = E.xml
        sessionID = E.sessionID
        uniqueID = E.uniqueID
        IP = E.IP
        weburl = E.weburl
        function = E.function
        tool = E.tool
        toolid = E.toolid
        data = E.data
        type = E.type
        features = E.features
        properties = E.properties
        style = E.style
        fillColor = E.fillColor
        fillOpacity = E.fillOpacity
        hoverFillColor = E.hoverFillColor
        hoverFillOpacity = E.hoverFillOpacity
        strokeColor = E.strokeColor
        strokeOpacity = E.strokeOpacity
        strokeWidth = E.strokeWidth
        strokeLinecap = E.strokeLinecap
        strokeDashstyle = E.strokeDashstyle
        hoverStrokeColor = E.hoverStrokeColor
        hoverStrokeOpacity = E.hoverStrokeOpacity
        hoverStrokeWidth = E.hoverStrokeWidth
        pointRadius = E.pointRadius
        hoverPointRadius = E.hoverPointRadius
        hoverPointUnit = E.hoverPointUnit
        pointerEvents = E.pointerEvents
        cursor = E.cursor
        fontColor = E.fontColor
        labelAlign = E.labelAlign
        labelOutlineColor = E.labelOutlineColor
        labelOutlineWidth = E.labelOutlineWidth
        name = E.name
        lon = E.lon
        lat = E.lat
        time = E.time
        z = E.z
        s = E.s
        height = E.height
        grainsize = E.grainsize
        distribution = E.distribution
        fallvelocity = E.fallvelocity
        scenario = E.scenario
        particles = E.particles
        duration_IDT = E.duration_IDT
        seasonname = E.seasonname
        geometry = E.geometry
        coordinates = E.coordinates
        duration = E.duration
        scenarioname = E.scenarioname

        #Input paramters
        scname = str(self.scnameIn.getValue())
        lon1 = str(self.lon1In.getValue())
        lat1 = str(self.lat1In.getValue())
        lon2 = str(self.lon2In.getValue())
        lat2 = str(self.lat2In.getValue())
        nparticles = str(self.nparticlesIn.getValue())
        tduration = str(self.tdurationIn.getValue())

        doc = xml(
            uniqueID(uID),
            sessionID("jOOst"),
            IP(userIP),
            weburl("http://dtvirt5.deltares.nl/wps"),
            function("IDT_runWeb"),
            tool("Interactive Dredge Planning Tool"),
            toolid("IDT_Singapore"),
            data(
                 type("FeatureCollection"),
                 features(
                          type("feature"),
                          properties(
                                     style(
                                           fillColor("#ee9900"),
                                           fillOpacity("0.4"),
                                           hoverFillColor("white"),
                                           hoverFillOpacity("0.8"),
                                           strokeColor("#ee9900"),
                                           strokeOpacity("1"),
                                           strokeWidth("5"),
                                           strokeLinecap("round"),
                                           strokeDashstyle("solid"),
                                           hoverStrokeColor("red"),
                                           hoverStrokeOpacity("1"),
                                           hoverStrokeWidth("0.2"),
                                           pointRadius("6"),
                                           hoverPointRadius("1"),
                                           hoverPointUnit("%"),
                                           pointerEvents("visiblePainted"),
                                           cursor("inherit"),
                                           fontColor("#000000"),
                                           labelAlign("cm"),
                                           labelOutlineColor("white"),
                                           labelOutlineWidth("3")
                                           ),
                                     name("Track1"),
                                     lon(lon1),
                                     lon(lon2),
                                     lat(lat1),
                                     lat(lat2),
                                     time("0"),
                                     time("60"),
                                     z("0"),
                                     z("0"),
                                     s("100"),
                                     s("100"),
                                     height("5"),
                                     grainsize("20"),
                                     grainsize("40"),
                                     grainsize("63"),
                                     grainsize("0"),
                                     grainsize("0"),
                                     distribution("20"),
                                     distribution("30"),
                                     distribution("50"),
                                     distribution("0"),
                                     distribution("0"),
                                     fallvelocity("0.0003"),
                                     fallvelocity("0.0011"),
                                     fallvelocity("0.0027"),
                                     fallvelocity("0"),
                                     fallvelocity("0"),
                                     scenario(scname),
                                     particles(nparticles),
                                     duration_IDT(tduration),
                                     seasonname("January")
                                     ),
                          geometry(
                                   type("LineString"),
                                   coordinates("11542420.453158442"),
                                   coordinates("135221.54070235384"),
                                   coordinates("11547006.674854577"),
                                   coordinates("138890.51805952715")
                                   )
                    ),
                seasonname("January"),
                duration(tduration),
                scenarioname(scname),
                particles(nparticles)
            )
            )
        
        #Save file on server
        doctxt = lxml.etree.tostring(doc, pretty_print=True)
        f = cStringIO.StringIO(doctxt)
        f.seek(0)
        server.storlines("STOR {}".format('input_'+uID+'.xml'), f)
        
        #After storing the input XML file on the server, Matlab automatically
        #starts calculating. The status of the calculations is given in a status
        #file. 
        
        #Reading process status
        import time
        time.sleep(3) #Time required for the ftp to store the file
        server = ftplib.FTP(host=host, user=user, passwd=passwd)
        server.cwd(status)
        #timeout = time.time() + 180
        status = 'start'
        a = 0
        status_old = status
        while status != 'Uploading output file':
            output = cStringIO.StringIO()
            statfile = server.retrlines("RETR {}".format('status_'+uID+'.xml'), output.write)
            output.seek(0)
            s = lxml.etree.parse(output)
            status = lxml.etree.tostring(s.find("status"))[8:-9]
            if status == 'Uploading output file':
                self.status.set(status, 95)
                self.status.set("Ready to access output files", 100)
                break    
            if status != status_old:
                self.status.set(status, a)
                a = a + 5
#            if time.time() > timeout:
#                self.satus.set("timeout", 0)
#                break
            status_old = status
            
        #Succesvolle run bestaat uit 19 stappen, per 'status-uitvoer' dus ongeveer 5% erbij.

        time.sleep(3) #Time required for the ftp to store the file

        #The location of the output files is stored in an XML file in the 
        #output folder.
        
        server = ftplib.FTP(host=host, user=user, passwd=passwd)
        server.cwd(outputfolder)

        output = cStringIO.StringIO()
        outfile = server.retrlines("RETR {}".format('output_'+uID+'.xml'), output.write)
        output.seek(0)
        s = lxml.etree.parse(output).findall("//kmlFile")

        trackfile = lxml.etree.tostring(s[0])[9:-13]
        sedimentfile = lxml.etree.tostring(s[1])[9:-13]
        ecofile = lxml.etree.tostring(s[2])[9:-13]

        print trackfile, sedimentfile, ecofile

        #The file names found in the output XML can be found in the KML folder
        server = ftplib.FTP(host=host, user=user, passwd=passwd)
        server.dir()
        server.cwd(kmlfolder)
        
        #The name of the actual KML file with the output is identical to the 
        #name of the zip file 
        
        kmlfilename = sedimentfile[:-3]+'kml'
        
        #The zipfile is written to the server's internal memory
        zipout = cStringIO.StringIO()
        server.retrbinary("RETR {}".format(sedimentfile), zipout.write)

        #The file stored in the internal memory is defined as a zip file
        fzip = zipfile.ZipFile(zipout)
        # extract the kml file
        
        foutput = cStringIO.StringIO()
        foutput.write(fzip.read(kmlfilename))
        foutput.seek(0)
        self.kmlOut.setValue(foutput)
        return     
        
        #np.savetxt('dataset.kml', np.array(kmloutput).reshape(1,), fmt='%1.4s')
        #kmloutput.seek(0)
        #np.savetxt('dataset.kml',kmldata)#,fmt="%s")
        #kmloutput.read()
        #f = kmloutput.getvalue()
        #The zipped KML file is written to an new kml file in the server's
        #internal memory
        #f = cStringIO.StringIO()
        #modout = fileoutput.read(kmlfile, f.write)
        #np.savetxt(f,modout,fmt="%s")
        #kmloutput.seek(0)

        #The zipped KML file is written to an new kml file in the server's
        #internal memory
        #kmloutput = cStringIO.StringIO()
        #fileoutput.read(kmlfile, kmloutput.write)
                       
        #The KML file is read
        #self.kmlOut.setValue(kmloutput.read())
        #return