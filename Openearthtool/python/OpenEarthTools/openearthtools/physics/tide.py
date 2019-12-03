# Function wrapper for tappy, so we can run the prediction without using xml input files.
# http://sourceforge.net/apps/mediawiki/tappy/index.php?title=Main_Page
# http://sourceforge.net/projects/tappy/

# Based on
#Copyright (C) 2005  Tim Cera timcera@earthlink.net
#http://tappy.sourceforge.net
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

import collections
import datetime
import bisect

import numpy as np
import scipy.interpolate
import pandas
import netCDF4

import tappy_lib
import astronomia.elp2000 as elp
import astronomia.sun as sun
import astronomia.calendar as cal
import astronomia.util as uti

deg2rad = np.pi/180.0
rad2deg = 180.0/np.pi


# utility for fast interpolation
# Find the lon, lat
# Draw a box around it
# Do an interpolation in the bix
def interpolate_window(lon_i, lat_i, lon, lat, arr, circular=False):
    """
    interpolate tide with a window (of 4 by default)
    lon_i, lat_i are the point to interpolate the tide on
    lon, lat are the spatial dimensions of arr
    if arr is circular it is split up into 2 components and put back together and transform to rads
    """

    # lookup position of the point in the lat, lon arrays
    lon_index = bisect.bisect(lon, lon_i)
    lat_index = bisect.bisect(lat, lat_i)
    # define a window size (for spline interpolation)
    window = 4

    # determine the shape
    lon_min = max(lon_index-window, 0)
    lon_max = min(lon_index+window, lon.shape[0]-1)
    lat_min = max(lat_index-window, 0) # in index space (not -90)
    lat_max = min(lat_index+window, lat.shape[0]-1)

    # determine the slice that we need
    lonslice = slice(lon_min, lon_max)
    latslice = slice(lat_min, lat_max)
    # look up the slice in the lat,lon coordinates
    Lon = lon[lonslice]
    Lat = lat[latslice]
    # Look up the values in the array
    A = arr[:,lonslice, latslice]
    if circular:
        # No degrees pls
        A = np.deg2rad(A)
    # Loop over the first dimension (constituents)
    results = []
    for i in range(A.shape[0]):
        if circular:
            # Interpolate the phases separate for a circular interpolation
            # Assume A is in degrees
            f_cos = scipy.interpolate.RectBivariateSpline(Lon, Lat, np.cos(A[i]), kx=2, ky=2, s=0)
            f_sin = scipy.interpolate.RectBivariateSpline(Lon, Lat, np.sin(A[i]), kx=2, ky=2, s=0)
            result = np.arctan2(f_sin(lon_i, lat_i), f_cos(lon_i, lat_i))
        else:
            # Just define a simple interpolation
            f = scipy.interpolate.RectBivariateSpline(Lon, Lat, A[i], kx=2, ky=2, s=0)
            result = f(lon_i, lat_i)
        # append
        results.append(result.squeeze())
    # convert back to an array (concat)
    return np.asarray(results)


def make_location(lon_i, lat_i, lon, lat, A, Phi, constituents):
    """
    create a dataframe for a location with the tidal information

    >>> ds = netCDF4.Dataset('http://opendap.deltares.nl/thredds/dodsC/opendap/osu/tpxo/h_tpxo7.2.nc')
    >>> if not TPXO:
    ...     TPXO.update(read_tpxo())
    >>> A = ds.variables['ha']
    >>> Phi = ds.variables['hp']
    >>> location = make_location(3, 52, TPXO['lon'], TPXO['lat'], A, Phi, TPXO['constituents'])
    >>> location.ix['M2']
    amplitude    0.790517
    phase        0.174533
    Name: M2, dtype: float64
    """
    amplitudes = interpolate_window(lon_i, lat_i, lon, lat, A, circular=False)
    # also transforms from deg2rad....
    phases = interpolate_window(lon_i, lat_i, lon, lat, Phi, circular=True)
    locationdf = pandas.DataFrame(data=dict(amplitude=amplitudes, phase=phases), index=constituents)
    return locationdf


