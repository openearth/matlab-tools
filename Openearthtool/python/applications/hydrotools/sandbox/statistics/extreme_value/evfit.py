# -*- coding: utf-8 -*-
"""
Created on Thu Oct 08 10:19:33 2015

@author: eilan_dk (dirk.eilander@deltares.nl)
v0.1 26/01/2016


"""
import numpy as np
import scipy.stats as st

# you might need to install these libraries
import lmoments as lm


def lmfit_gumbel(AM):
    """
    l-moment fit for gumbel dist


    :param AM: numpy array with lock maxima
    :return:
    """
    p_loc, p_sc = lm.pelgum(lm.samlmu(AM, 2))
    rv = st.genextreme(0, loc=p_loc, scale=p_sc)
    rv.par = [0, p_loc, p_sc]
    rv.dist.name = 'gumb'

    return rv

def lmfit_gev(AM):
    """
    l-moment fit for gev dist


    :param AM: numpy array with block maxima
    :return:
    """
    p_shape, p_loc, p_sc = lm.pelgev(lm.samlmu(AM, 3))
    rv = st.genextreme(p_shape, loc=p_loc, scale=p_sc)
    rv.par = [p_shape, p_loc, p_sc]
    rv.dist.name = 'gev'

    return rv

def bootstrap_indexes(data, n_samples=10000):
    """
    Given data points data, where axis 0 is considered to delineate points, return
    an array where each row is a set of bootstrap indexes. This can be used as a list
    of bootstrap indexes as well.
    """
    return np.random.randint(data.shape[0], size=(n_samples, data.shape[0]))


def bi_gev(sample):
    p_loc, p_sc, p_sh = lm.pelgev(lm.samlmu(sample, 3))
    return (p_sh, p_loc, p_sc)


def bi_gum(sample):
    p_loc, p_sc = lm.pelgum(lm.samlmu(sample, 2))
    return (0, p_loc, p_sc)


def CI_bootstrap(sample, R, rv, lambd=1, thresh=0, pc=95, nb=1000):
    if rv.dist.name == 'gev':
        fitfunc = bi_gev
    if rv.dist.name == 'gumb':
        fitfunc = bi_gum

    data = np.array(sample) - thresh
    tdata = (data,)  # data book keeping
    bootindexes = bootstrap_indexes(tdata[0], nb)  # creat random samples by generating indices
    parh = np.array([fitfunc(*(x[indexes] for x in tdata)) for indexes in bootindexes])  # bootstrap
    # bias correctioin
    parh0 = rv.par  # fitfunc(sample)
    bias = parh0 - np.nanmean(parh, axis=0)
    parh += bias
    # compute requested percentiles stat
    percent = [(100 - pc) / 2., 100 - (100 - pc) / 2.]
    # compute requested percentiles rval
    Qarray = 1 - 1. / (lambd * R)
    lb = np.array([])
    ub = lb
    for q in Qarray:
        a = np.array([rv.dist.ppf(q, pari[0], loc=pari[1], scale=pari[2]) + thresh for pari in parh])
        lb = np.hstack((lb, np.percentile(a, percent[0])))
        ub = np.hstack((ub, np.percentile(a, percent[1])))
    return lb, ub

