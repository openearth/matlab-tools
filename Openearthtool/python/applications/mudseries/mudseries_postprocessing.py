# -*- coding: utf-8 -*-
"""
Created on Fri Aug 11 14:01:45 2017

- From a given set of results from mudseries.py [mudlevel, time] csv's
- Outliers detection
- LogLog Plot time vs height
- Show plot + Selection of initial land final point of linear region of loglog plot.
- Fitting of the equation (merckelbach) in the linear loglog part.
- Save output of fitting: Kk and nf (or D).
- Linear trend indicators
- Store all choices from raw data to final result in text file: initial concentration, sand fraction, manual selection of points
- Settling phase Dankers equation

@authors:
Joan Sala Calero (joan.salacalero@deltares.nl)
"""

from datetime import datetime
import logging
import os
import pandas as pd

# Imports post-processing
from postprocessing_Master import Master


class Mudseries_Post():

    # Init
    def __init__(self, conf_file, preprocess_results, output):
        self.config = pd.read_csv(conf_file)
        self.pre_result = pd.read_csv(preprocess_results)
        self.output = output
        if not os.path.exists(self.output):
            os.makedirs(self.output)

    # Select a point
    def onselect(self, eclick, erelease):
        'eclick and erelease are matplotlib events at press and release'
        #self.ax.plot([eclick.xdata, erelease.xdata], [eclick.ydata, erelease.ydata])
        #self.ax.plot([eclick.xdata, erelease.xdata], [eclick.ydata, erelease.ydata])
        print[eclick.xdata, erelease.xdata]
        print[eclick.ydata, erelease.ydata]

    # --- MAIN --- #
    def run(self):
        # Logging
        logFile = os.path.join(self.output, 'mudseries_post_processing.log')
        logging.basicConfig(filename=logFile, level=logging.DEBUG,
                            format='%(asctime)s %(message)s')
        print("Log file available at: {}".format(logFile))
        logging.getLogger().addHandler(logging.StreamHandler())
        logging.info('Mudseries Post-processing START')

        cmap = ['sienna', 'darkviolet', 'green', 'darkorange', 'magenta', 'gold', 'limegreen',
                'blue', 'darkgray', 'pink', 'cyan', 'purple']  # every column one colour [red is forbidden]

        # Iterate over each column
        for i, column in enumerate(self.pre_result.column.unique()):
            logging.info('PROCESSING: {}'.format(i))

            # Slice specific column
            colconf = self.config[self.config.column == i].iloc[0]
            colresult = self.pre_result[self.pre_result.column == i]

            # CsvName ExpDur SampleName ColumnName Ci Cg H_ini Rho_s Rho_w SandFrac T1 T2 H_finalbed
            m = Master(colresult, colconf, self.output, color=cmap[i])
            logging.info('----------------------------------------------')
            #x, y = self.read_result_file(os.path.join(self.RES_DIR, r[0]))
            #fig = plt.figure(1)
            #plt.plot(x, y, color='g')
            #plt.loglog(x, y, color='b')
            # show()
