'''
http://svnbook.red-bean.com/en/1.4/svn.advanced.props.special.keywords.html
http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=fews_getlocations&datainputs=[parameterid=A.obs]
http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=fews_getlocations&datainputs=[parameterid=A.obs;datestart=1900101;dateend=19951231]
Repository information:
Date of last commit:     $Date: 2015-04-08 22:18:17 -0700 (Wed, 08 Apr 2015) $
Revision of last commit: $Revision: 11862 $
Author of last commit:   $Author: hendrik_gt $
URL of source:           $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/naivasha/fews_getlocations.py $
CodeID:                  $ID$
'''


import logging
from pywps.Process import WPSProcess                                
from naivasha import waterinformation


class Process(WPSProcess):
    def __init__(self):

        ##
        # Process initialization
        WPSProcess.__init__(self,
            identifier = "fews_getlocations",
            title="Get location from FEWS database",
            abstract="""This returns the locations as a GeoJSON file based on parameterid
            start date and end date
            """,
            version = "1.2",
            storeSupported = True,
            statusSupported = True)


        self.textIn = self.addLiteralInput(identifier="parameterid",
                                           title     ="Parameter ID",
                                           type      =type("parameter"),
                                           default   ="H.obs")
#        self.sdate = self.addLiteralInput(identifier      ="startdate",
#                                           title          ="Start date for data collection",
#                                           type           =type("date"),
#                                           default        ="1990-01-01")
#        self.edate = self.addLiteralInput(identifier      ="enddate",
#                                           title          ="End date for data collection",
#                                           type           =type("date"),
#                                           default        ="2000-01-01")                                             
        ##
        # Adding process outputs

        self.Output1 = self.addComplexOutput(identifier  = "Locations",
                                             title       = "List of locations available for specified parameters",
                                             formats     = [{"mimeType":"text/plain"}, # 1st is default
                                                           {'mimeType':"text/html"}])


    ##
    # Execution part of the process
    def execute(self):
        logging.info('in the process fews.getlocations')
        logging.info('parameterID '+ self.textIn.getValue())
#        logging.info('start date ' + self.sdate.getValue())
#        logging.info('end data '   + self.edate.getValue())
        #self.textOut.setValue( self.textIn.getValue() )
        #self.dataOut.setValue(r"C:\Program Files (x86)\Apache Software Foundation\Apache2.2\htdocs\mappingtools\htdocs\site-kenia\data\kenia.json")
        io = waterinformation.getlocation(self.textIn.getValue())
#        io = waterinformation.getlocation2(self.textIn.getValue())
        self.Output1.setValue(io)
        io.close()
        return