def read_tpxo():
    ds = netCDF4.Dataset('http://opendap.deltares.nl/thredds/dodsC/opendap/osu/tpxo/h_tpxo7.2.nc')
    lon = ds.variables['lon_z'][:,1] # somehow 0 contains strange values
    lat = ds.variables['lat_z'][0,:]
    const = netCDF4.chartostring(ds.variables['con'][:]) # the same as for u
    constituents = [x.strip().upper() for x in const]
    ds.close()
    return {
        'lon': lon,
        'lat': lat,
        'constituents': constituents
        }

# store on first call
TPXO = {}


def predict(points, dates=None, nodal=True):
    """
    Predict the tide for 1 or more locations for 1 or more dates.
    Data is returned
    """
    points = np.atleast_2d(points)

    # keep a list of all data frames
    dfs = []
    for point in points:
        h = predict_point(point, dates, nodal)
        # make sure all sizes align
        lon = np.zeros_like(dates, dtype=float) + point[0]
        lat = np.zeros_like(dates, dtype=float) + point[1]
        h = np.zeros_like(dates, dtype=float) + h
        df = pandas.DataFrame(data=collections.OrderedDict(lon=lon, lat=lat, date=dates, h=h))
        dfs.append(df)
    result =  pandas.concat(dfs, join="inner")
    return result

def predict_point(point, dates=None, nodal=True):
    """
    Predict the tide for a location for 1 or more dates
    """

    lon_i, lat_i = point

    if dates is None:
        dates = [datetime.datetime.now()]

    # convert to julian hours
    # julian days
    jd = dates2jd(dates)
    jh = jd * 24.0


    T = nodalconstituents(dates)
    T = {key.upper(): T[key] for key in T}
    T = pandas.DataFrame.from_dict(T, orient='index')

    if not TPXO:
        TPXO.update(read_tpxo())
    ds = netCDF4.Dataset('http://opendap.deltares.nl/thredds/dodsC/opendap/osu/tpxo/h_tpxo7.2.nc')
    A = ds.variables['ha']
    Phi = ds.variables['hp']
    location = make_location(lon_i, lat_i, TPXO['lon'], TPXO['lat'], A, Phi, TPXO['constituents'])
    ds.close()


    total = 0
    for const, row in location.iterrows():
        phase, ampl = row['phase'], row['amplitude']
        if nodal:
            # TODO: sometimes T['FF'][const] is a series, why?
            component = ampl*T['FF'][const]*np.cos(T['ospeed'][const]*jh - (phase - T['VAU'][const]))
        else:
            component = ampl*np.cos(T['ospeed'][const]*jh  - phase)
        try:
            # newer pandas return a series, convert back to scalar
            component = component.item()
        except (AttributeError, ValueError):
            pass
        total = total + component
    return total
def date2jd(date):
    """
    given a date, convert to julian days
    >>> date = datetime.datetime(2013,8,19,0,0)
    >>> date2jd(date)
    2456523.5

    """

    jd = cal.cal_to_jd(date.year, date.month, date.day) + \
         uti.hms_to_fday(date.hour, date.minute, date.second)
    return jd

def dates2jd(dates):
    """
    Given a date or dat will return a vector of Julian days as required
    by astronomia.
    """
    jd = np.array([date2jd(d) for d in dates])
    return jd


def node_factor_73(ii):
    return ((2./3.) - np.sin(ii)**2)/0.5021
def node_factor_74(ii):
    return np.sin(ii)**2 /0.1578
def node_factor_75(ii):
    return np.sin(ii)*np.cos(0.5*ii)**2 /0.37988
def node_factor_76(ii):
    return np.sin(2.0*ii)/0.7214
def node_factor_77(ii):
    return (np.sin(ii)*np.sin(0.5*ii)**2)/0.0164
def node_factor_78(ii):
    return np.cos(0.5*ii)**4 /0.91544
def node_factor_79(ii):
    return np.sin(ii)**2/0.1565
def node_factor_149(ii):
    return np.cos(0.5*ii)**6 /0.8758
def node_factor_144(ii):
    return (1.0 - 10.0*np.sin(0.5*ii)**2 +
            15.0*np.sin(0.5*ii)**4)*np.cos(0.5*ii)**2/0.5873
def node_factor_227(ii, nu):
    return (0.8965*(np.sin(2.*ii)**2) +
            0.6001*np.sin(2.*ii)*np.cos(nu) +
            0.1006)**0.5
