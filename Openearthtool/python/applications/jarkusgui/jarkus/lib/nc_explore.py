__author__ = 'heijer'
from netCDF4 import Dataset
import datetime
import numpy as np

epoch = datetime.datetime.utcfromtimestamp(0)


def get_time(url, var='time'):
    ds = Dataset(url)
    time = ds.variables[var][:]
    ds.close()
    return [datetime.timedelta(days=days)+epoch for days in time]


def get_coastalareas(url, code_var='areacode', name_var='areaname'):
    ds = Dataset(url)
    ac = ds.variables[code_var][:]
    unique_codes, unique_indices = np.unique(ac, return_index=True)
    result = []
    for cd, aidx in zip(unique_codes, unique_indices):
        an = ds.variables[name_var][aidx, ]
        result.append({'name': "".join(an).strip(), 'number': cd})
    ds.close()
    return result


def get_id(url, var='id'):
    ds = Dataset(url)
    trid = ds.variables[var][:]
    ds.close()
    return trid


