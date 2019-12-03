# -*- coding: utf-8 -*-
"""
v0.2 21-8-2014
http://domeintabellen-idsw-ws.rws.nl/DomainTableWS.svc?wsdl

Domeintabellen soapie to csv
@author: Maarten Pronk

Best would be to have changes implemented, but could be deletions, ignore 
those. However, would need datecheck, which is irritating. 
If file is provided, update based on last_modified, otherwise download all.
"""

from datetime import datetime,date
from suds.client import Client
from suds.plugin import MessagePlugin
import csv
from lxml import etree

ns = '{http://rws.services.nl/DomainTableWS/Contracts/2010/10}'
url = 'http://domeintabellen-idsw-ws.rws.nl/DomainTableWS.svc?wsdl'
dt = ['Bemonsteringsapparaat','Bemonsteringsmethode','Compartiment','Eenheid',
      'Hoedanigheid','Kwaliteitsoordeel','Orgaan','Parameter',
      'Plaatsbepalingsapparaat','Waardebepalingsmethode',
      'Waardebewerkingsmethode']

def methods():
    client = Client(url)
    for method in client.wsdl.services[0].ports[0].methods.values():
        print method
#    print client
    
def request_tablenames():
    class Filter(MessagePlugin):  # SUDS fails at uuid around xml
        def received(self, context):
            reply = context.reply
            context.reply = reply[reply.find("<s:Envelope"):reply.rfind(">")+1]

    client = Client(url,plugins=[Filter()])

    req = client.factory.create('ns1:GetDomainTableNamesRequest')
    req.CheckDate = datetime.today()

    result = client.service['basic'].GetDomainTableNames(req)

    return result[0][0]
    
def request_table(tablename):
    """Requests all possible domain table names and returns them in a list."""
    class Filter(MessagePlugin):  # SUDS fails at uuid around xml
        def received(self, context):
            reply = context.reply
            context.reply = reply[reply.find("<s:Envelope"):reply.rfind(">")+1]


    client = Client(url,plugins=[Filter()])
    client.set_options(retxml=True)

    req = client.factory.create('ns1:GetDomainTableRequest')
    req.DomaintableName = tablename
    req.CheckDate = datetime.today()
    req.PageSize = 999
    req.StartPage = 0

    result = client.service['basic'].GetDomainTable(req)
    return result

def parser(result):
    """Parses raw soap xml into list in lists for every datarow.
    Parsed data is fit for csv writing."""
    data = []
    root = etree.fromstring(result)
    header = []
    if int(root.find('.//'+ns+'TotalDataRows').text) > 0:
        for names in root.find('.//'+ns+'Fields'):
            for name in names.iter(ns+'Name'): header.append(name.text)
        data.append(header)
        for thing in root.iter(ns+'Fields'):
            row = []
            for thingie in thing.iter(ns+'DataField'):
                for i in thingie:
                    if i.tag == ns+'Data':
                        row.append(i.text)
            data.append(row)
    return data

def writer(data,fn):
    with open('domeintabellen/new/'+fn+'.csv','w') as f:
        writer = csv.writer(f)
        writer.writerows(data)
    print fn+" written."

def download_all():
    for table in request_tablenames():
        if table != "RedenGebruikLocatie": # Die already!
            writer(parser(request_table(table)),table)

#download_all()
for table in dt:
    writer(parser(request_table(table)),table)

#print request_tablenames()
#d = request_table('RedenGebruikLocatie')
#print d
#p = parser(d)
#writer(p,'Mapping_SDN_L05_Bemonsteringsapparaat')