def node_factor_235(ii, nu):
    return (19.0444*(np.sin(ii)**4) +
            2.7702*(np.sin(ii)**2) * np.cos(2.*nu) +
            0.0981)**0.5  # eq 235 schureman

def nodalconstituents(dates):
    """
    Return the nodal consituents for 1 or more dates.
    The returned parameters are:
    ospeed: angular frequency (rad/hr)

    """
    jd = dates2jd(dates)

    length = len(dates)
    lunar_eph = elp.ELP2000()
    solar_eph = sun.Sun()

    Nv = lunar_eph.mean_longitude_ascending_node(jd)
    p = lunar_eph.mean_longitude_perigee(jd)
    s = lunar_eph.mean_longitude(jd)
    h = solar_eph.mean_longitude(jd)
    p1 = solar_eph.mean_longitude_perigee(jd)

    # Calculate constants for V+u
    # I, inclination of Moon's orbit, pg 156, Schureman
    i = np.arccos(0.9136949 - 0.0356926*np.cos(Nv))

    # pg 156
    const_1 = 1.01883*np.tan(0.5*Nv)
    const_2 = 0.64412*np.tan(0.5*Nv)
    const_3 = 2.*np.arctan(const_1) - Nv
    const_4 = 2.*np.arctan(const_2) - Nv
    zeta = -0.5*(const_3 + const_4)
    nu = 0.5*(const_3 - const_4)

    const_1 = np.sin(2.0*i)*np.sin(nu)
    const_2 = np.sin(2.0*i)*np.cos(nu) + 0.3347
    nup = np.arctan2(const_1, const_2)  # eq 224

    const_1 = np.sin(i)**2 * np.sin(2.0*nu)
    const_2 = np.sin(i)**2 * np.cos(2.0*nu) + 0.0727
    nupp = 0.5*np.arctan2(const_1, const_2) # eq 232

    hour = jd[0] - int(jd[0])

    kap_p = (p - zeta)  # eq 191

    # pg 44, Schureman
    # Since R is only used for L2, should eventually move this
    term1 = np.sin(2.*kap_p)
    term2 = (1./6.)*(1./np.tan(i*0.5))**2
    term3 = np.cos(2.*kap_p)
    R = np.mod(np.arctan(term1/(term2 - term3)), 2*np.pi)

    # pg 42
    # Since Q is used only for NO1, should eventually move this
    Q = np.mod(np.arctan(0.483*np.tan(kap_p)) + np.pi, 2*np.pi)

    # hour == fraction of day
    # whitin day phase in radians
    T = 360.*hour*deg2rad

    ii = i


    tidal_dict = constituents()

    tidal_dict["M2"].update({
        'VAU': 2*(T - s + h + zeta - nu),
        'u':   2*(zeta - nu),
        'FF': node_factor_78(ii)
    })
    tidal_dict["K1"].update({
        'VAU': T + h - 90*deg2rad - nup,
        'u':   -nup,
        'FF': node_factor_227(ii, nu)
    })
    tidal_dict["M3"].update({
        'VAU': 3*(T - s + h + zeta - nu),
        'u': 3*(zeta - nu),
        'FF': node_factor_149(ii)
    })
    tidal_dict["M4"].update({
        'VAU': 2.*tidal_dict['M2']['VAU'],
        'FF': tidal_dict['M2']['FF']**2
    })
    tidal_dict["M6"].update({
        'VAU': 3.*tidal_dict['M2']['VAU'],
        # Parker, et. al node factor for M6 is square of M2.  This is
        # inconsistent with IHOTC, Schureman, and FF of M4 and M8.
        'FF': tidal_dict['M2']['FF']**3
    })
    tidal_dict["M8"].update({
        'VAU': 4.*tidal_dict['M2']['VAU'],
        'FF': tidal_dict['M2']['FF']**4
    })
    tidal_dict["S6"].update({
        'VAU': 6*T,
        'FF': np.ones(length)
    })
    tidal_dict["O1"].update({
        'VAU': T - 2*s + h + 90*deg2rad + 2*zeta - nu,
        'u': 2*zeta - nu,
        'FF': node_factor_75(ii)
    })
    tidal_dict["S2"].update({
        'VAU': 2*T,
        'FF': np.ones(length)
    })
    tidal_dict["2MS6"].update({
        'VAU': (2.0*tidal_dict['M2']['VAU'] +
                tidal_dict['S2']['VAU']),
        'FF': tidal_dict['M2']['FF']**2
    })
    tidal_dict["2SM6"].update({
        'VAU': (2.0*tidal_dict['S2']['VAU'] +
                tidal_dict['M2']['VAU']),
        'FF': tidal_dict['M2']['FF']
    })
    tidal_dict["MSf"].update({
        'VAU': 2.0*(s - h),
        'FF': node_factor_75(ii)
    })
    tidal_dict["SK3"].update({
        'VAU': tidal_dict['S2']['VAU'] + tidal_dict['K1']['VAU'],
        'FF': tidal_dict['K1']['FF']
    })
    # Might need to move this to another time span - couldn't find this
    # in Foreman for Rayleigh comparison pair.
    tidal_dict["2SM2"].update({
        'VAU': (2.0*tidal_dict['S2']['VAU'] -
                tidal_dict['M2']['VAU']),
        'FF': tidal_dict['M2']['FF']
    })
    tidal_dict["MS4"].update({
        'VAU': (tidal_dict['M2']['VAU'] +
                tidal_dict['S2']['VAU']),
        'FF': tidal_dict['M2']['FF']**2
    })
    tidal_dict["S4"].update({
        'VAU': 4*T,
        'FF': np.ones(length)
    })
    tidal_dict["OO1"].update({
        'VAU': T + 2*s + h - 90*deg2rad - 2*zeta - nu,
        'FF': node_factor_77(ii)
    })
    tidal_dict["MK3"].update({
        'VAU': tidal_dict['M2']['VAU'] + tidal_dict['K1']['VAU'],
        'FF': tidal_dict['M2']['FF']*tidal_dict['K1']['FF']
    })
    # Seems like 2MK3 in Schureman is equivalent to MO3 in Foreman
    tidal_dict["MO3"].update({
        'VAU': (2*tidal_dict['M2']['VAU'] -
                tidal_dict['K1']['VAU']),
        'FF': tidal_dict['M2']['FF']**2*tidal_dict['K1']['FF']
    })
    tidal_dict["N2"].update( {
        'VAU': 2*T - 3*s + 2*h + p + 2*zeta - 2*nu,
        'FF': tidal_dict['M2']['FF']
    })
    tidal_dict["2MN6"].update({
        'VAU': (2*tidal_dict['M2']['VAU'] +
                tidal_dict['N2']['VAU']),
        'FF': tidal_dict['M2']['FF']**3
    })
    tidal_dict["2Q1"].update({
        'VAU': T - 4*s + h + 2*p + 90*deg2rad + 2*zeta - nu,
        'FF': tidal_dict['O1']['FF']
    })
    tidal_dict["Q1"].update( {
        'VAU': T - 3*s + h + p + 90*deg2rad + 2*zeta - nu,
        'FF': tidal_dict['O1']['FF']
    })
    tidal_dict["J1"].update( {
        'VAU': T + s + h - p - 90*deg2rad - nu,
        'FF': node_factor_76(ii)
    })
    # Seems like KJ2 in Schureman is equivalent to eta2 in Foreman
    tidal_dict["eta2"].update({
        'VAU': 2*T + s + 2*h - p - 2*nu,
        'FF': node_factor_79(ii)
    })
    # Seems like KQ1 in Schureman is equivalent to ups1 in Foreman
    tidal_dict["ups1"].update({
        'VAU': T + 3*s + h - p - 90*deg2rad - 2*zeta - nu,
        'FF': node_factor_77(ii)
    })
    #
    # The M1/NO1 curse.
    #
    #        Foreman         Schureman           TASK
    #        =======         =========           ====
    # NO1   14.496693984        NA            UNKNOWN
    # M1        NA           14.4966939      14.4920521
    # (M1)      NA           14.4920521         NA
    #
    # Foreman mentions that M1 is a satellite of NO1 but does not have a
    # ospeed for M1.

    # By comparing the ospeeds from the different sources, I now think that
    # the component of M1 in Schureman is actually NO1 (ospeed=14.496693984)
    # and M1 in TASK is equal to (M1) in Schureman.

    # Flater writes:

        # In summary, M1 is a minor constituent that doesn't deserve to be
        # such an inconvenience.  Until someone complains, I am just going
        # to use the NOS M1 for all data containing a constituent named M1
        # and hope for the best.  Future producers of harmonic constants
        # are advised to abolish M1 and just use NO1.

    # More confusion: Flater in libcongen uses M1.

    # If M1 is 1/2 the ospeed of M2 that would mean TASK's M1 ospeed is
    # correct.  How do I get V, u, and f?  Let's use A71 from Schureman.
    # Why?  Because A71 is listed as a major component of M1, and the
    # ospeeds match (1/2 of M2 ospeed)

    # TAPPY
    # Constituent     Speed        V, u, and f
    # M1            14.492052126  From Schureman A71
    # NO1           14.496693984  From Schureman M1

    tidal_dict["M1"].update( {
        'VAU': T - s + h + zeta + nu, # term A71 in Schureman
        'FF': node_factor_144(ii)
    })
    tidal_dict["NO1"].update({
        'VAU': T - s + h - 90*deg2rad + zeta - nu + Q,
        # 2.307**0.5 factor was missed in Darwin's analysis and the wrong
        # factor was used for M1 for many years.  Indicates the importance
        # of M1 and NO1.  As with many constituents listed here, I have
        # included them for completeness rather than necessity.
        'FF': (tidal_dict['O1']['FF']*
               (2.31+1.435*np.cos(2.0*kap_p))**0.5/2.307**0.5)
    })
    tidal_dict["MN4"].update({
        'VAU': tidal_dict['M2']['VAU'] + tidal_dict['N2']['VAU'],
        'FF': tidal_dict['M2']['FF']**2
    })
    tidal_dict["Mm"].update( {
        'VAU': s - p,
        'FF': node_factor_73(ii)
    })
    tidal_dict["L2"].update( {
        'VAU': 2*T - s + 2*h - p + 180*deg2rad + 2*zeta - 2*nu - R,
        'FF': (tidal_dict['M2']['FF'] /
               (1.0/(1.0 - 12.0*np.tan(0.5*ii)**2 * np.cos(2.0*kap_p) +
                     36.0*np.tan(0.5*ii)**4)**0.5)) # eq 215, schureman
    })
    tidal_dict["mu2"].update({
        'VAU': 2*T - 4*s + 4*h + 2*zeta - 2*nu,
        'FF': tidal_dict['M2']['FF']
    })
    tidal_dict["MNS2"].update({
        'VAU': 2*T - 5*s + 4*h + p + 4*zeta - 4*nu, # verify
        'FF': tidal_dict['M2']['FF']**2
    })
    tidal_dict["SN4"].update({
        'VAU': 2*T - 5*s + 4*h + p + 4*zeta - 4*nu,
        'FF': tidal_dict['M2']['FF']**2
    })
    tidal_dict["Ssa"].update({
        'VAU': 2.0*h,
        'FF': np.ones(length)
    })
    tidal_dict["Mf"].update( {
        'VAU': 2.0*(s - zeta),
        'FF': node_factor_74(ii)
    })
    tidal_dict["P1"].update({
        'VAU': T - h + 90*deg2rad,
        'FF': np.ones(length)
    })
    tidal_dict["K2"].update({
        'VAU': 2*(T + h - nupp),
        'FF': node_factor_235(ii, nu)
    })
    tidal_dict["SO3"].update({
        'VAU': 3*T - 2*s + h + 90*deg2rad + 2*zeta - nu,
        'FF': tidal_dict["O1"]["FF"]
    })
    tidal_dict["phi1"].update({
        'VAU': T + 3*h - 90*deg2rad,
        'FF': np.ones(length)
    })
    tidal_dict["SO1"].update({
        'VAU': T + 2*s - h - 90*deg2rad - nu,
        'FF': tidal_dict['J1']['FF']
    })
    # Seems like A54 in Schureman is equivalent to MKS2 in Foreman
    tidal_dict["MKS2"].update({
        'VAU': 2*T - 2*s + 4*h - 2*nu,
        'FF': tidal_dict['eta2']['FF']
    })
    # Seems like MP1 in Schureman is equivalent to tau1 in Foreman
    tidal_dict["MP1"].update({
        'VAU': T - 2*s + 3*h - 90*deg2rad - nu,
        'FF': tidal_dict['J1']['FF']
    })
    # Seems like A19 in Schureman is equivalent to BET1 in Foreman
    # Can't find BET1 in eXtended Doodson numbers
    tidal_dict["beta1"].update({
        'VAU': T - s - h + p - 90*deg2rad - 2*zeta - nu,
        'FF': tidal_dict['O1']['FF']
    })
    tidal_dict["MK4"].update({
        'VAU': tidal_dict['M2']['VAU'] + tidal_dict['K2']['VAU'],
        'FF': tidal_dict['M2']['FF'] * tidal_dict['K2']['FF']
    })
    tidal_dict["MSN2"].update({
        'VAU': tidal_dict['M2']['VAU'] + tidal_dict['K2']['VAU'],
        'FF': tidal_dict['M2']['FF'] * tidal_dict['K2']['FF']
    })
    tidal_dict["2N2"].update({
        'VAU': 2*(T - 2*s + h + p + zeta - nu),
        'FF': tidal_dict['M2']['FF']
    })
    tidal_dict["nu2"].update({
        'VAU': 2*T - 3*s + 4*h - p + 2*zeta - 2*nu,
        'FF': tidal_dict['M2']['FF']
    })
    # Seems like A4 in Schureman is equivalent to MSm in Foreman
    tidal_dict["MSm"].update({
        'VAU': s - 2*h + p,
        'FF': tidal_dict['Mm']['FF']
    })
    # nuJ1 = sigma1
    tidal_dict["nuJ1"].update({
        'VAU': T - 4*s + 3*h + 90*deg2rad + 2*zeta - nu,
        'FF': tidal_dict['O1']['FF']
    })
    tidal_dict["rho1"].update({
        'VAU': T - 3*s + 3*h - p + 90*deg2rad + 2*zeta - nu,
        'FF': tidal_dict['O1']['FF']
    })
    tidal_dict["chi1"].update({
        'VAU': T - s + 3*h - p - 90*deg2rad - nu,
        'FF': tidal_dict['J1']['FF']
    })
    tidal_dict["theta1"].update({
        'VAU': T + s - h + p - 90*deg2rad - nu,
        'FF': tidal_dict['J1']['FF']
    })
    tidal_dict["lambda2"].update({
        'VAU': 2*T - s + p + 180*deg2rad,
        'FF': tidal_dict['M2']['FF']
    })
    tidal_dict["Sa"].update({
        'VAU': h,
        'FF': np.ones(length)
    })
    tidal_dict["S1"].update({
        'VAU': T,
        'FF': np.ones(length)
    })
    tidal_dict["T2"].update({
        'VAU': 2*T - h + p1,
        'FF': np.ones(length)
    })
    tidal_dict["R2"].update({
        'VAU': 2*T + h - p1 + 180*deg2rad,
        'FF': np.ones(length)
    })
    tidal_dict["pi1"].update({
        'VAU': T - 2*h + p1 + 90*deg2rad,
        'FF': np.ones(length)
        #'pi1': [1, 'AAWZZAY', [1, 1, -3, 0, 0, 1, -1]],
    })
    tidal_dict["psi1"].update({
        'VAU': T + 2*h - p1 - 90*deg2rad,
        'FF': np.ones(length)
        #'psi1': [1, 'AAAZZYA', [1, 1, 1, 0, 0, -1, 1]],
    })
    for key, val in tidal_dict.iteritems():
        for key2 in {'VAU', 'FF', 'u'}:
            if key2 in val:
                val[key2] = np.atleast_1d(val[key2])

        tidal_dict[key] = val
    return tidal_dict



