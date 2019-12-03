import pandas as pd
import numpy as np
import datetime as dt

# Author: Joan Sala Calero
# CLASS to generate bokeh plots for Fiber optics data [Pole experiment]
class PoleFile:
    def __init__(self, poleExpFile, poleHeightFile, cut_t0, cut_t1, cut_t2, offset_t0, offset_t1, cut_begin=0, cut_end=1.5):
        self.flippedPole = False
        self.poleExpFile = poleExpFile
        self.poleHeightFile = poleHeightFile
        self.cut_begin = cut_begin
        self.cut_end = cut_end
        self.cut_dt_t0 = dt.datetime.strptime(cut_t0, "%m/%d/%Y %H:%M:%S")
        self.cut_dt_t1 = dt.datetime.strptime(cut_t1, "%m/%d/%Y %H:%M:%S")
        self.cut_dt_t2 = dt.datetime.strptime(cut_t2, "%m/%d/%Y %H:%M:%S")
        self.offset_t0 = offset_t0
        self.offset_t1 = offset_t1

        # Read and cut data
        self.readAll()
        self.cutPole()
        self.cutTime()

    def readAll(self):
        self.df = pd.read_csv(self.poleExpFile)
        self.distance = self.df.ix[:, 0]
        self.timestr = list(self.df.columns.values)[1:]
        self.date = self.timestr[0].split(' ')[0]
        self.dfh = pd.read_csv(self.poleHeightFile, header=None)
        self.height = self.dfh.ix[:, 0]
        self.tempmatrix = self.df.drop('Distance', 1).values  # All temperatures
        self.meantemp = self.tempmatrix.mean(axis=1)  # Mean temperature over time
        if len(self.distance) != len(self.height):
            print 'ERR: #Samples_Distance = {} vs #Samples_Height = {}'.format(len(self.distance),len(self.height))
            exit(-1)

        # Get elapsed time
        self.time = [dt.datetime.strptime(d, "%m/%d/%Y %H:%M:%S") for d in self.timestr]
        self.t00 = self.time[0]
        self.elapsedTime = [(t - self.t00).seconds for t in self.time]

    def cutPole(self):
        idx0 = (np.abs(self.height - self.cut_begin)).idxmin()
        idx1 = (np.abs(self.height - self.cut_end)).idxmin()
        if idx0 > idx1: # upside down pole?
            tmp = idx0
            idx0 = idx1
            idx1 = tmp
            self.flippedPole = True
        self.df_cut = self.df[idx0:idx1]
        self.distance_cut = self.distance[idx0:idx1].values
        self.height_cut = self.height[idx0:idx1].values
        self.tempmatrix_cut = self.df_cut.drop('Distance', 1).values  # All temperatures
        self.meantemp_cut = self.tempmatrix_cut.mean(axis=1)  # Mean temperature over time
        if len(self.distance_cut) != len(self.height_cut):
            print 'ERR: #Samples_Distance_CUT = {} vs #Samples_Height_CUT = {}'.format(len(self.distance_cut),len(self.height_cut))
            exit(-1)

    def cutTime(self):
        # Time on/off heating [experiment] - Elapsed time
        self.cut_t0 = (self.cut_dt_t0 - self.t00).seconds
        self.cut_t1 = (self.cut_dt_t1 - self.t00).seconds
        self.cut_t2 = (self.cut_dt_t2 - self.t00).seconds

        self.idt0, self.val0 = min(enumerate(self.elapsedTime), key=lambda x: abs(x[1] - self.cut_t0))
        self.idt1, self.val1 = min(enumerate(self.elapsedTime), key=lambda x: abs(x[1] - self.cut_t1))
        self.idt2, self.val2 = min(enumerate(self.elapsedTime), key=lambda x: abs(x[1] - self.cut_t2))

        print [self.cut_dt_t0, self.cut_t0, self.idt0, self.val0]
        print [self.cut_dt_t1, self.cut_t1, self.idt1, self.val1]
        print [self.cut_dt_t2, self.cut_t2, self.idt2, self.val2]

        # Fixed offset before start and end experiment
        self.idt0_off, self.val0_off = min(enumerate(self.elapsedTime), key=lambda x: abs(x[1] - (self.cut_t0 - self.offset_t0)))
        self.idt1_off, self.val1_off = min(enumerate(self.elapsedTime), key=lambda x: abs(x[1] - (self.cut_t1 + self.offset_t1)))