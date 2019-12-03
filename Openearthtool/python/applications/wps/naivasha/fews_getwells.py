'''

http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=fews_getwells&datainputs=[parameterid=A.obs]
http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=getwaterabstraction&datainputs=[wellid=4284-20]
'''


import logging
from pywps.Process import WPSProcess                                
from naivasha import waterinformation


class Process(WPSProcess):
    def __init__(self):

        ##
        # Process initialization
        WPSProcess.__init__(self,
            identifier = "fews_getwells",
            title="Get wells from FEWS database",
            abstract="""This returns the wells as a GeoJSON file based on parameterid""",
            version = "1.0",
            storeSupported = True,
            statusSupported = True)


        self.textIn = self.addLiteralInput(identifier="parameterid",
                                           title     ="Parameter ID",
                                           type      =type(""),
                                           default   ="A.obs")

        ##
        # Adding process outputs

        self.Output1 = self.addComplexOutput(identifier  = "Locations",
                                             title       = "List of locations available for specified parameters",
                                             formats     = [{"mimeType":"text/json"}, # 1st is default
                                                           {'mimeType':"text/html"}])


    ##
    # Execution part of the process
    def execute(self):
        logging.info('in the process')
        #self.textOut.setValue( self.textIn.getValue() )
        #self.dataOut.setValue(r"C:\Program Files (x86)\Apache Software Foundation\Apache2.2\htdocs\mappingtools\htdocs\site-kenia\data\kenia.json")
        io = waterinformation.getwells(self.textIn.getValue())
        self.Output1.setValue(io)
        io.close()
        return
