import numpy as np
import os

class PeakOverThreshold:
    def __init__(self, data, threshold):
        self.reset(threshold)
        return self.process(data, threshold)

    def __call__(self, data, threshold):
        self.reset(self, threshold)
        return self.process(self, data, threshold)

    def reset(self, threshold):
        self.threshold = threshold
        self.peaks = np.array([], dtype='float64')
        self.indices = np.array([], dtype='int')

        self.ind_start = np.array([], dtype='int')
        self.ind_end = np.array([], dtype='int')
        self.NoP = np.array([], dtype='int')


    def process(self, data, threshold):
        nan_indices = np.where(np.isnan(data))
        nonan_indices = np.where(~np.isnan(data))        
        data_transl = data - threshold        
        flag_above = np.zeros_like(data_transl)-1
        flag_above[nonan_indices] = np.sign(data_transl[nonan_indices])

        crossing_up = np.where(np.diff(flag_above) >=1)
        crossing_down = np.where(np.diff(flag_above) <= -1)

        for ii in range(crossing_up[0].shape[0]):
            self.ind_start = np.append(self.ind_start,
                                       int(crossing_up[0][ii]))

            if nan_indices[0].shape[0] == 0:
                if np.where((crossing_down[0] > crossing_up[0][ii]))[0].shape[0]>0:
                    self.ind_end = np.append(self.ind_end,
                                            int(crossing_down[0][np.argmax(crossing_down[0] > crossing_up[0][ii])]))
                else:
                    self.ind_end = np.append(self.ind_end, int(data.shape[0]))
            else:
                if np.where((crossing_down[0] > crossing_up[0][ii]))[0].shape[0] > 0:
                    if np.where(nan_indices[0] > crossing_up[0][ii])[0].shape[0]==0:
                        self.ind_end = np.append(self.ind_end,
                                                 int(crossing_down[0][np.argmax(crossing_down[0] > crossing_up[0][ii])]))
                    else:
                        self.ind_end = np.append(self.ind_end,
                                         int(np.min([crossing_down[0][np.argmax(crossing_down[0] > crossing_up[0][ii])],
                                                     nan_indices[0][np.where(nan_indices[0] > crossing_up[0][ii] + 1)[0][0]]])))
                else:
                    self.ind_end = np.append(self.ind_end, int(data.shape[0]))

            self.NoP =  np.append(self.NoP,
                                  self.ind_end[-1]-self.ind_start[-1]+1)

            if self.ind_end[-1]+1-self.ind_start[-1]>0:
                self.peaks = np.append(self.peaks,np.nanmax(data[self.ind_start[-1]:self.ind_end[-1]+1]))
            else:
                self.peaks = np.append(self.peaks, data[self.ind_start[-1]])

            self.indices = np.append(self.indices,
                                     self.ind_start[-1]+np.where(data[self.ind_start[-1]:self.ind_end[-1]+1]==self.peaks[-1]))
            # pot(ii).PeakIndex = pot(ii).start + find(pot(ii).data == pot(ii).PeakValue) - 1;

        data[nan_indices]=np.nan

class PeakOverPeriod:
    def __init__(self, time, data, interval):
        self.reset(interval)
        return self.process(time, data, interval)

    def __call__(self, time, data, interval):
        self.reset(self, interval)
        return self.process(self, time, data, interval)

    def reset(self, interval):
        self.interval = interval
        self.peaks = np.array([], dtype='float64')
        self.indices = np.array([], dtype='int')

        self.ind_start = np.array([], dtype='int')
        self.ind_end = np.array([], dtype='int')

    def process(self, time, data, interval):
        dT = np.timedelta64(interval, 'D')
        NoI = np.ceil((time[-1]-time[0]).astype('timedelta64[D]')/dT)

        # analyse intervals 0 to NoI-1
        for ii in np.arange(0, NoI-1,1):
            self.ind_start = np.append(self.ind_start, np.argmax(time>time[0] + ii * dT))
            self.ind_end = np.append(self.ind_end, np.argmax(time>time[0] + (ii+1) * dT)-1)

            # if self.ind_start[-1]==self.ind_end[-1]:
            #     continue

            data_interval=data[self.ind_start[-1]: self.ind_end[-1]]

            if data_interval.shape[0]>0:
                if data_interval.shape[0] > np.where(np.isnan(data_interval))[0].shape[0]:
                    self.peaks = np.append(self.peaks, np.nanmax(data_interval))
                    self.indices = np.append(self.indices, self.ind_start[-1]+np.where(data_interval==self.peaks[-1])[0])

        # Now do the last interval
        self.ind_start = np.append(self.ind_start, np.argmax(time > time[0] + (NoI-1) * dT))
        self.ind_end = np.append(self.ind_end, time.shape[0])
        data_interval = data[self.ind_start[-1]: self.ind_end[-1]]

        if data_interval.shape[0]>0:
            if data_interval.shape[0] > np.where(np.isnan(data_interval))[0].shape[0]:
                self.peaks = np.append(self.peaks, np.nanmax(data_interval))
                self.indices = np.append(self.indices, self.ind_start[-1] + np.where(data_interval == self.peaks[-1])[0])




