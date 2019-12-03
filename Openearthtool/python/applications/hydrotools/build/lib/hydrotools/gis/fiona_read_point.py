# -*- coding: utf-8 -*-
"""
Created on Thu Jun 18 14:23:25 2015

@author: winsemi
"""
import fiona
def fiona_read_point(filename, file_format, properties):
    inp = fiona.open(filename, 'r')
    x = [f['geometry']['coordinates'][0] for f in inp]
    y = [f['geometry']['coordinates'][1] for f in inp]
    
    # now extract properties
    prop_dict = {}
    for prop in properties:
        prop_dict[prop] = [p['properties'][prop] for p in inp]
    inp.close()
    return x, y, prop_dict
