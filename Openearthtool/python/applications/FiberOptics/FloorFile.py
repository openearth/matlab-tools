import pandas as pd
import numpy as np
import datetime as dt
from datetime import timedelta

# Author: Joan Sala Calero
# CLASS to generate bokeh plots for Fiber optics data [Floor experiment]
class FloorFile:
    def __init__(self, floorExpFile, cut_begin, cut_end, time_offset=0):
        self.flippedPole = False
        self.floorExpFile = floorExpFile
        self.cut_begin = cut_begin
        self.cut_end = cut_end
        self.readAll(time_offset)
        self.cutDist()

    def readAll(self, time_offset):
        self.df = pd.read_csv(self.floorExpFile)
        self.distance = self.df.ix[:, 0]
        self.timestr = list(self.df.columns.values)[1:]
        self.date = self.timestr[0].split(' ')[0]
        self.tempmatrix = self.df.drop('Distance', 1).values  # All temperatures
        self.meantemp = self.tempmatrix.mean(axis=1)  # Mean temperature over time

        # Get elapsed time
        self.time = [dt.datetime.strptime(d.split('.')[0], "%m/%d/%Y %H:%M:%S") for d in self.timestr]
        if time_offset != 0:
            self.time = [dt.datetime.strptime(d.split('.')[0], "%m/%d/%Y %H:%M:%S") + timedelta(hours=time_offset) for d in self.timestr]

        self.t00 = self.time[0]
        self.elapsedTime = [(t - self.t00).seconds for t in self.time]

    # Cut a data file by two distance values
    def cutDist(self):
        self.idx0 = (np.abs(self.distance - self.cut_begin)).idxmin()
        self.idx1 = (np.abs(self.distance - self.cut_end)).idxmin()
        self.df_cut = self.df[self.idx0:self.idx1]                                            # subselection dataframe
        self.distance_cut = self.distance[self.idx0:self.idx1].values                         # Subselection distance
        self.tempmatrix_cut = self.df_cut.drop('Distance', 1).values                          # All temperatures within x0/x1
        self.meantemp_cut = self.tempmatrix_cut.mean(axis=1)                                  # Mean temperature over time

    # Cut a full data file by two time values
    def cutTime(self, date_str, t0_str, t1_str):
        self.t0 = (dt.datetime.strptime(date_str + ' ' + t0_str, "%d-%m-%y %H:%M:%S") - self.t00).seconds
        self.t1 = (dt.datetime.strptime(date_str + ' ' + t1_str, "%d-%m-%y %H:%M:%S") - self.t00).seconds
        self.idt0, self.val0 = min(enumerate(self.elapsedTime), key=lambda x: abs(x[1] - self.t0))
        self.idt1, self.val1 = min(enumerate(self.elapsedTime), key=lambda x: abs(x[1] - self.t1))
        self.elapsedTime_timeslice = self.elapsedTime[self.idt0:self.idt1]              # Subselection time
        self.df_timeslice = self.df_cut.iloc[:, self.idt0:self.idt1]
        self.tempmatrix_timeslice = self.tempmatrix_cut[:, self.idt0:self.idt1]         # All temperatures within t0/t1 x0/x1
        self.meantemp_timeslice = self.tempmatrix_timeslice.mean(axis=1)                # Mean temperature over time
        self.tempt0_timeslice = self.df_cut.values[:,self.idt0]                         # T0 time series
        self.tempt1_timeslice = self.df_cut.values[:,self.idt1]                         # T1 time series

    def selDist(self, selected_distance):
        idx = (np.abs(self.distance - selected_distance)).idxmin()
        return self.tempmatrix[idx, :]
