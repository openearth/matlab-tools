import json
import xlrd
import re
import os

def read(fname=r'rws_waterbase_name2standard_name.xls'):

    if os.path.exists(fname):
        book = xlrd.open_workbook(fname)
        sheet = book.sheet_by_index(0)
        dictionary = []
        
        firstline = True
        for i in range(sheet.nrows):
            if not re.match('^#',sheet.row(i)[0].value):
                if firstline:
                    header = [r.value.upper() for r in sheet.row(i)]
                    firstline = False
                else:
                    row = [r.value for r in sheet.row(i)]
                    rowdict = {'DONAR':{},'AQUO':{},'SDN':{}}
                    rowgroups = rowdict.keys()
                    for j,hdr in enumerate(header):
                        ingroup = False
                        for rowgroup in rowgroups:
                            if re.match(rowgroup+'_',hdr):
                                rowdict[rowgroup][re.sub('^'+rowgroup+'_','',hdr)] = row[j]
                                ingroup = True
                                break
                        if not ingroup:
                            rowdict[hdr] = row[j]
                    
                    dictionary.append(rowdict)
        del dictionary[0]
        
        return dictionary
        
def write(dictionary, fname='rws_waterbase_name2standard_name.json'):

    f = open(fname,'w')
    json.dump(dictionary,f)
    f.close()