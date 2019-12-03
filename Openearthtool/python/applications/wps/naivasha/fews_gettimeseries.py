'''

http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=fews_gettimeseries&datainputs=[parameterid=H.obs;locationid=2GD1]
http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=fews_gettimeseries&datainputs=[parameterid=H.obs;locationid=2GD1;startdate=1980-01-01;enddate=1980-12-31]

Repository information:
Date of last commit:     $Date: 2015-06-15 00:04:54 -0700 (Mon, 15 Jun 2015) $
Revision of last commit: $Revision: 11987 $
Author of last commit:   $Author: hendrik_gt $
URL of source:           $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/naivasha/fews_gettimeseries.py $
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
            identifier = "fews_gettimeseries",
            title="Get timesseries from FEWS database for specific location id and parameter id",
            abstract="""This returns a timeseries as a JSON file based on parameterid and location id
            """,            
            version = "1.1",
            storeSupported = True,
            statusSupported = True)
        
        
        self.parameterID = self.addLiteralInput(identifier="parameterid",
                                           title          ="Parameter ID",
                                           type           =type(""),
                                           default        ="H.obs")
                                           
        self.locationID = self.addLiteralInput(identifier ="locationid",
                                           title          ="Location ID",
                                           type           =type(""),
                                           default        ="2GD1")
        
        self.sdate = self.addLiteralInput(identifier      ="startdate",
                                           title          ="Start date for data collection",
                                           type           =type(""),
                                           default        ="19800101")
                                           
        self.edate = self.addLiteralInput(identifier      ="enddate",
                                           title          ="End date for data collection",
                                           type           =type(""),
                                           default        ="20000101")                                                   
        ##
        # Adding process outputs
        
        self.Output1 = self.addComplexOutput(identifier  = "timeseries",
                                             title       = "Timeseries for specified parameter and locationid",
                                             formats     = [{"mimeType":"text/plain"}, # 1st is default
                                                           {'mimeType':"text/html"}])


    ##
    # Execution part of the process
    def execute(self):
        logging.info('parameterID ' + self.parameterID.getValue())
        logging.info('location    ' + self.locationID.getValue())
        if self.sdate.getValue() == 'NoneType':
            logging.info('start date is null ')
        if len(self.sdate.getValue()) <8:
            logging.info('start date if null ' + self.sdate.getValue())
            if len(self.edate.getValue()) <8:
                logging.info('end date if null ' + self.edate.getValue())
                io = waterinformation.gettimeseries(self.parameterID.getValue(),self.locationID.getValue(),'19810101','19820101')
        else:
            io = waterinformation.gettimeseries(self.parameterID.getValue(),self.locationID.getValue(),self.sdate.getValue(),self.edate.getValue())
        logging.info('start date  ' + self.sdate.getValue())
        logging.info('end date    ' + self.edate.getValue())
        
        if not io:
            self.Output1.setValue('no data retrieved')
        else:
            self.Output1.setValue(io)
            io.close()
        return
