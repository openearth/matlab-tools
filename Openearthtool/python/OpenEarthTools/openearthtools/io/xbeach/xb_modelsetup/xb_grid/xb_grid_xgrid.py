import numpy as np
from scipy.interpolate import interp1d
from OpenEarthTools.physics import disper
class Grid(object):
    # grid = Grid()

    def __init__(self, xin=None, zin=None, **kwargs):#, xin, zin
        self.OPT = {'xgrid' : [],                # predefined xgrid vector
               'Tm' : 5,                    # incident short wave period (used for maximum grid size at offshore boundary) if you impose time series of wave conditions use the min(Tm) as input
               'dxmin' : 2,                 # minimum required cross shore grid size (usually over land)
               'dxmax' : float('Inf'),      # user-specified maximum grid size, when usual wave period / CFL condition does not suffice
               'vardx' : True,              # False = constant dx, True = varying dx
               'g' : 9.81,                  # gravitational constant
               'CFL' : 0.9,                 # Courant number
               'dtref' : 4,                 # Ref value for dt in computing dx from CFL
               'maxfac' : 1.15,             # Maximum allowed grid size ratio
               'wl' : 0,                    # Water level elevation used to estimate water depth
               'depthfac': 2,               # Maximum gridsize to depth ratio
               'ppwl' : 12,                 # desired points per wavelength
               'nonh' : False,              # setting grid to solve individual short waves instead of infragravity waves
               'dxdry' : [],                # grid size to use for dry cells
               'zdry' : [],                 # vertical level above which cells should be considered dry
               'xdry' : [],                 # horizontal (cross-shore) level from which cells should be considered dry
               }
        if kwargs is not None:
            for key, value in kwargs.items():
                self.OPT[key] = value

    def xb_grid_xgrid(self, xin, zin):

        if not self.OPT['dxdry']:
            self.OPT['dxdry'] = self.OPT['dxmin']
        if not self.OPT['zdry']:
            self.OPT['zdry'] = self.OPT['wl']

        # remove nan values from zin
        xin, zin = np.array(xin), np.array(zin)
        xin, zin = xin[np.isfinite(zin)], zin[np.isfinite(zin)]

        # set boundaries
        xend = xin[-1]
        xstart = xin[0]
        xlast = xstart

        if not self.OPT['vardx']:
            #TODO
            pass
        elif self.OPT['vardx'] and len(self.OPT['xgrid']):
            #TODO
            pass
        elif self.OPT['vardx']:

            # prepare
            hin = [max(self.OPT['wl']-z, 0.01) for z in zin]
            xin2, indices = np.unique(xin, return_index=True)
            fhgr = interp1d(xin2, np.array(hin)[indices])
            fzgr = interp1d(xin2, np.array(zin)[indices])

            if self.OPT['nonh']:
                k = disper(2 * np.pi / self.OPT['Tm'], np.max(hin), self.OPT['g'])
            else:
                k = disper(np.pi / (2 * self.OPT['Tm']), np.max(hin), self.OPT['g']) # assume Tlong = 4 * Tshort, instead of Llong = 4*Lshort
            Llong = 2 * np.pi / k

            # grid settings
            ii = 0
            xgr = [xstart]
            zgr = [zin[0]]
            hgr = [hin[0]]
            dx = []
            while xlast < xend:
                # minimum grid size in the area
                if len(self.OPT['xdry']):
                    drycell = ii > self.OPT['xdry']
                else:
                    drycell = zgr[ii] > self.OPT['zdry']
                if drycell:
                    localmin = self.OPT['dxdry']
                else:
                    localmin = self.OPT['dxmin']

                # compute dx, minimum value dx (on dry land) = dxmin
                dxmax = min(Llong / self.OPT['ppwl'], self.OPT['dxmax'])
                dx.append(np.sqrt(self.OPT['g'] * hgr[ii]) * self.OPT['dtref'] / self.OPT['CFL'])
                dx[ii] = min(dx[ii], self.OPT['depthfac'] * hgr[ii])
                dx[ii] = max(dx[ii], localmin)
                if dxmax > localmin:
                    dx[ii] = min(dx[ii], dxmax)
                else:
                    dx[ii] = localmin
                    if ii == 0:
                        print('Computed dxmax (= ' + str(dxmax) + ' m) is smaller than the user defined dxmin (= ' + str(localmin) + ' m).\n'
                                'Grid will be generated using constant dx = dxmin.\nPlease change dxmin if this is not desired.')
                #
                if ii > 0:
                    if dx[ii] >= self.OPT['maxfac'] * dx[ii - 1]:
                        dx[ii] = self.OPT['maxfac'] * dx[ii - 1]
                    if dx[ii] <= 1. / self.OPT['maxfac'] * dx[ii - 1]:
                        dx[ii] = 1. / self.OPT['maxfac'] * dx[ii - 1]

                #
                ii += 1
                xgr.append(float(xgr[ii - 1] + dx[ii - 1]))
                xtemp = min(xgr[ii], xend)
                hgr.append(float(fhgr(xtemp)))
                zgr.append(float(fzgr(xtemp)))
                xlast = xgr[ii]

            print('Optimize cross-shore grid using CFL condition')

        else:
            print('vardx must be either True or False')

        return xgr, zgr

    # def xb_grid_extend():

# def fromfile():
## def tofile():