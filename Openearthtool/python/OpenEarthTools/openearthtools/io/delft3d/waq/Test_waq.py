# -*- coding: utf-8 -*-
"""
Created on Mon May 19 12:26:50 2014

@author: gaytan_sa
"""
import matplotlib.pyplot as plt
import numpy as np
import waq as wq
import matplotlib.dates as date
from datetime import datetime
from corner2center import corner2center

FileName = 'p:/1201763-cobios-fews/waq/waq_runs/KNO-L/2003/nzbloom.map'
lgaFile  = 'p:/1209005-eutrotracks/KPP/DINEOF/com-001-2d.lga'

Sub = 'Chlfa'
Seg = [];
Time = 0;

s = wq.openfile(FileName)
g = wq.openlga(lgaFile)
    
time, data = wq.read(s,Sub,Seg,Time)

z = wq.ingrid(data,g)

plt.pcolor(g['X'], g['Y'], z)




# date.num2date(time)
