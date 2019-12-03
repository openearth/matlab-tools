# -*- coding: utf-8 -*-
"""
Created on Mon Jul 14 11:32:05 2014

@author: tollena
"""

import string

NETW_CSV = "NETWORK.NTW"
CONF_CSV = "CONFFIL.NTW"
FOOT_TXT = 'CONFFILfooter.txt'

NETW=open(NETW_CSV, 'r')
FOOT=open(FOOT_TXT, 'r')
CONF=open(CONF_CSV, 'w+')
Read = True
SBK_TYPES = ['"SBK_SBK-3B-NODE_DIVERSION"','"SBK_SBK-3B-NODE_CONFLUENCE"','"SBK_BOUNDARY_TERMINAL"','"SBK_BOUNDARY_INFLOW"','"SBK_CHANNEL&LAT_DIVERSION"','"SBK_CHANNEL&LAT_NOTUSED"','"SBK_SBK-3B-NODE_WEIR"','"SBK_SBK-3B-NODE_RESERVOIR"','"SBK_SBK-3B-NODE_RUNOFFRIVER"']
RIB_TYPES = ['"RIB_DIV"','"RIB_CONFL"','"RIB_TERM"','"RIB_VARINF"','"RIB_QDV"','"RIB_QSW"','"RIB_DIV"','"RIB_RSV"','"RIB_RUNOFRIV"']
RIB_TIDS = [8,3,4,1,6,1,8,6,7]

linenumber = 0

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
            elif linesplit[14][1:4] == 'SWR':
                linesplit[14] = '"' + linesplit[14][4:len(linesplit[14])]
                linesplit[18] = '6'
                linesplit[19] = '"RIB_RSV"'
            elif linesplit[14][1:4] == 'ROR':
                linesplit[14] = '"' + linesplit[14][4:len(linesplit[14])]
                linesplit[18] = '7'
                linesplit[19] = '"RIB_RUNOFRIV"'
            elif linesplit[14][1:4] == 'DIV':
                linesplit[14] = '"' + linesplit[14][4:len(linesplit[14])]
                linesplit[18] = '8'
                linesplit[19] = '"RIB_DIV"'
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
            elif linesplit[27][1:4] == 'SWR':
                linesplit[27] = '"' + linesplit[27][4:len(linesplit[27])]
                linesplit[31] = '6'
                linesplit[32] = '"RIB_RSV"'
            elif linesplit[27][1:4] == 'ROR':
                linesplit[27] = '"' + linesplit[27][4:len(linesplit[27])]
                linesplit[31] = '7'
                linesplit[32] = '"RIB_RUNOFRIV"'
            elif linesplit[27][1:4] == 'DIV':
                linesplit[27] = '"' + linesplit[27][4:len(linesplit[27])]
                linesplit[31] = '8'
                linesplit[32] = '"RIB_DIV"'
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

for idx, line in enumerate(FOOT):
    linenumber += 1
    print "write line: " + str(linenumber)
    CONF.write(line)

CONF.close()
NETW.close()
FOOT.close()
           