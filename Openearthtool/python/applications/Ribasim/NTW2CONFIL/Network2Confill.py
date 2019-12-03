# -*- coding: utf-8 -*-
"""
NTW2CONFIL

AUTHOR:     Daniel Tollenaar
Email:      daniel.tollenaar@deltares.nl
Version:    12 August 2014

Documentation:  NTW2CONFIL.docx

General description:
This script converts a network.ntw file used in Sobek to a confil.ntw file used in RIBASIM.  Current version translates rivers, inflows, terminals, reservoirs, diversions and runoff-rivers. A conversion can be made in two steps:
1.	Re-import your Sobek-network using custom-node types (in ntrpluv.obj)
2.	Convert your network.ntw file to a confil.ntw file using ntw2confil.py and open it in Ribasim

Procedure
1.	Open the existing SOBEK-schematisation you would like to convert in Netter (Edit Model).
2.	Go to File -> Export ->  GIS-file ->  Reaches to export your reach layer. 
3.	Close Netter and save as a new case (e.g. “ForRibasim”)
4.	Select 1DWAD in settings
5.	Double-click on schematization evoking the schematization popup menu
6.	Copy NTRPLUV.OBJ to the work-folder of your sobek-model and open Netter (Edit Model)
7.	Delete your entire network
8.	Import the reach layer you exported at 2 by choosing File -> Import.  Choose default settings for the popup window. 
9.	Click on the Advanced… button, select the Node types tab and choose:
        •	Boundary in 		67 Inflow
        •	Boundary out		66 Terminal
        •	Confluence		      68 Confluence
        •	Diversion		      69 Diversion
        •	Calculation point	16 Flow – Calculation Point
10.	Copy the network.ntw file to the same folder as ntw2confil.py and run the python-script. It should create a confil.ntw file
11.	Open Ribasim, add a basin, make a new case, select scenario’s, specify simulation control data and double-click on edit network, evoking the edit data popup menu
12.	Copy the generated confil.ntw file to the work-directory of your Ribasim basin, overwriting the old one
13.	Open Netter (Edit network and object data) from the edit data popup menu in Ribasim. Your converted model should appear.
"""

import string

NETW_CSV = "NETWORK.NTW"
CONF_CSV = "CONFFIL.NTW"

NETW=open(NETW_CSV, 'r')
CONF=open(CONF_CSV, 'w+')
SBK_TYPES = ['"SBK_SBK-3B-NODE_DIVERSION"','"SBK_SBK-3B-NODE_CONFLUENCE"','"SBK_BOUNDARY_TERMINAL"','"SBK_BOUNDARY_INFLOW"','"SBK_CHANNEL_DIVERSION"','"SBK_CHANNEL&LAT_NOTUSED"','"SBK_SBK-3B-NODE_WEIR"','"SBK_SBK-3B-NODE_RESERVOIR"','"SBK_SBK-3B-NODE_RUNOFF"']
RIB_TYPES = ['"RIB_DIV"','"RIB_CONFL"','"RIB_TERM"','"RIB_VARINF"','"RIB_QDV"','"RIB_QSW"','"RIB_DIV"','"RIB_RSV"','"RIB_RUNOFRIV"']
RIB_TIDS = [8,3,4,1,6,1,8,6,7]


def footer(document):
    print "writing footer"
    document.write('\n')
    document.write('[Model connection node]\n')
    document.write('"1.00"\n')
    document.write('0\n\n')
    document.write('[Model connection branch]\n')
    document.write('"1.00"\n')
    document.write('0\n\n')
    document.write('[Nodes with calculationpoint]\n')
    document.write('"1.00"\n')
    document.write('0\n\n')
    document.write('[NTW properties]\n')
    document.write('"1.00"\n')
    document.write('3\n')
    document.write('v1=4\n')
    document.write('v2=0\n')
    document.write('v3=985\n')


linenumber = 0
Read = True

for idx, line in enumerate(NETW):
    if idx == 0:
        linenumber += 1
        print "write line: " + str(linenumber)
        CONF.write(line)
    else:
        if line == '"*"\n':
            Read = False
            CONF.write('"*"\n')
            linenumber += 1
            print "write line: " + str(linenumber)
        if Read == True:
            linenumber += 1
            print "write line: " + str(linenumber)
            linesplit = string.split(line, ",")
            linesplit[0] = '"' + str(idx) + '"'
            linesplit[2] = '0'
            linesplit[10] = '0'
            linesplit[17] = '0'
            linesplit[24] = '0'
            linesplit[30] = '0'
            linesplit[37] = '0'
            if linesplit[5] == '""':
                linesplit[4] = '"RIB_QSW"'
                linesplit[3] = '1'
            else:
                linesplit[4] = RIB_TYPES[SBK_TYPES.index(linesplit[5])]
                linesplit[3] = str(RIB_TIDS[SBK_TYPES.index(linesplit[5])])                   
            if linesplit[14][1:4] == 'PWS':
                linesplit[14] = '"' + linesplit[14][4:len(linesplit[14])]
                linesplit[18] = '10'
                linesplit[19] = '"RIB_PWS"'
            elif linesplit[14][1:4] == 'IRR':
                linesplit[14] = '"' + linesplit[14][4:len(linesplit[14])]
                linesplit[18] = '25'
                linesplit[19] = '"RIB_ADVIR"'
            else:
                linesplit[18] = str(RIB_TIDS[SBK_TYPES.index(linesplit[20])]) 
                linesplit[19] = RIB_TYPES[SBK_TYPES.index(linesplit[20])]                   
                                   
            if linesplit[27][1:4] == 'PWS':
                linesplit[27] = '"' + linesplit[27][4:len(linesplit[27])]
                linesplit[31] = '10'
                linesplit[32] = '"RIB_PWS"'
            elif linesplit[27][1:4] == 'IRR':
                linesplit[27] = '"' + linesplit[27][4:len(linesplit[27])]
                linesplit[31] = '25'
                linesplit[32] = '"RIB_ADVIR"'
            else:
                linesplit[31] = str(RIB_TIDS[SBK_TYPES.index(linesplit[33])])
                linesplit[32] = RIB_TYPES[SBK_TYPES.index(linesplit[33])] 
            linesplit[25] = '"SYS_WATER"'
            linesplit[38] = '"SYS_WATER"'
            linesplit[5] = '""'
            linesplit[20] = '""'
            linesplit[33] = '""'
            newline = string.join(linesplit,",")
            CONF.write(newline)
            
footer(CONF)

CONF.close()
NETW.close()
           