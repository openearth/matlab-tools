# -*- coding: utf-8 -*-
"""
Created on Mon Jun 18 14:42:47 2012

@author: schelle
"""


import numpy
import matplotlib as mpl
#mpl.use('Agg')
import matplotlib.pyplot as plt
import datetime
import pandas
import pcrut
from stats import *



fname = 'run.tss'
obs,head=pcrut.readtss(fname)
pers = numpy.size(obs,axis=0)

i=0    
print head

for location in head:
    
    print i
    #trange = pandas.DatetimeIndex(datetime.datetime(1985,1,1),periods=pers,offset=pandas.DateOffset())
    ts = pandas.Series(obs[:,i],index=pandas.date_range('1/1/1985',periods=pers))
    
    plt.figure(i)
    plt.autoscale(enable=True)
    ts.plot(label='Observed',color='blue')
    plt.title(location) 
    plt.legend()
    i = i + 1
    
plt.show()