def constituents():
    """
    Constituents excluding nodal factors. ospeed is angular frequency in radians per hour.

    >>> T = constituents()
    >>> per_hour = T['M2']['ospeed']/(2*np.pi)
    >>> np.allclose(1/(per_hour),12.4206012)
    True
    """

    # Required length of time series depends on Raleigh criteria to
    # differentiate beteen constituents of simmilar speed.
    #  Key is tidal constituent name from Schureman
    #    speed is how fast the constiuent moves in radians/hour
    #    VAU is V+u taken from Schureman
    #    FF is the node factor from Schureman

    # TASK has the following constituents
    #  MSN6       87.4238337

    # TODO: insert doodson numbers and coefficients
    tidal_dict = {}

    tidal_dict["M2"] = {
        'ospeed': 28.984104252*deg2rad
    }
    tidal_dict["K1"] = {
        'ospeed': 15.041068632*deg2rad
    }
    tidal_dict["M3"] = {
        'ospeed': 43.476156360*deg2rad
    }
    tidal_dict["M4"] = {
        'ospeed': 57.968208468*deg2rad,
    }
    tidal_dict["M6"] = {
        'ospeed': 86.952312720*deg2rad,
    }
    tidal_dict["M8"] = {
        'ospeed': 115.936416972*deg2rad,
    }
    tidal_dict["S6"] = {
        'ospeed': 90.0*deg2rad,
    }
    tidal_dict["O1"] = {
        'ospeed': 13.943035584*deg2rad
    }
    tidal_dict["S2"] = {
        'ospeed': 30.0000000*deg2rad,
    }
    tidal_dict["2MS6"] = {
        'ospeed': 87.968208492*deg2rad
    }
    tidal_dict["2SM6"] = {
        'ospeed': 88.984104228*deg2rad
    }
    tidal_dict["MSf"] = {
        'ospeed': 1.0158957720*deg2rad
    }
    tidal_dict["SK3"] = {
        'ospeed': 45.041068656 * deg2rad
    }
    # Might need to move this to another time span - couldn't find this
    # in Foreman for Rayleigh comparison pair.
    tidal_dict["2SM2"] = {
        'ospeed': 31.01589576*deg2rad
    }
    tidal_dict["MS4"] = {
        'ospeed': 58.984104240*deg2rad
    }
    tidal_dict["S4"] = {
        'ospeed': 60.0*deg2rad
    }
    tidal_dict["OO1"] = {
        'ospeed': 16.139101680*deg2rad
    }
    tidal_dict["MK3"] = {
        'ospeed': 44.025172884*deg2rad
    }
    # Seems like 2MK3 in Schureman is equivalent to MO3 in Foreman
    tidal_dict["MO3"] = {
        'ospeed': 42.927139836*deg2rad
    }
    tidal_dict["N2"] =  {
        'ospeed': 28.439729568*deg2rad
    }
    tidal_dict["2MN6"] = {
        'ospeed': 86.407938036*deg2rad
    }
    tidal_dict["2Q1"] = {
        'ospeed': 12.854286252*deg2rad
    }
    tidal_dict["Q1"] =  {
        'ospeed': 13.3986609*deg2rad
    }
    tidal_dict["J1"] =  {
        'ospeed': 15.5854433*deg2rad
    }
    # Seems like KJ2 in Schureman is equivalent to eta2 in Foreman
    tidal_dict["eta2"] = {
        'ospeed': 30.626511948*deg2rad
    }
    # Seems like KQ1 in Schureman is equivalent to ups1 in Foreman
    tidal_dict["ups1"] = {
        'ospeed': 16.683476328*deg2rad
    }
    #
    # The M1/NO1 curse.
    #
    #        Foreman         Schureman           TASK
    #        =======         =========           ====
    # NO1   14.496693984        NA            UNKNOWN
    # M1        NA           14.4966939      14.4920521
    # (M1)      NA           14.4920521         NA
    #
    # Foreman mentions that M1 is a satellite of NO1 but does not have a
    # ospeed for M1.

    # By comparing the ospeeds from the different sources, I now think that
    # the component of M1 in Schureman is actually NO1 (ospeed=14.496693984)
    # and M1 in TASK is equal to (M1) in Schureman.

    # Flater writes:

        # In summary, M1 is a minor constituent that doesn't deserve to be
        # such an inconvenience.  Until someone complains, I am just going
        # to use the NOS M1 for all data containing a constituent named M1
        # and hope for the best.  Future producers of harmonic constants
        # are advised to abolish M1 and just use NO1.

    # More confusion: Flater in libcongen uses M1.

    # If M1 is 1/2 the ospeed of M2 that would mean TASK's M1 ospeed is
    # correct.  How do I get V, u, and f?  Let's use A71 from Schureman.
    # Why?  Because A71 is listed as a major component of M1, and the
    # ospeeds match (1/2 of M2 ospeed)

    # TAPPY
    # Constituent     Speed        V, u, and f
    # M1            14.492052126  From Schureman A71
    # NO1           14.496693984  From Schureman M1

    tidal_dict["M1"] =  {
        'ospeed': 14.4920521*deg2rad
    }
    tidal_dict["NO1"] = {
        'ospeed': 14.496693984*deg2rad
    }
    tidal_dict["MN4"] = {
        'ospeed': 57.423833820*deg2rad
    }
    tidal_dict["Mm"] =  {
        'ospeed': 0.5443747*deg2rad
    }
    tidal_dict["L2"] =  {
        'ospeed': 29.5284789*deg2rad
    }
    tidal_dict["mu2"] = {
        'ospeed': 27.9682084*deg2rad
    }
    tidal_dict["MNS2"] = {
        'ospeed': 27.423833796*deg2rad
    }
    tidal_dict["SN4"] = {
        'ospeed': 58.4397295560*deg2rad
    }
    tidal_dict["Ssa"] = {
        'ospeed': 0.0821373*deg2rad
    }
    tidal_dict["Mf"] =  {
        'ospeed': 1.0980331*deg2rad
    }
    tidal_dict["P1"] = {
        'ospeed': 14.9589314*deg2rad
    }
    tidal_dict["K2"] = {
        'ospeed': 30.0821373*deg2rad
    }
    tidal_dict["SO3"] = {
        'ospeed': 43.9430356*deg2rad
    }
    tidal_dict["phi1"] = {
        'ospeed': 15.1232059*deg2rad
    }
    tidal_dict["SO1"] = {
        'ospeed': 16.0569644*deg2rad
    }
    # Seems like A54 in Schureman is equivalent to MKS2 in Foreman
    tidal_dict["MKS2"] = {
        'ospeed': 29.066241528*deg2rad
    }
    # Seems like MP1 in Schureman is equivalent to tau1 in Foreman
    tidal_dict["MP1"] = {
        'ospeed': 14.025172896*deg2rad
    }
    # Seems like A19 in Schureman is equivalent to BET1 in Foreman
    # Can't find BET1 in eXtended Doodson numbers
    tidal_dict["beta1"] = {
        'ospeed': 14.414556708*deg2rad
    }
    tidal_dict["MK4"] = {
        'ospeed': 59.066241516*deg2rad
    }
    tidal_dict["MSN2"] = {
        'ospeed': 30.544374672*deg2rad
    }
    tidal_dict["2N2"] = {
        'ospeed': 27.8953548*deg2rad
    }
    tidal_dict["nu2"] = {
        'ospeed': 28.5125831*deg2rad
    }
    # Seems like A4 in Schureman is equivalent to MSm in Foreman
    tidal_dict["MSm"] = {
        'ospeed': 0.4715210880*deg2rad
    }
    tidal_dict["nuJ1"] = {
        'ospeed': 12.9271398*deg2rad
    }
    tidal_dict["rho1"] = {
        'ospeed': 13.4715145*deg2rad
    }
    tidal_dict["chi1"] = {
        'ospeed': 14.5695476*deg2rad
    }
    tidal_dict["theta1"] = {
        'ospeed': 15.5125897*deg2rad
    }
    tidal_dict["lambda2"] = {
        'ospeed': 29.4556253*deg2rad
    }
    tidal_dict["Sa"] = {
        'ospeed': 0.0410686*deg2rad
    }
    tidal_dict["S1"] = {
        'ospeed': 15.0000000*deg2rad
    }
    tidal_dict["T2"] = {
        'ospeed': 29.9589333*deg2rad
    }
    tidal_dict["R2"] = {
        'ospeed': 30.0410667*deg2rad
    }
    tidal_dict["pi1"] = {
        'ospeed': 14.9178647*deg2rad
    }
    tidal_dict["psi1"] = {
        'ospeed': 15.0821352*deg2rad
    }
    return tidal_dict

def osu_constituents():
    """
    constituents from constit.h from osu tidal predict
    """
    import json
    import os
    data = json.load(open(os.path.join(os.path.dirname(__file__), "constit.json")))
    return data['records']


if __name__ == '__main__':
    import doctest
    doctest.testmod()
