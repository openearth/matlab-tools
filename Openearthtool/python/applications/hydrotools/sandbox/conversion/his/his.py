"""Reads and writes SOBEK HIS files.
Martijn Visser, Deltares, 2014-06
"""

from struct import unpack, pack
import numpy as np
from datetime import datetime, timedelta
from os.path import getsize
import pandas as pd

def read(hisfile):
    '''Read a hisfile to a Pandas panel with extra attributes.'''
    filesize = getsize(hisfile)
    with open(hisfile, 'rb') as f:
        header = f.read(120)
        timeinfo = f.read(40)
        datestr = timeinfo[4:14].replace(' ', '0') + timeinfo[14:23]
        startdate = datetime.strptime(datestr, '%Y.%m.%d %H:%M:%S')
        dt = int(timeinfo[30:-2]) # assumes unit is seconds
        noout, noseg = unpack('ii', f.read(8))
        notim = ((filesize - 168 - noout*20 - noseg*24) /
                 (4 * (noout * noseg + 1)))
        params = [f.read(20).rstrip() for _ in xrange(noout)]
        locnrs, locs = [], []
        for i in xrange(noseg):
            locnrs.append(unpack('i', f.read(4))[0])
            locs.append(f.read(20).rstrip())
        dates = []
        data = np.zeros((noout, notim, noseg), np.float32)
        for t in xrange(notim):
            ts = unpack('i', f.read(4))[0]
            date = startdate + timedelta(seconds=ts*dt)
            dates.append(date)
            for s in xrange(noseg):
                data[:, t, s] = np.fromfile(f, np.float32, noout)

    pn = pd.Panel(data, items=params, major_axis=dates, minor_axis=locs,
                  dtype=np.float32, copy=True)
    pn.meta = dict(header=header, scu=dt, t0=startdate)
    return pn

def write(hisfile, pn):
    '''Writes a Pandas panel with extra attributes to a hisfile.'''
    with open(hisfile, 'wb') as f:
        header = pn.meta['header']
        scu = pn.meta['scu']
        t0 = pn.meta['t0']
        f.write(header.ljust(120)[:120]) # enforce length
        t0str = t0.strftime('%Y.%m.%d %H:%M:%S')
        timeinfo = 'T0: {}  (scu={:8d}s)'.format(t0str, scu)
        f.write(timeinfo)
        noout, notim, noseg = pn.shape
        f.write(pack('ii', noout, noseg))
        params = np.array(pn.items, dtype='S20')
        params = np.char.ljust(params, 20)
        params.tofile(f)
        locs = np.array(pn.minor_axis, dtype='S20')
        locs = np.char.ljust(locs, 20)
        for locnr, loc in enumerate(locs):
            f.write(pack('i', locnr))
            f.write(loc)
        data = pn.values.astype(np.float32)
        for t, date in enumerate(pn.major_axis):
            ts = int((date - t0).total_seconds() / scu)
            f.write(pack('i', ts))
            for s in xrange(noseg):
                data[:, t, s].tofile(f)
        countmsg = 'hisfile written is not the correct length'
        assert f.tell() == 160 + 8 + 20 * noout + (4 + 20) * noseg + notim * (4 + noout * noseg * 4), countmsg

