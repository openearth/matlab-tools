# -*- coding: utf-8 -*-
"""
Created on Fri Aug 11 14:01:45 2017

- Master class for reading and plotting the csv outputs of the pre-processing

To fix:
Overuse of self
Class functions call each other, no clear modular setup.
Very odd casing
Time fitting is very unclear

@authors:
Ebi Meshkati Shahmirzadi <ebi.meshkatishahmirzadi@deltares.nl>
Joan Sala Calero <joan.salacalero@deltares.nl>
"""

# General imports
from scipy.optimize import curve_fit
from decimal import Decimal
import logging
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import scipy as sy
import os

## Main class for the post-processing of the columns
class Master(object):

    # Init main class of the post-processing
    def __init__(self, data, conf, output, coln, color="limegreen"):
        self.data = data
        self.coln = coln # column number [0...N]
        self.color = color  # used for plotting >> color of the mud/interface
        self.expdur = float(conf.expdur)  # used for plotting >> how many days exp lasts
        self.sample = conf.sample  # used for saving >> mud name
        self.c = float(conf.ci)  # concentration [g/l]
        self.cg = float(conf.cg)  # concentration [g/l]
        # initial water level of the settling column in [m]
        self.h_ini = float(conf.h_ini)
        self.rho_s = float(conf.rho_s)  # density of solids in [kg/m3]
        # density of water in [kg/m3](dependent on salinity)
        self.rho_w = float(conf.rho_w)
        # Output directory
        self.outdir = output  # output directory
        if not(os.path.exists(output)):
            os.mkdir(output)
        self.sandfrac = float(conf.sandfrac)  # fraction of sand present in sample
        self.t1 = float(conf.t1)  # time point start of the first phase of consolidation
        self.t2 = float(conf.t2)  # time point start of the second phase of consolidation
        self.h_finalbed = float(conf.h_final)

        # Calibration between pixels and meters - h[meters] = pix2m*h[pixels] + K2m
        self.pix2m = float(conf.pix2m)
        self.khm = float(conf.khm)

        # initial water content = mass of water / mass of dry material
        self.w_ini = float(conf.rho_w) / float(conf.ci)  # e.g.: 1.002/0.06
        self.conc_ini = str(conf.ci) + 'gpl'  # used for saving figure
        self.t, self.h = self.parse_column_data()
        self.cal_basic_params()

    # Setup startup parameters for the fitting
    def cal_basic_params(self):
        # Factors computed from constants above
        self.phi_0 = 1 / (1 + self.rho_s * (self.w_ini / self.rho_w))
        self.Delta = (self.rho_s - self.rho_w) / self.rho_w
        self.phi_sa0 = self.phi_0 * self.sandfrac
        self.phi_m0 = self.phi_0 * (1 - self.sandfrac)

        # Gibson or material height for fines or reduced Gibson height: same as zeta = h_ini*phi_0 when there is no sand in sample, but distinction between sand and fines included
        self.zeta_m = self.h_ini * self.phi_m0 / (1 - self.phi_sa0)
        self.zeta_s = self.h_ini * self.phi_sa0  # Gibson or material height for sand
        self.zeta = self.h_ini / (1 + self.rho_s * (self.w_ini / self.rho_w))
        self.rho_norm = ((self.rho_s - self.rho_w) / self.rho_w)

        logging.info('PARAMS: [phi_0 = {:.2f}, Delta = {:.2f}, w_ini = {:.2f}, zeta_m = {:.2f}, zeta_s = {:.2f}, zeta = {:.2f}, rho_norm = {:.2f}]'.format(
            self.phi_0, self.Delta, self.w_ini, self.zeta_m, self.zeta_s, self.zeta, self.rho_norm))
        self.get_xydata_phaseI()

    # Load the csv containing all the columns data from the pre-processing
    def parse_column_data(self):
        """Parse dataframe with initial height and return elapsed time and height."""
        df_data = self.data.dropna(how="any")
        df_data.loc[:, "pixel"] *= self.pix2m # to meters
        df_data.loc[:, "pixel"] += self.khm  # add constant
        df_data["height [m]"] = df_data["pixel"]
        df_data.loc[:, 'height [m]'] *= 0.01  # heights in [meter]
        df_data["date"] = pd.to_datetime(df_data["date"])
        # DO NOT SET BACK TO ZERO: df_data["elapsed time [s]"] = (df_data["date"] - df_data["date"].iloc[0]).astype("timedelta64[s]")
        df_data.drop_duplicates(subset=["date", "elapsed time [s]"], keep=False)
        t = df_data["elapsed time [s]"]
        h = df_data["height [m]"]

        df_data.to_csv(os.path.join(self.outdir, 'postproc_output_column_{}.csv'.format(self.coln)), sep=";", index=False)
        self.data = df_data
        return t, h

    # Slice dataframe with window between t_start and t_end.
    def get_xydata_phaseI(self):
        """Pass."""
        # read t in seconds, h in meters
        # t1 t2 are respectively the lower
        # and upper bound for timeframe selection
        trange = min(self.h), max(self.h)
        logging.info(
            "Timedelta ranges between {} and {} seconds".format(*trange))

        # If t1 doesn't match any existing timestep
        if not any(self.t == self.t1):
            logging.info("Find timesteps")
            t_1 = self.t[self.t < self.t1]
            t_1 = t_1.iloc[-1]
            t_2 = self.t[self.t > self.t1]
            t_2 = t_2.iloc[0]
            h1_1 = self.h[self.t == t_1]
            h1_1 = h1_1.iloc[0]
            h1_2 = self.h[self.t == t_2]
            h1_2 = h1_2.iloc[0]
            self.h1 = h1_1 - (h1_1 - h1_2) / (t_2 - t_1) * (self.t1 - t_1)
        # Otherwise h1 = h at t1
        else:
            logging.info('Direct timestamp match')
            self.h1 = self.h[self.t == self.t1].iloc[0]

        # Output df_ht_cal, self.xdata, self.ydata
        self.xdata = self.t[(self.t > self.t1) & (self.t < self.t2)]
        self.xdata = self.xdata.values.tolist()
        self.ydata = self.h[(self.t > self.t1) & (self.t < self.t2)]
        self.ydata = self.ydata.values.tolist()
        # self.h_at_t1 = (self.c * self.h_ini) / self.cg  # estimated height in the column when column should reach to structural density (cgel)
        self.h_at_t1 = self.h1
        index_h_t1 = (np.where(self.h < self.h_at_t1)[0][0])
        self.t_at_t1 = self.t.iloc[index_h_t1]
        self.h_at_t1 = self.h.iloc[index_h_t1]

        # Plot from origin to phase I start
        self.df_ht_cal = pd.DataFrame({'t_1 [s]': [0, self.t_at_t1], 'h_1 [m]': [0, self.h_at_t1]})
        self.cal_n_kk()

        return self.t, self.h

    # Slice dataframe with window between t_start and t_end. [equivalent to get_xydata_phaseI] - Missing the last part
    def timewindow(self):
        """
        Return elapsed time t, and height h for use in fitting and plotting.
        t_start and t_end are in seconds, meant for the column elapsed time [s].
        """
        # this could be separate call (in __init__), but we're mimicking get_xydata_phaseI
        self.parse_column_data()

        # Slice Dataframe between t_start with an inclusive range
        elapsed_t = self.data["elapsed time [s]"]
        windowed = self.data[(elapsed_t >= self.t1) & (elapsed_t <= self.t2)]

        # Sort by elapsed time
        windowed = windowed.sort_values(by="elapsed time [s]")

        # Separate time and height for use as x and y
        t, h = windowed["elapsed time [s]"], windowed["height [m]"]
        self.xdata = t.values.tolist()
        self.ydata = h.values.tolist()

        return t, h

    # no correction for sand
    def ht_phaseI_merkelbach_2000(self, x, n, kk):
        # 'y=gibson _sand +((gibson_mud*(2-n)/(1-n))^((1-n)/(2-n))) * (((n-2)*Kk*1.65)^(1/(2-n))) * x^(1/(2-n))’;
        return self.zeta_s + ((self.zeta_m * ((2 - n) / (1 - n)))**((1 - n) / (2 - n))) * (((n - 2) * kk * self.rho_norm)**(1 / (2 - n))) * ((x**(1 / (2 - n))))

    # Fitting [no correction for sand]
    def cal_n_kk(self):
        guess_n = 8
        guess_kk = 10**(-15)
        p0 = sy.array([guess_n, guess_kk])
        self.Xdata = np.array(self.xdata)
        self.Ydata = np.array(self.ydata)
        self.popt, self.pcov = curve_fit(self.ht_phaseI_merkelbach_2000, self.Xdata, self.Ydata, p0, maxfev=1000000)

        # Fitting output [see doi: 2348234]
        self.n = self.popt[0]
        self.D = 3 - 2 / self.n
        self.kk = self.popt[1]

        # Don't need it at the moment
        # self.cal_ksigma()
        # self.plot_fitted_line_phaseI()
        logging.info('FITTING: n={:.4f}, D={:.4f}, kk={:.8f}'.format(self.n, self.D, self.kk))

    # No correction for sand
    def cal_ksigma(self):
        """Not used at the moment!"""
        a = (self.h_finalbed - self.zeta_s) / ((self.n / ((self.n - 1) * (self.rho_s - self.rho_w)
                                                          * 9.8)) * ((self.rho_s - self.rho_w) * 9.8 * self.zeta_m) ** ((self.n - 1) / self.n))
        self.k_sigma = a ** (1 / (1 - (self.n - 1) / self.n))
        return self.k_sigma

    # Calculate the fitting line for phase I
    def cal_fitted_line_phaseI(self):
        ydata_fitted = self.ht_phaseI_merkelbach_2000(self.Xdata, *self.popt)
        X_firstphase = self.Xdata
        ydata_fitted = ydata_fitted
        return X_firstphase, ydata_fitted

    # Plot the fitting line
    def plot_fitted_line_phaseI(self):
        Xfirstphase, ydata_fitted = self.cal_fitted_line_phaseI()
        df_fitted = pd.DataFrame({'t_first_phase [s]': Xfirstphase, 'h_fitted_first_phase [m]': ydata_fitted})
        self.plotit(df_fitted)

    # General plot of the fitting
    def plotit(self, fitted):
        # Plot title
        kk_str = '%.2E' % Decimal(self.kk)
        title_str = 'Column = C{} with D={:.4f}, kk={}'.format(self.coln, self.D, kk_str)

        # Black line [Bed surface]
        df_th = pd.DataFrame({'t_1 [s]': [0, self.xdata[0]], 'h_1 [m]': [0, self.ydata[0]]})
        ax = df_th.plot(x="t_1 [s]", y="h_1 [m]", color=self.color, marker='o', markersize=1, label='Bed surface',
                        kind='line', grid=True, title=title_str, figsize=(16, 6), logx=True, logy=True)

        # Red line [the fitting]
        fitted.plot(x="t_first_phase [s]", y="h_fitted_first_phase [m]", color='red', label='Fitted_line',
                    kind='line', grid=True, ax=ax, title=title_str, logx=True, logy=True, linewidth=6)

        # Color line [the data, log axis]
        self.data.plot(x="elapsed time [s]", y="height [m]", color=self.color, marker='o', markersize=2, label='Water - mud interface',
                       kind='line', grid=True, ax=ax, title=title_str, logx=True, logy=True, linewidth=1)

        # Axis names
        ax.set_xlabel('elapsed time [s]')
        ax.set_ylabel('height [m]')
        plt.savefig(os.path.join(self.outdir, 'plot_postproc_column_{}.png'.format(self.coln)))


