# -*- coding: utf-8 -*-
"""
Created on Wed Nov 09 13:51:31 2016

It was found at that adding files did not yield in proper indices
so from november 2016 it is possible to update the start number of the indices.

@author: hendrik_gt
"""

import sqlfunctions

credentials['user'] = 'postgres'
credentials['host'] = 'localhost'
credentials['dbname'] = 'emodnet'
credentials['password'] = 'ghn@DELTARES'
credentials['port'] = '5433'

dcttables = {}
dcttables['cdi'] = 'cdi_id_seq'
dcttables['edmo'] = 'edmo_id_seq1'
dcttables['observation'] = 'observation_id_seq1'
dcttables['odvfile'] = 'odvfile_id_seq'

# for each table in lsttables get max(id)
for tbl in dcttables.keys():
    strSql = """SELECT MAX(id) from {t}""".format(t=tbl)
    maxid = sqlfunctions.executesqlfetch(strSql,credentials)[0][0]

    # sql to update the sequence
    strSql = """
    ALTER SEQUENCE {seq} RESTART WITH {id}
    """.format(seq=dcttables[tbl],id=maxid+1)
    sqlfunctions.perform_sql(strSql,credentials)
    