## TESTING
if __name__ == "__main__":
    # Color map for the plots
    cmap = ['sienna', 'darkviolet', 'green', 'darkorange', 'magenta', 'gold', 'limegreen',
            'blue', 'darkgray', 'pink', 'cyan', 'purple']  # every column one colour [red is forbidden]

    # Please fill this input values [explanation above]
    indir = "D:\sala\Documents\mudseries\IMAGES\CHATTAM_FAST\preprocess"
    outdir = "D:\sala\Documents\mudseries\IMAGES\CHATTAM_FAST\postprocess"

    # Fit and plot [post-processing]
    results = os.path.join(indir, 'columns.csv')
    config_file = os.path.join(indir, 'postproc_config.csv')
    config = pd.read_csv(config_file, delimiter=";")
    pre_result = pd.read_csv(results, delimiter=";")
    predata = pre_result.column.unique()

    # For every column
    for i, column in enumerate(predata):
        # Slice
        colconf = config[config.column == i].iloc[0]
        colresult = pre_result[pre_result.column == i]

        # CsvName ExpDur SampleName ColumnName Ci Cg H_ini Rho_s Rho_w SandFrac T1 T2 H_finalbed
        m = Master(colresult, colconf, outdir, i, color=cmap[i])
        m.get_xydata_phaseI()
        # m.timewindow()
        m.cal_n_kk()
        m.plot_fitted_line_phaseI()